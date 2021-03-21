//
//  HomePageListReactor.swift
//  LoveCat
//
//  Created by jingjun on 2020/10/19.
//

import Foundation
import ReactorKit
import Moya
import MJRefresh
final class HomePageListReactor: Reactor {

    enum Action {
        case loadList(Paging)
        case clickLikeAction(HomePageModel)
        case clickCollection(HomePageModel)
        case updateItemModel(HomePageModel)
        case loadPubLishData(Paging)
        case loadCollectionData(Paging)
        case completeRescue(HomePageModel)
        case shieldItem(Int)
    }

    enum Mutation {
        case setLoading(Bool)
        case setRefreshing(Bool)
        case setListData([HomePageModel],Paging)
        case setErrorMsg(String?)
        case setLikedStatus(Bool,LikeStatusModel?,HomePageModel?)
        case setCollectionStatus(Bool,CollectionStatusModel?,HomePageModel?)
        case setUpdateItem(HomePageModel)
        case setPublishData([HomePageModel],Paging)
        case setCollectionData([CollectionModel],Paging)
        case updateComplete(HomePageModel)
        case setShieldItem(Int)
    }

    struct State {
        var isLoading: Bool = false
        var isRefreshing: Bool = false
        var dataModels: [HomePageModel] = []
        var section: [HomePageSection] = []
        var endRefreshing: RefreshState?
        var errorMsg: String?
        var page: Int = 1
        var pageType: HomePageType
    }
    
    var initialState: State = State(pageType: .homePageList)
    var netWorking = NetWorking<HomePageApi>()
    var authNetWorking = NetWorking<MinePageApi>()

    var page: Int = 1
    init(type: HomePageType) {
        self.initialState.pageType = type
    }

}
extension HomePageListReactor {
    func mutate(action: HomePageListReactor.Action) -> Observable<HomePageListReactor.Mutation> {
        switch action {
        case .loadList(let page):
            guard !self.currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.networkForList(page: page).map { (model) -> Mutation in
                guard let data = model?.dataArr,data.count > 0 else {
                    return Mutation.setListData([],page)
                }
                return Mutation.setListData(data,page)
            }.catchError { (error) -> Observable<Mutation> in
                return Observable.just(Mutation.setErrorMsg("网络错误"))
            }

            return Observable.concat(start,request,end)
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
        case .updateItemModel(let model):
            return Observable.just(Mutation.setUpdateItem(model))

        case .loadPubLishData(let page):
            guard !self.currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.getPublishList(page: page).map { (model) -> Mutation in
                if model?.isSuccess ?? false{
                    return Mutation.setPublishData(model?.dataArr ?? [],page) //model?.dataArr ??
                }else{
                    return Mutation.setPublishData([],page)
                }
            }.catchErrorJustReturn(Mutation.setPublishData([],page))
            
            return .concat([start,request,end])
            
        case .loadCollectionData(let page):
            guard !self.currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.getCollectionList(page: page).map { (model) -> Mutation in
                if model?.isSuccess ?? false{
                    return Mutation.setCollectionData(model?.dataArr ?? [],page)
                }else{
                    return Mutation.setCollectionData([],page)
                }
            }.catchError { (error) -> Observable<Mutation> in
                return Observable.just(Mutation.setCollectionData([],page))
            }
            
            return .concat([start,request,end])
            
        case .completeRescue(let model):
            guard !self.currentState.isRefreshing else {
                return .empty()
            }
            let start = Observable.just(Mutation.setRefreshing(true))
            let end = Observable.just(Mutation.setRefreshing(false))
            let request = self.completeRescueNetwoking(model: model).map { (baseModel) -> Mutation in
                if baseModel?.isSuccess ?? false {
                    return Mutation.updateComplete(model)
                }else{
                    return Mutation.setErrorMsg("修改失败")
                }
            }.catchErrorJustReturn(Mutation.setErrorMsg("修改失败"))
            return .concat(start,request,end)
        case .shieldItem(let item):
            return Observable.just(Mutation.setShieldItem(item))
        }
    }

    func reduce(state: HomePageListReactor.State, mutation: HomePageListReactor.Mutation) -> State {
        var state = state
        state.endRefreshing = nil
        switch mutation {
        case .setLoading(let loading):
            state.isLoading = loading
        case .setListData(let data,let page):
            if page == .refresh {
                state.dataModels = data
            }else{
                state.dataModels = state.dataModels + data
                if data.count == 0 {
                    state.page -= 1
                }
            }
            // 屏蔽
            let arr = UserManager.shared.getUserShieldContent(shieldType: .rescue_sh_page)
            state.dataModels = state.dataModels.filter { (model) -> Bool in
                !arr.contains(model.topic_id!)
            }
            state.endRefreshing = Tool.shared.getRefreshState(page: page, datas: data)
            let section = self.uploadSection(data: state.dataModels)
            state.section = section
            
        case .setErrorMsg(let msg):
            state.errorMsg = msg
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
                let section = self.uploadSection(data: state.dataModels)
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
                            if state.pageType == .authCollect {
                                return nil
                            }else{
                                if (newData.collection_num ?? 0) > 0 {
                                    newData.collection_num = (newData.collection_num ?? 1) - 1
                                }
                            }
                        }
                    }
                    return newData
                }
                state.dataModels = datamodels
                let section = self.uploadSection(data: state.dataModels)
                state.section = section
                if datamodels.count == 0 {
                    state.endRefreshing = .empty
                }
            }else{
                state.errorMsg = "点赞失败"
            }
        case .setUpdateItem(let model):
            let datamodels = state.dataModels.map { (oriData) -> HomePageModel in
                var newData = oriData
                if newData.topic_id == model.topic_id {
                    newData.liked = model.liked
                    newData.collectioned = model.collectioned
                    newData.views_num = model.views_num
                    newData.likes_num = model.likes_num
                    newData.collection_num = model.collection_num
                }
                return newData
            }
            state.dataModels = datamodels
            let section = self.uploadSection(data: state.dataModels)
            state.section = section
            
        case .setPublishData(let models,let page):
    
            if page == .refresh {
                state.dataModels = models
            }else{
                state.dataModels = state.dataModels + models
                if models.count == 0 {
                    state.page -= 1
                }
            }
            state.endRefreshing = Tool.shared.getRefreshState(page: page, datas: models)
            let section = self.uploadSection(data: state.dataModels)
            state.section = section
            
        case .setCollectionData(let models,let page):
            
            if page == .refresh {
                
                let data = models.compactMap { (model) -> HomePageModel? in
                    return model.topicInfo
                }
                state.dataModels = data
            }else{
                let data = models.compactMap { (model) -> HomePageModel? in
                    return model.topicInfo
                }
                state.dataModels = state.dataModels + data
                if models.count == 0 {
                    state.page -= 1
                }
            }
            state.endRefreshing = Tool.shared.getRefreshState(page: page, datas: models)
            let section = self.uploadSection(data: state.dataModels)
            state.section = section
            
        case .updateComplete(let data):
            let items = state.dataModels.map { (model) -> HomePageModel in
                if model.topic_id == data.topic_id {
                    var newModel = model
                    newModel.is_complete = 1
                    return newModel
                }else{
                    return model
                }
            }
            state.dataModels = items
            let section = self.uploadSection(data: state.dataModels)
            state.section = section
        case .setRefreshing(let refresh):
            state.isRefreshing = refresh
        case .setShieldItem(let itemId):
            state.dataModels = state.dataModels.filter { (model) -> Bool in
                model.topic_id != itemId
            }
            let section = self.uploadSection(data: state.dataModels)
            state.section = section
        }
        return state
    }
}
extension HomePageListReactor {
    func networkForList(page: Paging) -> Observable<BaseModel<HomePageModel>?> {
        switch page {
        case .refresh:
            self.initialState.page = 1
        case .next:
            self.initialState.page = self.initialState.page + 1
        }
        return netWorking.request(.homePageList(page: self.initialState.page
        )).mapData(HomePageModel.self)
    }
    
    func likeTopicAction(model: HomePageModel) -> Observable<BaseModel<LikeStatusModel>?> {
        let like_mark = (model.liked == 1) ? 0 : 1
        return netWorking.request(.likeTopicAction(like_mark: like_mark, topicId: model.topic_id ?? 0)).mapData(LikeStatusModel.self)
    }
    
    func collectionTopic(model: HomePageModel) -> Observable<BaseModel<CollectionStatusModel>?> {
        let collect_mark = (model.collectioned == 1) ? 0 : 1
        return netWorking.request(.collectionAction(collect_mark: collect_mark, topicId: model.topic_id ?? 0)).mapData(CollectionStatusModel.self)
    }
    
    func uploadSection(data: [HomePageModel]) -> [HomePageSection] {
        let items = data.map { (model) -> HomePageItem in
            let reactor  = HomePageItemReactor.init(model: model) { (index, data) in
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
    
    func getPublishList(page:Paging) -> Observable<BaseModel<HomePageModel>?> {
        switch page {
        case .refresh:
            initialState.page = 1
        default:
            initialState.page += 1
        }
        return authNetWorking.request(.publishList(page: initialState.page)).mapData(HomePageModel.self)
    }
    
    func getCollectionList(page: Paging) -> Observable<BaseModel<CollectionModel>?> {
        switch page {
        case .refresh:
            initialState.page = 1
        default:
            initialState.page += 1
        }
        return authNetWorking.request(.getCollectionList(page: initialState.page)).mapData(CollectionModel.self)
    }

    func completeRescueNetwoking(model: HomePageModel) -> Observable<BaseModel<EmptyModel>?> {
        guard let topic_id = model.topic_id else {
            return .empty()
        }
        return netWorking.request(.completeRescue(topicId: topic_id)).mapData(EmptyModel.self)
    }
}
