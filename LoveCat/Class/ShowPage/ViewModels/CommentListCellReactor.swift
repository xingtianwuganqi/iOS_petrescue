//
//  CommentListCellReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/29.
//

import Foundation
import RxSwift
import ReactorKit
final class CommentListCellReactor: Reactor {
    
    enum Action {
       
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var isLoading: Bool = false
        var netError: Bool = false
        var model: CommentListModel?
    }
    
    var initialState: State = State()

    init(model: CommentListModel) {
        self.initialState.model = model
    }

    
}
final class ReplyListCellReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var isLoading: Bool = false
        var netError: Bool = false
        var model: ReplyListModel?
    }
    
    var initialState: State = State()
    
    init(model: ReplyListModel) {
        self.initialState.model = model
    }
    
}
