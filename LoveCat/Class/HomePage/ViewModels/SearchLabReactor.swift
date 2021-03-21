//
//  SearchLabReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/4.
//

import Foundation
import RxSwift
import ReactorKit
final class SearchLabReactor: Reactor {
    
    enum Action {
        case loadLabels
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setData([SearchKeysInfo])

    }
    
    struct State {
        var isLoading: Bool = false
        var netError: Bool = false
        var labsData: [SearchKeysInfo] = []
    }
    
    var initialState: State = State()
    let networking = NetWorking<HomePageApi>()
    init() {
        
    }
    func getSearchKeyWords() -> Observable<BaseModel<SearchKeysInfo>?> {
        return networking.request(.getSearchKeys).mapData(SearchKeysInfo.self)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadLabels:
            guard !self.currentState.isLoading else {
                return Observable.just(.setLoading(false))
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end   = Observable.just(Mutation.setLoading(false))
            
            let request = getSearchKeyWords().map { (model) -> Mutation in
                if let data = model?.dataArr {
                    return Mutation.setData(data)
                }else{
                    return Mutation.setData([])
                }
            }
            return .concat([start,request,end])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setLoading(let loading):
            state.isLoading = loading
        case .setData(let datas):
            state.labsData = datas
        }
        return state
    }
    
}
