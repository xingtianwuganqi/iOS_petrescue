//
//  MyPublishReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/6.
//

import Foundation
import ReactorKit
import MJRefresh
final class MyPublishReactor: Reactor {
    
    enum Action {
        case loadPubLishData(Paging)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setPublishData([HomePageModel],Paging)
        case setErrorMsg(String?)
    }
    
    struct State {
        var isLoading: Bool = false
        var netError: Bool = false
        var errorMsg: String?
        var section: [HomePageSection] = []
        var page: Int = 1
        var endRefreshing: RefreshState?
    }
    
    var initialState: State = State()
    var netWorking = NetWorking<MinePageApi>()
    
    func getCollectionList(page:Paging) -> Observable<BaseModel<HomePageModel>?> {
        switch page {
        case .refresh:
            initialState.page = 1
        default:
            initialState.page += 1
        }
        return netWorking.request(.publishList(page: initialState.page)).mapData(HomePageModel.self)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadPubLishData(let page):
            guard !self.currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.getCollectionList(page: page).map { (model) -> Mutation in
                if model?.isSuccess ?? false{
                    return Mutation.setPublishData(model?.dataArr ?? [],page) //model?.dataArr ??
                }else{
                    return Mutation.setPublishData([],page)
                }
            }.catchErrorJustReturn(Mutation.setPublishData([],page))
            
            return .concat([start,request,end])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.errorMsg = nil
        state.endRefreshing = nil
        switch mutation {
        case .setPublishData(let models,let page):
    
            if page == .refresh {
                let items = models.map { (model) -> HomePageItem in
                    return HomePageItem.homepageItem(HomePageItemReactor(model: model))
                }
                let section = HomePageSection.sectionItem(items)
                state.section = [section]
                
            }else{
                if models.count == 0 {
                    state.page -= 1
                }
            
                let items = models.map { (model) -> HomePageItem in
                    return HomePageItem.homepageItem(HomePageItemReactor(model: model))
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
        }
        return state
    }
    
}
