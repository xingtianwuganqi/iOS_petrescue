//
//  ReportReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/3/15.
//

import Foundation
import ReactorKit
final class ReportReactor: Reactor {
    
    enum Action {
        case loadData
        case uploadData(model: ViolationModel)
        case reportAction(user_id: Int,violation_id: Int)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setRefreshing(Bool)
        case setData([ViolationModel])
        case setUploadData(model: ViolationModel)
        case reportSuccess(Bool)
        
    }
    
    struct State {
        var isLoading: Bool = false
        var netError: Bool = false
        var isRefreshing: Bool = false
        var report_type: Int?
        var report_id: Int?
        var dataModel: [ViolationModel] = []
        var dataSource: [ViolationListSection] = []
        var changeResult: Bool?
    }
    
    var initialState: State = State()
    lazy var netWorking = NetWorking<MinePageApi>()
    init(report_Type: Report_type,report_Id: Int) {
        initialState.report_type = report_Type.rawValue
        initialState.report_id = report_Id
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadData:
            guard !self.currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.loadViolations().map { (baseModel) -> Mutation in
                if baseModel?.isSuccess ?? false {
                    return Mutation.setData(baseModel?.dataArr ?? [])
                }else{
                    return Mutation.setData([])
                }
            }
            return .concat([start,request,end])
            
        case .uploadData(model: let model):
            return .just(Mutation.setUploadData(model: model))
            
        case .reportAction(user_id: let user_id,violation_id: let violationId):
            guard !self.currentState.isRefreshing else {
                return .empty()
            }
            guard let report_type = currentState.report_type else {
                return .empty()
            }
            guard let report_id = currentState.report_id else {
                return .empty()
            }
            let start = Observable.just(Mutation.setRefreshing(true))
            let end = Observable.just(Mutation.setRefreshing(false))
            let request = self.reportNetworking(report_type: report_type, report_Id: report_id, user_id: user_id, violation_id: violationId).map { (baseModel) -> Mutation in
                return Mutation.reportSuccess(baseModel?.isSuccess ?? false)
            }
            return .concat(start,request,end)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setLoading(let loading):
            state.isLoading = loading
        case .setData(let models):
            state.dataModel = models
            state.dataSource = self.updateModels(models: models)
            
        case .setUploadData(model: let changeModel):
            state.dataModel = state.dataModel.map({ (model) -> ViolationModel in
                var newModel = model
                if changeModel.id == newModel.id {
                    newModel.selected = true
                }else{
                    newModel.selected = false
                }
                return newModel
            })
            state.dataSource = self.updateModels(models: state.dataModel)
        case .reportSuccess(let success):
            state.changeResult = success
        case .setRefreshing(let refreshing):
            state.isRefreshing = refreshing
        }
        return state
    }
}

extension ReportReactor {
    
    func updateModels(models: [ViolationModel]) -> [ViolationListSection]{
        let items = models.map { (model) -> ViolationListItem in
            return ViolationListItem.violationItem(ViolationCellReactor.init(model: model))
        }
        let section = ViolationListSection.violationListItems(items)
        return [section]
    }
    
    func loadViolations() -> Observable<BaseModel<ViolationModel>?> {
        return netWorking.request(.violationList).mapData(ViolationModel.self)
    }
    
    func reportNetworking(report_type: Int, report_Id: Int, user_id: Int, violation_id: Int) -> Observable<BaseModel<EmptyModel>?> {
        return netWorking.request(.reportAction(report_type: report_type, report_Id: report_Id, user_id: user_id, violation_id: violation_id)).mapData(EmptyModel.self)
    }
}

final class ViolationCellReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var isLoading: Bool = false
        var netError: Bool = false
        var model: ViolationModel?
    }
    
    var initialState: State = State()
    
    init(model: ViolationModel?)
    {
        initialState.model = model
    }
    
}
