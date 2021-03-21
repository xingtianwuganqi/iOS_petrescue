//
//  AuthMsgCellReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/2/3.
//

import Foundation
import RxSwift
import ReactorKit
final class AuthMsgCellReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var isLoading: Bool = false
        var netError: Bool = false
        var model: MessageInfoModel?
    }
    
    var initialState: State = State()
    
    init(model: MessageInfoModel?) {
        initialState.model = model
    }
    
}
