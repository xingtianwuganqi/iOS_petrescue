//
//  GambitViewReactor.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/30.
//

import Foundation
import RxSwift
import ReactorKit
final class GambitViewReactor: Reactor {
    
    enum Action {
        case loadData
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var isLoading: Bool = false
        var netError: Bool = false
    }
    
    var initialState: State = State()
    
}
