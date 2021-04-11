//
//  SystemMessageReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/4/2.
//

import Foundation
import ReactorKit
final class SystemMessageReactor: Reactor {
    
    enum Action {
        case reloadData(Paging)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setData([SystemMsgModel],Paging)
    }
    
    struct State: StateProtocal {
        var isLoading: Bool = false
        var isRefreshing: Bool = false
        var netError: Bool = false
        var endRefreshing: RefreshState?
        var errorMsg: String?
        var dataModels: [SystemMsgModel] = []
        var section : [SystemMessageSection] = []
        var page: Int = 1

    }
    
    var initialState: State = State()
    lazy var networking: NetWorking = NetWorking<MessageApi>()
    init() {
        
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .reloadData(let page):
            guard !self.currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.dataNetworking().map { (baseModel) -> Mutation in
                if baseModel?.isSuccess ?? false {
                    return Mutation.setData(baseModel?.dataArr ?? [],page)
                }else{
                    return Mutation.setData([],page)
                }
            }.catchErrorJustReturn(Mutation.setData([], page))
            return .concat([start,request,end])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setLoading(let loading):
            state.isLoading = loading
        case .setData(let datas,let page):
            state.dataModels = datas
            if page == .refresh {
                state.dataModels = datas
            }else{
                state.dataModels = state.dataModels + datas
                if datas.count == 0 {
                    state.page -= 1
                }
            }
            state.section = self.updateSection(datas: state.dataModels)
            state.endRefreshing = Tool.shared.getRefreshState(page: page, datas: state.dataModels)
            
        }
        return state
    }
    
    
    func dataNetworking() -> Observable<BaseModel<SystemMsgModel>?> {
        
        return networking.request(.systemMessage).mapData(SystemMsgModel.self)
    }
    
    func updateSection(datas: [SystemMsgModel]) -> [SystemMessageSection] {
        let items = datas.map { (model) -> SystemMessageItem in
            return SystemMessageItem.sysItem(SystemMsgCellReactor(model: model))
        }
        return [SystemMessageSection.systemSection(items)]
    }
}

