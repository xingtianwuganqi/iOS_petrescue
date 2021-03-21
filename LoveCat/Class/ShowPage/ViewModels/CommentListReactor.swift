//
//  CommentListReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/28.
//

import Foundation
import RxSwift
import ReactorKit
final class CommentListReactor: Reactor {
        
    enum Action {
        case commentList(page: Paging)
        case commentAction(content: String)
        case replyAction(content: String,comment_id: Int,reply_id: Int,reply_type: Int,to_uid: Int)
        case changeComment(comment_id: Int?,reply_id: Int?,to_uid: Int?)
        case loadMoreReply(CommentListModel)
        case shieldAction(Int,Shield_type)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setRefreshing(Bool)
        case setCommentList([CommentListModel],Paging)
        case setCommentStatus(CommentListModel?)
        case setReplyStatus(ReplyListModel?)
        case setComment(comment_id: Int?,reply_id: Int?,to_uid: Int?)
        case setErrMsg(String?)
        case setMoreReply([ReplyListModel]?)
        case setShieldAction(Int,Shield_type)
    }
    
    struct State {
        var topicId: Int = 0
        var isLoading: Bool = false
        var netError: Bool = false
        var dataModel: [CommentListModel] = []
        var section: [CommentListSection] = []
        var endRefreshing: RefreshState?
        var page: Int = 1
        var comment_id: Int?
        var reply_id: Int?
        var to_uid: Int?
        var commentResult: Bool?
        var errMsg: String?
        var refreshing: Bool = false
    }
    
    var initialState: State = State()
    
    lazy var netWoking = NetWorking<ShowPageApi>()
    
    init(topicId: Int) {
        self.initialState.topicId = topicId
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .commentList(page: let page):
            guard  !self.currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))

            let request = self.networkingForComList(topicId: currentState.topicId,page: page).map { (baseModel) -> Mutation in
                return Mutation.setCommentList(baseModel?.dataArr ?? [],page)
            }.catchErrorJustReturn(Mutation.setErrMsg("网络错误"))
            return .concat([start,request,end])
        case .commentAction(content: let content):
            guard  !self.currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setRefreshing(true))
            let end = Observable.just(Mutation.setRefreshing(false))
            let request = self.networkingCommentList(content: content, topicId: currentState.topicId).map { (baseModel) -> Mutation in
                if baseModel?.isSuccess ?? false {
                    return Mutation.setCommentStatus(baseModel?.data ?? nil)
                }else{
                    return Mutation.setErrMsg(baseModel?.message ?? "评论失败")
                }
            }.catchErrorJustReturn(Mutation.setErrMsg("评论失败"))
            return .concat([start,request,end])
        case .replyAction(content: let content, comment_id: let comment_id, reply_id: let reply_id,reply_type: let replyType,to_uid: let to_uid):
            guard  !self.currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setRefreshing(true))
            let end = Observable.just(Mutation.setRefreshing(false))
            let request = self.networkingReplyList(content: content, comment_id: comment_id, reply_id: reply_id, reply_type: replyType, to_uid: to_uid).map { (baseModel) -> Mutation in
                if baseModel?.isSuccess ?? false {
                    return Mutation.setReplyStatus(baseModel?.data ?? nil)
                }else{
                    return Mutation.setErrMsg(baseModel?.message ?? "回复失败")
                }
            }.catchErrorJustReturn(Mutation.setErrMsg("回复失败"))
            return .concat([start,request,end])
        case .changeComment(comment_id: let comment_id, reply_id: let reply_id,to_uid: let to_uid):
            return Observable.just(Mutation.setComment(comment_id: comment_id, reply_id: reply_id,to_uid: to_uid))
        case .loadMoreReply(let model):
            guard  !self.currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setRefreshing(true))
            let end = Observable.just(Mutation.setRefreshing(false))
            let request = self.loadMoreReplyNetworking(model: model).map { (baseModel) -> Mutation in
                if baseModel?.isSuccess ?? false {
                    return Mutation.setMoreReply(baseModel?.dataArr ?? [])
                }else{
                    return Mutation.setMoreReply([])
                }
            }.catchErrorJustReturn(Mutation.setErrMsg("网络错误"))
            return .concat([start,request,end])
            
        case .shieldAction(let id, let shieldTyp):
            return .just(Mutation.setShieldAction(id, shieldTyp))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.errMsg = nil
        switch mutation {
        case .setLoading(let loading):
            state.isLoading = loading
        case .setRefreshing(let refreshing):
            state.refreshing = refreshing
        case .setCommentList(let commentList,let page):
            if page == .refresh {
                state.dataModel = commentList
            }else{
                state.dataModel += commentList
                if commentList.count == 0 {
                    state.page -= 1
                }
            }
            
            // 屏蔽
            let comArr = UserManager.shared.getUserShieldContent(shieldType: .show_sh_comment)
            let replyArr = UserManager.shared.getUserShieldContent(shieldType: .show_sh_reply)
            state.dataModel = state.dataModel.filter({ (model) -> Bool in
                !comArr.contains(model.comment_id!)
            })
            state.dataModel = state.dataModel.map({ (model) -> CommentListModel in
                var newModel = model
                let newReplys = model.replys?.filter({ (replyModel) -> Bool in
                    !replyArr.contains(replyModel.reply_id!)
                })
                newModel.replys = newReplys
                return newModel
            })
            
            state.endRefreshing = Tool.shared.getRefreshState(page: page, datas: commentList)
            state.section = self.updateSection(models: state.dataModel)
        case .setCommentStatus(let comment):
            guard let comment = comment else {
                return state
            }
            state.dataModel.insert(comment, at: 0)
            state.section = self.updateSection(models: state.dataModel)
        case .setReplyStatus(let reply):
            guard let replyInfo = reply else {
                return state
            }
            let data = state.dataModel.map { (model) -> CommentListModel in
                var newModel = model
                if newModel.comment_id == reply?.comment_id {
                    newModel.replys?.insert(replyInfo, at: 0)
                }
                return newModel
            }
            state.dataModel = data
            state.section = self.updateSection(models: state.dataModel)

        case .setComment(comment_id: let comment_id, reply_id: let reply_id,to_uid: let to_uid):
            state.comment_id = comment_id
            state.reply_id = reply_id
            state.to_uid = to_uid
        case .setErrMsg(let msg):
            state.errMsg = msg
        case .setMoreReply(let datas):
            guard let replys = datas,replys.count > 0,let replyComId = replys.first?.comment_id else {
                return state
            }
            let comments = state.dataModel.compactMap({ (comModel) -> CommentListModel? in
                if comModel.comment_id == replyComId {
                    var newModel = comModel
                    newModel.replys = (newModel.replys ?? []) + replys
                    newModel.next_page += 1
                    return newModel
                }else{
                    return comModel
                }
            })
            state.dataModel = comments
            state.section = self.updateSection(models: state.dataModel)
            
        case .setShieldAction(let id, let shield_type):
            if shield_type == .show_sh_comment {
                // 屏蔽
                state.dataModel = state.dataModel.filter({ (model) -> Bool in
                    model.comment_id != id
                })
            }else{
                state.dataModel = state.dataModel.map({ (model) -> CommentListModel in
                    var newModel = model
                    let newReplys = model.replys?.filter({ (replyModel) -> Bool in
                        replyModel.id != id
                    })
                    newModel.replys = newReplys
                    return newModel
                })
            }
            state.section = self.updateSection(models: state.dataModel)
        }
        return state
    }
    
    func updateSection(models: [CommentListModel]) -> [CommentListSection] {
        let items = models.map { (model) -> CommentListSection in
            var item: [CommentListItem] = []
            item.append(CommentListItem.commentItem(CommentListCellReactor.init(model: model)))
            model.replys?.forEach({ (reply) in
                item.append(CommentListItem.replyItem(ReplyListCellReactor.init(model: reply)))
            })
            if (model.reply_count ?? 0) > (model.replys?.count ?? 0) {
                item.append(CommentListItem.moreItem)
            }
            return CommentListSection.commentSection(item)
        }
        return items
    }
    
    func networkingForComList(topicId: Int,page: Paging) -> Observable<BaseModel<CommentListModel>?> {
        switch page {
        case .refresh:
            self.initialState.page = 1
        case .next:
            self.initialState.page += 1
        }
        return self.netWoking.request(.commentList(topic_id: topicId, page: self.initialState.page)).mapData(CommentListModel.self)
    }
    
    func networkingCommentList(content: String, topicId: Int) -> Observable<BaseModel<CommentListModel>?> {
        return self.netWoking.request(.commentAction(content: content, topic_id: topicId, comment_type: 2)).mapData(CommentListModel.self)
    }
    
    func networkingReplyList(content: String, comment_id: Int, reply_id: Int,reply_type: Int,to_uid: Int) -> Observable<BaseModel<ReplyListModel>?> {
        return self.netWoking.request(.replyComment(content: content, comment_id: comment_id,reply_id: reply_id, reply_type: reply_type, to_uid: to_uid)).mapData(ReplyListModel.self)
    }
    
    func loadMoreReplyNetworking(model: CommentListModel) -> Observable<BaseModel<ReplyListModel>?> {
        guard let comment_id = model.comment_id else {
            return .empty()
        }
        
        return self.netWoking.request(.loadMoreReply(comment_id: comment_id, page: model.next_page)).mapData(ReplyListModel.self)
    }
}


