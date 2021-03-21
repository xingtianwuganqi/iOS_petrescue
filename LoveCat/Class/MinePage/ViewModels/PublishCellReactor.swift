//
//  PublishCellReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/10.
//

import Foundation
import ReactorKit
final class PublishCellReactor: Reactor {
    
    enum Action {

    }
    
    enum Mutation {
        
    }
    
    struct State {
        var model: HomePageModel?
    }
    
    var initialState: State = State()
    
    init(model:HomePageModel?) {
        self.initialState.model = model
    }
    
}
