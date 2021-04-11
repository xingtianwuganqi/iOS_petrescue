//
//  MessageCommonCellReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/3/29.
//

import Foundation
import ReactorKit
final class MessageCommonCellReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var isLoading: Bool = false
        var netError: Bool = false
        var model: MessageListModel?
    }
    
    var initialState: State = State()
    init(model: MessageListModel) {
        self.initialState.model = model
    }
    
}
