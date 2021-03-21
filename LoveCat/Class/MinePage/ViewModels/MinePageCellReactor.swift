//
//  MinePageCellReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/6.
//

import Foundation
import RxSwift
import ReactorKit
final class MinePageCellReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var model: MinePageCellModel
    }
    var initialState: State
    
    init(model: MinePageCellModel) {
        initialState = State.init(model: model)
    }
}
