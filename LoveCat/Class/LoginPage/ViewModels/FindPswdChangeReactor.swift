//
//  FindPswdChangeReactor.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/16.
//

import Foundation
import ReactorKit
final class FindPswdChangeReactor: Reactor {
    
    enum Action {
        case changePswd(phone: String?,email: String?, pswd: String,confrim: String)
    }
    
    enum Mutation {
        case empty
        case setLoading(Bool)
        case setChangeState(Bool)
    }
    
    struct State {
        var isLoading: Bool = false
        var netError: Bool = false
        var account: String
    }
    
    var initialState: State
    
    init(account: String) {
        self.initialState = State.init(account: account)
    }
}
