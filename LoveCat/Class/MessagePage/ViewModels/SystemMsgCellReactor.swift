//
//  SystemMsgCellReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/4/7.
//

import Foundation
import ReactorKit
final class SystemMsgCellReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var isLoading: Bool = false
        var model: SystemMsgModel?
    }
    
    var initialState: State = State()
    
    init(model: SystemMsgModel) {
        initialState.model = model
    }
    
}
