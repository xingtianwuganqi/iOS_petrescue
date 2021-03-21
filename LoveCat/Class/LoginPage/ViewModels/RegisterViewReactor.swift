//
//  RegisterViewReactor.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/16.
//

import Foundation
import RxSwift
import ReactorKit
final class RegisterViewReactor: Reactor {
    
    enum Action {
        case loginAndRegister(phone: String?,email: String?, pswd: String,confrim: String)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setLoginState(Bool,UserInfoModel?)
        case empty
        case showErrorMsg(String?)
    }
    
    struct State {
        var isLoading: Bool = false
        var netError: Bool = false
        var isLogin: Bool = false
        var userInfo: UserInfoModel?
        var msg: String?
    }
    
    var initialState: State = State()
    let net = NetWorking<LoginApi>()

    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loginAndRegister(phone: let phone, email: let email, pswd: let pswd, confrim: let confrim):
            guard !self.currentState.isLoading else {
                return Observable.empty()
            }
            let loading = Observable.just(Mutation.setLoading(true))
            let netReq = self.netWorking(phone: phone, email: email, pswd: pswd, confirm: confrim).map { (model) -> Mutation in
                if model?.isSuccess == true {
                    return Mutation.setLoginState(true,model?.data)
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
            
        case .setLoginState(let isLogin,let userInfo):
            state.isLogin = isLogin
            state.userInfo = userInfo
        case .showErrorMsg(let msg):
            state.msg = msg
        case .empty:
            break
        }
        return state
    }
}
extension RegisterViewReactor {
    func netWorking(phone: String?, email: String?,pswd: String,confirm: String) -> Observable<BaseModel<UserInfoModel>?> {
        return net.request(.register(phone: phone, email: email, pswd: pswd.et.md5String, confirm: confirm.et.md5String)).mapData(UserInfoModel.self)
    }
}
