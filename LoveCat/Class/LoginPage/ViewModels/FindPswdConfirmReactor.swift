//
//  FindPswdConfirmReactor.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/16.
//

import Foundation
import RxSwift
import ReactorKit
final class FindPswdConfirmReactor: Reactor {

    enum Action {
        case confirmPhone(phone: String)
    }

    enum Mutation {
        case setLoading(Bool)
        case setPhoneState(Bool)
        case setErrorMsg(String?)
    }

    struct State {
        var isLoading: Bool = false
        var phoneState: Bool = false
        var errorMsg: String?
    }

    var initialState: State = State()
    
    var netWorking: NetWorking<LoginApi>
    init() {
        self.netWorking = NetWorking<LoginApi>()
    }

}

extension FindPswdConfirmReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .confirmPhone(phone: let phone):
            let start = Observable.just(Mutation.setLoading(true))
            let netReq = netWorking(phone: phone).asObservable().map { (baseModel) -> Mutation in
                if baseModel?.isSuccess ?? false {
                    return Mutation.setPhoneState(baseModel?.isSuccess ?? false)
                }else{
                    return Mutation.setErrorMsg(baseModel?.message ?? "环境检测失败")
                }
            }.catchError { (error) -> Observable<Mutation> in
                print(error.localizedDescription)
                return Observable.empty()
            }

            let end = Observable.just(Mutation.setLoading(false))
            return Observable.concat([start,netReq,end])
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.errorMsg = nil
        switch mutation {
        case .setLoading(let loading):
            state.isLoading = loading
        case .setPhoneState(let phoneState):
            state.phoneState = phoneState
        case .setErrorMsg(let message):
            state.errorMsg = message
        }
        return state
    }
}

extension FindPswdConfirmReactor {
    func netWorking(phone: String) -> Observable<BaseModel<EmptyModel>?> {
        return netWorking.request(.confirmPhone(account: phone.et.md5String))
            .mapData(EmptyModel.self)
    }
    
 
}
    
//    func netWorking(phone: String) {
//        let net = NetWorking<LoginApi>()
//        _ = net.request(.confirmPhone(account: phone)).mapJSON()
//            .map { (result) -> BaseModel<EmptyModel>? in
//                return BaseApiFunc.parseResponse(EmptyModel.self, result)
//            }.subscribe { (json) in
//                print(json)
//            } onError: { (error) in
//                print(error.localizedDescription)
//            }
//
//    }
//}
