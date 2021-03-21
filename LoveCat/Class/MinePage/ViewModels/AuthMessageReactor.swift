//
//  AuthMessageReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/2/3.
//

import Foundation
import ReactorKit
final class AuthMessageReactor: Reactor {
    
    enum Action {
        case loadData(Paging)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setMessageData([MessageInfoModel],Paging)
    }
    
    struct State {
        var isLoading: Bool = false
        var netError: Bool = false
        var dataModels: [MessageInfoModel] = []
        var section: [MessageListSection] = []
        var endRefreshing: RefreshState = .empty
        var page: Int = 1
    }
    
    var initialState: State = State()
    lazy var netWorking = NetWorking<MinePageApi>()
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadData(let page):
            guard !self.currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.messageListNetworking(page: page).map { (baseModel) -> Mutation in
                if baseModel?.isSuccess ?? false {
                    return Mutation.setMessageData(baseModel?.dataArr ?? [], page)
                }else{
                    return Mutation.setMessageData([], page)
                }
            }
            return .concat([start,request,end])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setLoading(let loading):
            state.isLoading = loading
        case let .setMessageData(datas, page):
            if page == .refresh {
                state.dataModels = datas
            }else{
                state.dataModels += datas
                if datas.count == 0 {
                    state.page -= 1
                }
            }
            state.section = self.updateSection(models: state.dataModels)
            state.endRefreshing = Tool.shared.getRefreshState(page: page, datas: datas)

        }
        return state
    }
    
}
extension AuthMessageReactor {
    
    func updateSection(models: [MessageInfoModel]) -> [MessageListSection] {
        let items = models.compactMap { (model) -> MessageListItem? in
            return MessageListItem.messageItem(AuthMsgCellReactor.init(model: model))
        }
        let section = MessageListSection.messageListItems(items)
        return [section]
    }
    
    func messageListNetworking(page: Paging) -> Observable<BaseModel<MessageInfoModel>?> {
        switch page {
        case .refresh:
            self.initialState.page = 1
        default:
            self.initialState.page += 1
        }
        return netWorking.request(.authMessage(page: initialState.page)).mapData(MessageInfoModel.self)
    }
}
