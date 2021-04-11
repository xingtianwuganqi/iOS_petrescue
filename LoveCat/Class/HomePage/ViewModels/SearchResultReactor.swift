//
//  SearchResultReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/4.
//

import Foundation
import RxSwift
import ReactorKit
final class SearchResultReactor: Reactor {
    
    enum Action {
        case beginSearch(String)
        case clearData
        case clickLikeAction(HomePageModel)
        case clickCollection(HomePageModel)
        case updateItemModel(HomePageModel)
        case shieldItem(Int)
    }
    
    enum Mutation {
        case empty
        case setLoading(Bool)
        case setListData([HomePageModel])
        case setErrorMsg(String?)
        case setKeyword(String)
        case setClearData
        case setUpdateItem(HomePageModel)
        case setShieldItem(Int)
        case setLikedStatus(Bool,LikeStatusModel?,HomePageModel?)
        case setCollectionStatus(Bool,CollectionStatusModel?,HomePageModel?)
    }
    
    struct State {
        var isLoading: Bool = false
        var netError: Bool = false
        var searchText: String = ""
        var dataModels: [HomePageModel] = []
        var section: [HomePageSection] = []
        var errorMsg: String?
        var keyword: String = ""
    }
    
    var initialState: State = State()
    var netWorking = NetWorking<HomePageApi>()
    
    func beginSearchKeyWord(keyWord: String) -> Observable<BaseModel<HomePageModel>?> {
        return  self.netWorking.request(.beginSearch(keyWord: keyWord)).mapData(HomePageModel.self)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .beginSearch(let keyword):
            guard !self.currentState.isLoading else {
                return .empty()
            }
            let key = Observable.just(Mutation.setKeyword(keyword))
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.beginSearchKeyWord(keyWord: keyword).map { (model) -> Mutation in
                guard let data = model?.dataArr else{
                    return Mutation.empty
                }
                return Mutation.setListData(data)
            }
            return Observable.concat([key,start,request,end])
        
        case .clearData:
            return Observable.just(Mutation.setClearData)
            
        case .updateItemModel(let model):
            return Observable.just(Mutation.setUpdateItem(model))
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
                    return Mutation.setCollectionStatus(false, baseModel?.data,model)
                }
            }
            return .concat([start,request,end])
        case .shieldItem(let id):
            return Observable.just(Mutation.setShieldItem(id))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setLoading(let loading):
            state.isLoading = loading
        case .setListData(let models):
            state.dataModels = models
            // 屏蔽
            let arr = UserManager.shared.getUserShieldContent(shieldType: .rescue_sh_page)
            state.dataModels = state.dataModels.filter { (model) -> Bool in
                !arr.contains(model.topic_id!)
            }
            let section = self.setupSection(data: state.dataModels)
            state.section = section
            
        case .setErrorMsg(let string):
            state.errorMsg = string
        case .setKeyword(let keyword):
            state.keyword = keyword
        case .empty:
            break
        case .setClearData:
            state.section = []
        case .setUpdateItem(let model):
            let datamodels = state.dataModels.map { (oriData) -> HomePageModel in
                var newData = oriData
                if newData.topic_id == model.topic_id {
                    newData.views_num = model.views_num
                    newData.liked = model.liked
                    newData.collectioned = model.collectioned
                    newData.likes_num = model.liked
                    newData.collection_num = model.collection_num
                    newData.commNum = model.commNum
                }
                return newData
            }
            state.dataModels = datamodels
            let section = self.setupSection(data: state.dataModels)
            state.section = section
            
        case .setLikedStatus(let success, let status,let model):
            if success {
                let datamodels = state.dataModels.map { (oriData) -> HomePageModel in
                    var newData = oriData
                    if newData.topic_id == model?.topic_id {
                        newData.liked = status?.like
                        if newData.liked == 1 {
                            newData.likes_num = (newData.likes_num ?? 0) + 1
                        }else{
                            if (newData.likes_num ?? 0) > 0 {
                                newData.likes_num = (newData.likes_num ?? 1) - 1
                            }
                        }
                    }
                    return newData
                }
                state.dataModels = datamodels
                let section = self.setupSection(data: state.dataModels)
                state.section = section
            }else{
                state.errorMsg = "点赞失败"
            }
        case .setCollectionStatus(let success, let status,let model):
            if success {
                let datamodels = state.dataModels.compactMap { (oriData) -> HomePageModel? in
                    var newData = oriData
                    if newData.topic_id == model?.topic_id {
                        newData.collectioned = status?.collection
                        if newData.collectioned == 1 {
                            newData.collection_num = (newData.collection_num ?? 0) + 1
                        }else{
                            if (newData.collection_num ?? 0) > 0 {
                                newData.collection_num = (newData.collection_num ?? 1) - 1
                            }
                        }
                    }
                    return newData
                }
                state.dataModels = datamodels
                let section = self.setupSection(data: state.dataModels)
                state.section = section
            }else{
                state.errorMsg = "点赞失败"
            }
            
        case .setShieldItem(let itemId):
            state.dataModels = state.dataModels.filter { (model) -> Bool in
                model.topic_id != itemId
            }
            let section = self.setupSection(data: state.dataModels)
            state.section = section
            
        }
        return state
    }
    
    func setupSection(data: [HomePageModel]) -> [HomePageSection] {
        let items = data.map { (model) -> HomePageItem in
            let reactor = HomePageItemReactor.init(model: model) { (index, data) in
                if index == 1 {
                    self.action.onNext(.clickLikeAction(data))
                }else if index == 2 {
                    self.action.onNext(.clickCollection(data))
                }
            }
            return HomePageItem.homepageItem(reactor)
        }
        let section = HomePageSection.sectionItem(items)
        return [section]
    }
    
    func likeTopicAction(model: HomePageModel) -> Observable<BaseModel<LikeStatusModel>?> {
        let like_mark = (model.liked == 1) ? 0 : 1
        return netWorking.request(.likeTopicAction(like_mark: like_mark, topicId: model.topic_id ?? 0)).mapData(LikeStatusModel.self)
    }
    
    func collectionTopic(model: HomePageModel) -> Observable<BaseModel<CollectionStatusModel>?> {
        let collect_mark = (model.collectioned == 1) ? 0 : 1
        return netWorking.request(.collectionAction(collect_mark: collect_mark, topicId: model.topic_id ?? 0)).mapData(CollectionStatusModel.self)
    }
}
