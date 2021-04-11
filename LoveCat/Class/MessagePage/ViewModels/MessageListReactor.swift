//
//  MessageListReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/3/29.
//

import Foundation
import ReactorKit
final class MessageListReactor: Reactor {
    
    enum Action {
        case reloadData(page: Paging)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setData([MessageListModel],Paging)
    }
    
    struct State: StateProtocal {
        var isLoading: Bool = false
        var isRefreshing: Bool = false
        var netError: Bool = false
        var endRefreshing: RefreshState?
        var errorMsg: String?
        var dataModels: [MessageListModel] = []
        var section : [MessageCommonSection] = []
        var msgType: MsgType?
        var page: Int = 1
    }
    
    var initialState: State = State()
    lazy var networking: NetWorking = NetWorking<MessageApi>()
    init(msgType: MsgType) {
        self.initialState.msgType = msgType
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .reloadData(page: let page):
            guard !self.currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.dataNetworking(page: page).map { (baseModel) -> Mutation in
                if baseModel?.isSuccess ?? false {
                    return Mutation.setData(baseModel?.dataArr ?? [], page)
                }else{
                    return Mutation.setData([], page)
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

        case .setData(let models,let page):
            if page == .refresh {
                state.dataModels = models
            }else{
                if models.count == 0 {
                    state.page -= 1
                }
                state.dataModels += models
            }
            state.section = self.updateSection(model: state.dataModels)
            state.endRefreshing = Tool.shared.getRefreshState(page: page, datas: models)
        }
        return state
    }
    
    
    func dataNetworking(page:Paging) -> Observable<BaseModel<MessageListModel>?> {
        switch page {
        case .refresh:
            self.initialState.page = 1
        default:
            self.initialState.page += 1
        }
        return networking.request(.authMessage(msg_type: currentState.msgType?.rawValue ?? 0, page: currentState.page)).mapData(MessageListModel.self)
    }
    
    func updateSection(model: [MessageListModel]) -> [MessageCommonSection] {
        let items = model.map({ (model) -> MessageCommonItems in
            let cellReactor = MessageCommonCellReactor.init(model: model)
            let datas = MessageCommonItems.CommonItem(cellReactor)
            return datas
        })
        let section: [MessageCommonSection] = [MessageCommonSection.msgCommonItem(items)]
        return section
    }
}
