//
//  HomePageItemReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/1.
//

import Foundation
import ReactorKit

class HomePageItemReactor: Reactor {
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var model: HomePageModel?
        var clickBtnBlock:((Int,HomePageModel) -> Void)?
    }

    var initialState: State = State()
    
    init(model: HomePageModel,clickBtnBlock:((Int,HomePageModel) -> Void)? = nil) {
        initialState.model = model
        initialState.clickBtnBlock = clickBtnBlock
    }
    
}
