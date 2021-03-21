//
//  MyCollectionReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/6.
//

import Foundation
import RxSwift
import ReactorKit
import MJRefresh
final class MyCollectionReactor: Reactor {
    
    enum Action {
        case loadCollectionData(Paging)
        case cancelCollection(HomePageModel)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setCollectionData([HistoryModel],Paging)
        case setErrorMsg(String?)
        case setCancelSuccess(HomePageModel)
    }
    
    struct State {
        var isLoading: Bool = false
        var netError: Bool = false
        var errorMsg: String?
        var section: [HomePageSection] = []
        var endRefreshing: RefreshState?
        var page = 1
    }
    
    var initialState: State = State()
    var netWorking = NetWorking<MinePageApi>()
    var homeNetWork = NetWorking<HomePageApi>()
    func getCollectionList(page: Paging) -> Observable<BaseModel<HistoryModel>?> {
        switch page {
        case .refresh:
            initialState.page = 1
        default:
            initialState.page += 1
        }
        return netWorking.request(.authHistoryList(page: initialState.page, size: 10)).mapData(HistoryModel.self)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
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
        case .cancelCollection(let model):
            
            guard !self.currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.collectionTopic(model: model).map { (baseModel) -> Mutation in
                if baseModel?.isSuccess ?? false {
                    return Mutation.setCancelSuccess(model)
                }else{
                    return Mutation.setErrorMsg("取消收藏失败")
                }
            }
            return .concat([start,request,end])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.errorMsg = nil
        state.endRefreshing = nil
        switch mutation {
        case .setCollectionData(let models,let page):
            
            if page == .refresh {
                
                let items = models.filter({ (model) -> Bool in
                    model.topicInfo?.topic_id != nil
                }).map { (model) -> HomePageItem in
                    return HomePageItem.homepageItem(HomePageItemReactor.init(model: model.topicInfo ?? HomePageModel.init()))
                }
                let section = HomePageSection.sectionItem(items)
                state.section = [section]
            }else{
                if models.count == 0 {
                    state.page -= 1
                }
                
                let items = models.filter({ (model) -> Bool in
                    model.topicInfo?.topic_id != nil
                }).map { (model) -> HomePageItem in
                    return HomePageItem.homepageItem(HomePageItemReactor.init(model: model.topicInfo ?? HomePageModel.init()))
                }
                let newItems = (state.section.first?.items ?? []) + items
                let section = HomePageSection.sectionItem(newItems)
                state.section = [section]
            }
            state.endRefreshing = Tool.shared.getRefreshState(page: page, datas: models)

        case .setLoading(let loading):
            state.isLoading = loading
        case .setErrorMsg(let msg):
            state.errorMsg = msg
        case .setCancelSuccess(let model):
            let items = state.section.first?.items.compactMap({ (pageItem) -> HomePageItem? in
                switch pageItem {
                case .homepageItem(let reac):
                    if reac.currentState.model?.topic_id == model.topic_id {
                        return nil
                    }else{
                        return pageItem
                    }
                }
            })
            if let items = items {
                if items.count == 0 {
                    state.endRefreshing = .empty
                }
                state.section = [.sectionItem(items)]
            }
        }
        return state
    }
    
    func collectionTopic(model: HomePageModel) -> Observable<BaseModel<CollectionStatusModel>?> {
        let collect_mark = 0
        return homeNetWork.request(.collectionAction(collect_mark: collect_mark, topicId: model.topic_id ?? 0)).mapData(CollectionStatusModel.self)
    }
    
}
