//
//  MessagePageReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/3/22.
//

import Foundation
import ReactorKit
final class MessagePageReactor: Reactor {
    
    enum Action {
        case reloadMessageNum
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setMessageNum(MessageNumModel?)
    }
    
    struct State: StateProtocal {
        var isLoading: Bool = false
        var isRefreshing: Bool = false
        var netError: Bool = false
        var endRefreshing: RefreshState?
        var errorMsg: String?
        var msgDatas: [MinePageCellModel] = []
        var section : [MessagePageSection] = []
        var model   : MessageNumModel?
        var page: Int = 1
    }
    
    var initialState: State = State()
    lazy var networking: NetWorking = NetWorking<MessageApi>()
    init() {
        let msgDatas: [MinePageCellModel] =
            [   MinePageCellModel.init(iconImg: "icon_message_sys", title: "系统消息",num: 0),
                MinePageCellModel.init(iconImg: "icon_message_like", title: "点赞",num: 0),
                MinePageCellModel.init(iconImg: "icon_message_collect", title: "收藏",num: 0),
                MinePageCellModel.init(iconImg: "icon_message_com", title: "评论",num: 0),
            ]
        initialState.msgDatas = msgDatas
        initialState.section = self.updateSection(data: msgDatas)
        
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .reloadMessageNum:
            guard !self.currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.messageNumNetworking().map { (baseModel) -> Mutation in
                if baseModel?.isSuccess ?? false {
                    return Mutation.setMessageNum(baseModel?.data)
                }else{
                    return Mutation.setMessageNum(nil)
                }
            }.catchErrorJustReturn(Mutation.setMessageNum(nil))
            return .concat([start,request,end])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setLoading(let loading):
            state.isLoading = loading
        case .setMessageNum(let model):
            guard let model = model else {
                state.endRefreshing = .idle
                return state
            }
            let msgDatas: [MinePageCellModel] =
                [
                    MinePageCellModel.init(iconImg: "icon_message_sys", title: "系统消息",num: model.sys_unread ?? 0),
                    MinePageCellModel.init(iconImg: "icon_message_like", title: "点赞",num: model.like_unread ?? 0),
                    MinePageCellModel.init(iconImg: "icon_message_collect", title: "收藏",num: model.collec_unread ?? 0),
                    MinePageCellModel.init(iconImg: "icon_message_com", title: "评论",num: model.com_unread ?? 0),
                ]
            state.msgDatas = msgDatas
            state.section = self.updateSection(data: msgDatas)
            state.endRefreshing = .idle
            state.model = model
        }
        return state
    }
    
    
    func messageNumNetworking() -> Observable<BaseModel<MessageNumModel>?> {
        return networking.request(.authUnReadNum).mapData(MessageNumModel.self)
    }
    
    func updateSection(data: [MinePageCellModel]) -> [MessagePageSection] {
        let items = data.map { (model) -> MessagePageItems in
            return MessagePageItems.sysMsgItem(MinePageCellReactor.init(model: model))
        }
        return [MessagePageSection.msgPageItem(items)]
    }
}
