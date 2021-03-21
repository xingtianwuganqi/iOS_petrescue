//
//  SearchMainReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/4.
//

import Foundation
import RxSwift
import ReactorKit
final class SearchMainReactor: Reactor {
    
    enum Action {
        case showLabsView(Bool)
    }
    
    enum Mutation {
        case setShowLabsView(Bool)
    }
    
    struct State {
        var isLoading: Bool = false
        var netError: Bool = false
        var showLabs: Bool = true
    }
    
    var initialState: State = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .showLabsView(let show):
            return Observable.just(Mutation.setShowLabsView(show))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setShowLabsView(let show):
            state.showLabs = show
        }
        return state
    }
}
