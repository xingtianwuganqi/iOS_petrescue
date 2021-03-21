//
//  ShowListCellReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/18.
//

import Foundation
import RxSwift
import ReactorKit
final class ShowListCellReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var isLoading: Bool = false
        var netError: Bool = false
        var model: ShowPageModel?
        var openBlock: ((ShowPageModel?) -> Void)?
//        var turnPageBlock: ((ShowPageModel?,Int) -> Void)?
        var likeOrCollectionBlock: ((ShowPageModel?,Int) -> Void)?
    }
    
    var initialState: State = State()
    
    init(model: ShowPageModel?,openBlock: ((ShowPageModel?) -> Void)?,likeOrCollection: ((ShowPageModel?,Int) -> Void)?) {
        initialState.model = model
        initialState.openBlock = openBlock
        initialState.likeOrCollectionBlock = likeOrCollection
//        initialState.turnPageBlock = turnPage
    }
    
}