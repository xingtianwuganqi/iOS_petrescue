//
//  CityCellReactor.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/24.
//

import Foundation
import RxSwift
import ReactorKit

final class ProvinceReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var provinceModel: ProvinceModel?
    }
    
    var initialState: State = State()
    
    init(model: ProvinceModel) {
        initialState.provinceModel = model
    }
    
}

final class CityCellReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var cityModel: CityModel?
    }
    
    var initialState: State = State()
    
    init(model: CityModel) {
        initialState.cityModel = model
    }
    
}

final class AreaReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var areaModel: AreaModel?
    }
    
    var initialState: State = State()
    
    init(model: AreaModel) {
        initialState.areaModel = model
    }
    
}
