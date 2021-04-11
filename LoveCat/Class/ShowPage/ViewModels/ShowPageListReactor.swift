//
//  ShowPageListReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/18.
//

import Foundation
import RxSwift
import ReactorKit
import MJRefresh
final class ShowPageListReactor: Reactor {
    
    enum Action {
        case loadShowData(Paging)
        case openInstruction(ShowPageModel)
        case likedInfoAction(ShowPageModel)
        case collectionAction(ShowPageModel)
        case loadAuthPublish(Paging)
        case loadAuthCollection(Paging)
        case shieldItem(Int)
        case updateShowInfo(ShowPageModel)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setShowData([ShowPageModel],Paging)
        case changeOpenInstrct(ShowPageModel)
        case setLikedStatus(Bool,LikeStatusModel?,ShowPageModel?)
        case setCollectionStatus(Bool,CollectionStatusModel?,ShowPageModel?)
        case setAuthCollectionData([ShowCollectionModel],Paging)
        case setShieldItem(Int)
        case setUpdateItem(ShowPageModel)

    }
    
    struct State {
        var isLoading: Bool = false
        var netError: Bool = false
        var dataModels: [ShowPageModel] = []
        var section: [ShowPageListSection] = []
        var page: Int = 1
        var endRefreshing: RefreshState?
        var errorMsg: String?
        var pageType: ShowPageType
        var gambitId: Int? = nil
        var showId: Int? = nil
    }
    
    var initialState: State = State(pageType: .showInfoList)
    var networking: NetWorking<ShowPageApi> = NetWorking<ShowPageApi>()
    init(type: ShowPageType,gambit_id: Int? = nil,show_id: Int?) {
        self.initialState.pageType = type
        self.initialState.gambitId = gambit_id
        self.initialState.showId = show_id
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case.loadShowData(let page):
            guard !self.currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.showInfoListNetworking(page: page).map { (baseModel) -> Mutation in
                if baseModel?.isSuccess ?? false {
                    return Mutation.setShowData(baseModel?.dataArr ?? [], page)
                }else{
                    return Mutation.setShowData([], page)
                }
            }.catchErrorJustReturn(Mutation.setShowData([], page))
            return .concat([start,request,end])
        case .openInstruction(let model):
            return Observable.just(Mutation.changeOpenInstrct(model))
        case .likedInfoAction(let model):
            guard !self.currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.likeShowInfoNetworking(model: model).map { (baseModel) -> Mutation in
                if baseModel?.isSuccess ?? false {
                    return Mutation.setLikedStatus(true, baseModel?.data,model)
                }else{
                    return Mutation.setLikedStatus(false, nil,nil)
                }
            }
            return .concat([start,request,end])
        case .collectionAction(let model):
            guard !self.currentState.isLoading else {
                return .empty()
            }
            
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.collectionShowInfoNetworking(model: model).map { (baseModel) -> Mutation in
                if baseModel?.isSuccess ?? false {
                    return Mutation.setCollectionStatus(true, baseModel?.data,model)
                }else{
                    return Mutation.setCollectionStatus(false, baseModel?.data,model)
                }
            }
            return .concat([start,request,end])
        case .loadAuthPublish(let page):
            guard !self.currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.authPublishNetWorking(page: page).map { (baseModel) -> Mutation in
                if baseModel?.isSuccess ?? false {
                    return Mutation.setShowData(baseModel?.dataArr ?? [], page)
                }else{
                    return Mutation.setShowData([], page)
                }
            }
            return .concat([start,request,end])
        case .loadAuthCollection(let page):
            guard !self.currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.authCollectionNetWorking(page: page).map { (baseModel) -> Mutation in
                if baseModel?.isSuccess ?? false {
                    return Mutation.setAuthCollectionData(baseModel?.dataArr ?? [], page)
                }else{
                    return Mutation.setAuthCollectionData([], page)
                }
            }
            return .concat([start,request,end])
        case .shieldItem(let id):
            return .just(Mutation.setShieldItem(id))
            
        case .updateShowInfo(let model):
            return .just(Mutation.setUpdateItem(model))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.errorMsg = nil
        state.endRefreshing = nil
        switch mutation {
        case .setLoading(let loading):
            state.isLoading = loading
        case .changeOpenInstrct(let openModel):
            let items = state.dataModels.map { (model) -> ShowPageModel in
                var newModel = model
                if newModel == openModel {
                    newModel.open = !newModel.open
                }
                return newModel
            }
            state.dataModels = items
            let section = self.updateSection(items: state.dataModels)
            state.section = section
        case let .setShowData(data, page):

            if page == .refresh {
                state.dataModels = data
                
            }else{
                state.dataModels = state.dataModels + data
                if data.count == 0 {
                    state.page -= 1
                }
            }
            // 屏蔽
            let arr = UserManager.shared.getUserShieldContent(shieldType: .rescue_sh_page)
            state.dataModels = state.dataModels.filter { (model) -> Bool in
                !arr.contains(model.show_id!)
            }
            state.endRefreshing = Tool.shared.getRefreshState(page: page, datas: data)
            let section = self.updateSection(items: state.dataModels)
            state.section = section
            
        case .setLikedStatus(let success, let status,let model):
            if success {
                let datamodels = state.dataModels.map { (oriData) -> ShowPageModel in
                    var newData = oriData
                    if newData.show_id == model?.show_id {
                        newData.liked = status?.like
                        if newData.liked == 1 {
                            newData.likes_num = (newData.likes_num ?? 0) + 1
                        }else{
                            if (newData.likes_num ?? 0) > 0 {
                                newData.likes_num = (newData.likes_num ?? 1) - 1
                            }
                        }
                    }
                    return newData
                }
                state.dataModels = datamodels
                let section = self.updateSection(items: state.dataModels)
                state.section = section
            }else{
                state.errorMsg = "点赞失败"
            }
        case .setCollectionStatus(let success, let status,let model):
            if success {
                let datamodels = state.dataModels.compactMap { (oriData) -> ShowPageModel? in
                    var newData = oriData
                    if newData.show_id == model?.show_id {
                        newData.collectioned = status?.collection
                        
                        if newData.collectioned == 1 {
                            newData.collection_num = (newData.collection_num ?? 0) + 1
                        }else{
                            if state.pageType == .collectShowInfo {
                                return nil
                            }else{
                                if (newData.collection_num ?? 0) > 0 {
                                    newData.collection_num = (newData.collection_num ?? 1) - 1
                                }
                            }
                        }
                    }
                    return newData
                }
                state.dataModels = datamodels
                let section = self.updateSection(items: state.dataModels)
                state.section = section
                if datamodels.count == 0 {
                    state.endRefreshing = .empty
                }
            }else{
                state.errorMsg = "点赞失败"
            }
            
        case .setAuthCollectionData(let data, let page):
            
            if page == .refresh {
                let showModel = data.compactMap { (model) -> ShowPageModel? in
                    return model.showInfo
                }
                state.dataModels = showModel
                
            }else{
                
                let showModel = data.compactMap { (model) -> ShowPageModel? in
                    return model.showInfo
                }
                state.dataModels = state.dataModels + showModel
                if data.count == 0 {
                    state.page -= 1
                }
            
            }
            state.endRefreshing = Tool.shared.getRefreshState(page: page, datas: data)
            let section = self.updateSection(items: state.dataModels)
            state.section = section
            
        case .setShieldItem(let id):
            state.dataModels = state.dataModels.filter { (model) -> Bool in
                model.show_id != id
            }
            let section = self.updateSection(items: state.dataModels)
            state.section = section
            
        case .setUpdateItem(let model):
            let datamodels = state.dataModels.map { (oriData) -> ShowPageModel in
                var newData = oriData
                if newData.show_id == model.show_id {
                    newData.liked = model.liked
                    newData.collectioned = model.collectioned
                    newData.views_num = model.views_num
                    newData.likes_num = model.likes_num
                    newData.collection_num = model.collection_num
                    newData.commNum = model.commNum
                }
                return newData
            }
            state.dataModels = datamodels
            let section = self.updateSection(items: state.dataModels)
            state.section = section
        }
        return state
    }
}

extension ShowPageListReactor {
    
    func updateSection(items: [ShowPageModel]) -> [ShowPageListSection] {
        let itemInfo = items.map { (show) -> ShowPageListItem in
            return ShowPageListItem.showPageItem(ShowListCellReactor.init(model: show, openBlock: { model in
                guard let model = model else {
                    return
                }
                self.action.onNext(.openInstruction(model))
            }, likeOrCollection: { model,type in
                guard let model = model else {
                    return
                }
                if type == 1 {
                    self.action.onNext(.likedInfoAction(model))
                }else{
                    self.action.onNext(.collectionAction(model))
                }
            }))
        }
        let section = ShowPageListSection.showListSection(itemInfo)
        return [section]
    }
    
    func showInfoListNetworking(page: Paging) -> Observable<BaseModel<ShowPageModel>?> {
        switch page {
        case .refresh:
            self.initialState.page = 1
        case .next:
            self.initialState.page += 1
        }
        return self.networking.request(.showInfoList(page: initialState.page, gambit_id: self.initialState.gambitId,show_id: self.initialState.showId)).mapData(ShowPageModel.self)
    }
    
    func likeShowInfoNetworking(model: ShowPageModel) -> Observable<BaseModel<LikeStatusModel>?> {
        let like_mark = (model.liked == 1) ? 0 : 1
        return self.networking.request(.likeShowInfo(show_id: model.show_id ?? 0, like_mark: like_mark)).mapData(LikeStatusModel.self)
    }
    
    func collectionShowInfoNetworking(model: ShowPageModel) -> Observable<BaseModel<CollectionStatusModel>?> {
        let collect_mark = (model.collectioned == 1) ? 0 : 1
        return networking.request(.collectionShowInfo(showId: model.show_id ?? 0, collect_mark: collect_mark)).mapData(CollectionStatusModel.self)
    }
    
    func authPublishNetWorking(page:Paging) -> Observable<BaseModel<ShowPageModel>?> {
        switch page {
        case .refresh:
            self.initialState.page = 1
        case .next:
            self.initialState.page += 1
        }
        return networking.request(.authPublishShowinfo(page: initialState.page)).mapData(ShowPageModel.self)
    }
    
    func authCollectionNetWorking(page:Paging) -> Observable<BaseModel<ShowCollectionModel>?> {
        switch page {
        case .refresh:
            self.initialState.page = 1
        case .next:
            self.initialState.page += 1
        }
        return networking.request(.authCollectionShowInfo(page: initialState.page)).mapData(ShowCollectionModel.self)
    }
}
