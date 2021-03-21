//
//  TagsViewReactor.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/13.
//

import Foundation
import RxSwift
import ReactorKit
final class TagsViewReactor: Reactor {
    
    enum Action {
        case loadTagList
        case selectItem(Int)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setTagData([TagInfoModel])
        case setSelectItem(Int)
    }
    
    struct State {
        var isLoading: Bool = false
        var netCompletion: Bool = false
        var allItems: [TagInfoModel] = []
        var selectedItems: [TagInfoModel] = []
    }
    
    var initialState: State = State()
    var networking: NetWorking<HomePageApi> = NetWorking<HomePageApi>()
    
    init(normal: [TagInfoModel]) {
        initialState.selectedItems = normal
//        var items : [TagInfoModel] = []
//        for i in 0 ..< 10 {
//            let item = TagInfoModel(id: i, tag_name: "测试标签\(i)")
//            items.append(item)
//        }
//        items = items.map({ (model) -> TagInfoModel in
//            var newItem = model
//            if normal.contains(newItem) {
//                newItem.select = true
//            }
//            return newItem
//        })
//        self.initialState.selectedItems = normal
//        self.initialState.allItems = items
//        let values = initialState.allItems.map { (model) -> TagInfoItem in
//            return TagInfoItem.tagItem(TagInfoCellReactor.init(model: model))
//        }
//        let section = TagInfoSection.tagSection(values)
//        self.initialState.section = [section]
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadTagList:
            guard !self.currentState.isLoading else {
                return .empty()
            }
            
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.tagListNetWorking().map { (baseModel) -> Mutation in
                if baseModel?.isSuccess ?? false {
                    return Mutation.setTagData(baseModel?.dataArr ?? [])
                }else{
                    return Mutation.setTagData([])
                }
            }.catchErrorJustReturn(Mutation.setTagData([]))
            return .concat([start,request,end])
        case .selectItem(let index):
            return Observable.just(Mutation.setSelectItem(index))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setLoading(let loading):
            state.isLoading = loading
        case .setTagData(let models):
            state.netCompletion = true
            let items = models.map({ (model) -> TagInfoModel in
                var newItem = model
                if currentState.selectedItems.contains(newItem) {
                    newItem.select = true
                }
                return newItem
            })
            state.allItems = items
        case .setSelectItem(let index):
            state.allItems = state.allItems.enumerated().map { (row,model) -> TagInfoModel in
                var newData = model
                if index == row {
                    if newData.select == true {
                        newData.select = false
                    }else{
                        newData.select = true
                    }
                }
                return newData
            }
            state.selectedItems = state.allItems.filter({ (model) -> Bool in
                model.select
            })
        }
        return state
    }
    
    
    func tagListNetWorking() -> Observable<BaseModel<TagInfoModel>?> {
        return networking.request(.tagInfoList).mapData(TagInfoModel.self)
    }
}
