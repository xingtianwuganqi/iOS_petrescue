//
//  GambitListReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/18.
//

import Foundation
import RxSwift
import ReactorKit
final class GambitListReactor: Reactor {
    
    enum Action {
        case loadData(Paging)
        case selected(GambitListModel?)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setGambitList([GambitListModel])
        case setSelected(GambitListModel?)
    }
    
    struct State {
        var isLoading: Bool = false
        var netError: Bool = false
        var dataModels: [GambitListModel] = []
        var section: [GambitListSection] = []
        var selectedModel: GambitListModel?
        var endRefreshing: RefreshState?
    }
    
    var initialState: State = State()
    lazy var netWorking = NetWorking<ShowPageApi>()
    init(normal: GambitListModel?) {
        initialState.selectedModel = normal
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case.loadData:
            guard !self.currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.gambitListNetWoking().map { (baseModel) -> Mutation in
                if baseModel?.isSuccess ?? false {
                    return Mutation.setGambitList(baseModel?.dataArr ?? [])
                }else{
                    return Mutation.setGambitList([])
                }
            }.catchErrorJustReturn(Mutation.setGambitList([]))
            return .concat([start,request,end])
        case .selected(let model):
            return Observable.just(Mutation.setSelected(model))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.endRefreshing = nil
        switch mutation {
        case .setGambitList(let items):
            
            let newItems = items.map { (model) -> GambitListModel in
                var newModel = model
                if newModel == state.selectedModel {
                    newModel.selected = true
                }
                return newModel
            }
            state.dataModels = newItems
            let infos = newItems.map { (model) -> GambitListItem in
                return GambitListItem.gambitItem(model)
            }
            let section = GambitListSection.gambitSection(infos)
            state.section = [section]
            state.endRefreshing = .empty
        case .setSelected(let selectModel):
            state.selectedModel = selectModel
            let items = self.currentState.dataModels.map { (model) -> GambitListModel in
                var newModel = model
                if newModel == selectModel {
                    newModel.selected = true
                }else{
                    newModel.selected = false
                }
                return newModel
            }
            state.dataModels = items
            let info = state.dataModels.map { (model) -> GambitListItem in
                return GambitListItem.gambitItem(model)
            }
            let section = GambitListSection.gambitSection(info)
            state.section = [section]
        case .setLoading(let loading):
            state.isLoading = loading
        }
        return state
    }
}
extension GambitListReactor {
    func gambitListNetWoking() -> Observable<BaseModel<GambitListModel>?> {
        return self.netWorking.request(.gambitList).mapData(GambitListModel.self)
    }
}
