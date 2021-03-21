//
//  TopicDetailViewModel.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/28.
//

import Foundation
import RxSwift
import ReactorKit
import HandyJSON
final class TopicDetailReactor: Reactor {
    
    enum Action {
        case getTopicDetail(Int)
        case clickLikeAction(HomePageModel)
        case clickCollection(HomePageModel)
        case getContact(Int)
        case addViewHistory
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setTopicDetail(HomePageModel)
        case setErrorMsg(String?)
        case setLikedStatus(Bool,LikeStatusModel?,HomePageModel?)
        case setCollectionStatus(Bool,CollectionStatusModel?,HomePageModel?)
        case setContact(String?)
        case setGetContactLoading(Bool)
        case setAddHistory
    }
    
    struct State {
        var topic_id: Int?
        var isLoading: Bool = false
        var isGetContactLoading: Bool = false
        var netError: Bool = false
        var section: [TopicDetailSection] = []
        var model: HomePageModel?
        var errorMsg: String?
        var loadEnd: Bool = false
    }
    
    var initialState: State = State()
    var netWorking = NetWorking<HomePageApi>()
    
    
    init(topicId: Int,model: HomePageModel? = nil) {
        self.initialState.topic_id = topicId
        if let model = model {
            self.initialState.model = model
            let infoItem: TopicDetailItem = .userInfoItem(TopicInfoCellReactor.init(detail: model))
            let contentItem: TopicDetailItem = .topicInfo(TopicContentCellReactor.init(topicDetail: model))
            let imgs = model.imgs?.map({ (imgStr) -> TopicDetailItem in
                return .topicImg(TopicImgCellReactor(img: imgStr))
            }) ?? []

            var sectionItems : [TopicDetailItem] = []
            sectionItems.append(infoItem)
            sectionItems.append(contentItem)
            sectionItems.append(contentsOf: imgs)
            let section: TopicDetailSection = .detailItem(sectionItems)
            self.initialState.section = [section]
        }
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .getTopicDetail(let topic_id):
            guard !self.currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.topidDetailNetworking(topicId: topic_id).map { (baseModel) -> Mutation in
                if baseModel?.isSuccess ?? false,let data = baseModel?.data {
                    return Mutation.setTopicDetail(data)
                }else{
                    return Mutation.setErrorMsg(baseModel?.message)
                }
            }
            return .concat([start,request,end])
        case .clickLikeAction(let model):
            guard !self.currentState.isLoading else {
                return .empty()
            }
            
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.likeTopicAction(model: model).map { (baseModel) -> Mutation in
                if baseModel?.isSuccess ?? false {
                    return Mutation.setLikedStatus(true, baseModel?.data,model)
                }else{
                    return Mutation.setLikedStatus(false, nil,nil)
                }
            }
            return .concat([start,request,end])
        case .clickCollection(let model):
            guard !self.currentState.isLoading else {
                return .empty()
            }
            
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.collectionTopic(model: model).map { (baseModel) -> Mutation in
                if baseModel?.isSuccess ?? false {
                    return Mutation.setCollectionStatus(true, baseModel?.data,model)
                }else{
                    return Mutation.setCollectionStatus(true, baseModel?.data,model)
                }
            }
            return .concat([start,request,end])
        case .getContact(let topicId):
            guard !self.currentState.isGetContactLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setGetContactLoading(true))
            let end = Observable.just(Mutation.setGetContactLoading(false))
            let request = self.getContactNetworking(topicId: topicId).map { (baseModel) -> Mutation in
                if baseModel?.isSuccess ?? false {
                    return Mutation.setContact(baseModel?.data?.contact)
                }else{
                    return Mutation.setErrorMsg("获取联系方式失败")
                }
            }
            return .concat([start,request,end])
        case .addViewHistory:
            guard self.currentState.loadEnd == true else {
                return .empty()
            }
            
            guard let topic_id = self.currentState.topic_id else {
                return .empty()
            }
            
            let request = self.addViewHistoryNetworking(topicId: topic_id).map { (baseModel) -> Mutation in
                return Mutation.setAddHistory
            }
            return request
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setLoading(let loading):
            state.isLoading = loading
        case .setGetContactLoading(let loading):
            state.isGetContactLoading = loading
        case .setTopicDetail(let model):
            state.model = model
            state.section = self.setupSection(model: model)
            state.loadEnd = true
        case .setErrorMsg(let msg):
            state.errorMsg = msg
        case .setLikedStatus(let success, let status,let oldModel):
            if success {
                
                if currentState.topic_id == oldModel?.topic_id {
                    state.model?.liked = status?.like
                    if state.model?.liked == 1 {
                        let likeNum = state.model?.likes_num
                        state.model?.likes_num = (likeNum ?? 0) + 1
                    }else{
                        if (state.model?.likes_num ?? 0) > 0 {
                            let likeNum = state.model?.likes_num
                            state.model?.likes_num = (likeNum ?? 1) - 1
                        }
                    }
                }
                
            }else{
                state.errorMsg = "点赞失败"
            }
        case .setCollectionStatus(let success, let status,let oldModel):
            if success {
                if currentState.topic_id == oldModel?.topic_id {
                    state.model?.collectioned = status?.collection
                    
                    if state.model?.collectioned == 1 {
                        let collecNum = state.model?.collection_num
                        state.model?.collection_num = (collecNum ?? 0) + 1
                    }else{
                        if (state.model?.collection_num ?? 0) > 0 {
                            let collecNum = state.model?.collection_num
                            state.model?.collection_num = (collecNum ?? 1) - 1
                        }
                    }
                }
                
            }else{
                state.errorMsg = "点赞失败"
            }
        case .setContact(let contact):
            guard let contact = contact else {
                return state
            }
            var newModel = state.model
            newModel?.contact_info = contact
            newModel?.getedcontact = 1
            if let orModel = newModel {
                state.model = orModel
                state.section = self.setupSection(model: orModel)
            }
        case .setAddHistory:
            return state
        }
        return state
    }
    
    func topidDetailNetworking(topicId: Int) -> Observable<BaseModel<HomePageModel>?> {
        return netWorking.request(.topicDetail(topicID: topicId)).mapData(HomePageModel.self)
    }
    
    func likeTopicAction(model: HomePageModel) -> Observable<BaseModel<LikeStatusModel>?> {
        let like_mark = (model.liked == 1) ? 0 : 1
        return netWorking.request(.likeTopicAction(like_mark: like_mark, topicId: model.topic_id ?? 0)).mapData(LikeStatusModel.self)
    }
    
    func collectionTopic(model: HomePageModel) -> Observable<BaseModel<CollectionStatusModel>?> {
        let collect_mark = (model.collectioned == 1) ? 0 : 1
        return netWorking.request(.collectionAction(collect_mark: collect_mark, topicId: model.topic_id ?? 0)).mapData(CollectionStatusModel.self)
    }
    
    func getContactNetworking(topicId: Int) -> Observable<BaseModel<ContactModel>?> {
        return netWorking.request(.getContact(topicId: topicId)).mapData(ContactModel.self)
    }
    
    func addViewHistoryNetworking(topicId: Int) -> Observable<BaseModel<EmptyModel>?> {
        return netWorking.request(.addViewHistory(topicId: topicId)).mapData(EmptyModel.self)
    }
    
    func setupSection(model: HomePageModel) -> [TopicDetailSection] {
        self.initialState.model = model
        let infoItem: TopicDetailItem = .userInfoItem(TopicInfoCellReactor.init(detail: model))
        let contentItem: TopicDetailItem = .topicInfo(TopicContentCellReactor.init(topicDetail: model))
        let imgs = model.imgs?.map({ (imgStr) -> TopicDetailItem in
            return .topicImg(TopicImgCellReactor(img: imgStr))
        }) ?? []

        var sectionItems : [TopicDetailItem] = []
        sectionItems.append(infoItem)
        sectionItems.append(contentItem)
        sectionItems.append(contentsOf: imgs)
        let section: TopicDetailSection = .detailItem(sectionItems)
        return [section]
    }
}


