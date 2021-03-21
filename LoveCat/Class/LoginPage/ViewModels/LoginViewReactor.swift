//
//  LoginViewReactor.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/15.
//

import Foundation
import ReactorKit
import RxSwift

class LoginViewReactor: Reactor {
    enum Action {
        case loginAction(phone: String?,email: String?, pswd: String)
    }
    
    enum Mutation {
        case empty
        case setLoading(Bool)
        case setLoginState(Bool,UserInfoModel?)
        case showErrorMsg(String?)
    }
    
    struct State {
        var isLoading: Bool = false
        var isLogin: Bool = false
        var userInfo: UserInfoModel?
        var msg: String?
    }
    
    var initialState: State
    let net = NetWorking<LoginApi>()
    init() {
        self.initialState = State()
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loginAction(phone: let phone, email: let email, pswd: let pswd):
            guard !self.currentState.isLoading else {
                return Observable.empty()
            }
            let loading = Observable.just(Mutation.setLoading(true))
            let netReq = self.netWorking(phone: phone, email: email, pswd: pswd).map { (model) -> Mutation in
                if model?.isSuccess == true {
                    return Mutation.setLoginState(true, model?.data)
                }else{
                    return Mutation.showErrorMsg(model?.message)
                }
            }.catchError { (error) -> Observable<Mutation> in
                return Observable.just(Mutation.showErrorMsg("网络错误"))
            }
            let endLoading = Observable.just(Mutation.setLoading(false))
            return Observable.concat([loading,netReq,endLoading])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.msg = nil
        switch mutation {
        case .setLoading(let loading):
            state.isLoading = loading
            
        case .setLoginState(let loginState,let userInfo):
            state.userInfo = userInfo
            state.isLogin = loginState
        case .showErrorMsg(let msg):
            state.msg = msg
        case .empty:
            break
        }
        return state
    }
}

extension LoginViewReactor {
    func netWorking(phone: String?, email: String?,pswd: String) -> Observable<BaseModel<UserInfoModel>?> {
        let obj = net.request(.login(phone: phone, email: email, pswd: pswd.et.md5String))
        return obj.mapData(UserInfoModel.self)
    }
}
