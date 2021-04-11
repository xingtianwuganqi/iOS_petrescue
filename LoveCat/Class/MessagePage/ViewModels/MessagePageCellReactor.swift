//
//  MessagePageCellReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/3/22.
//

import Foundation
import RxSwift
import ReactorKit
final class MessagePageCellReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var isLoading: Bool = false
        var netError: Bool = false
        var model: MinePageCellModel?
    }
    
    var initialState: State = State()
    
    init(model: MinePageCellModel) {
        initialState.model = model
    }
    
}
