//
//  CityViewReactor.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/24.
//

import Foundation
import RxSwift
import ReactorKit
import SectionReactor
import Differentiator
import HandyJSON

final class CityViewReactor: Reactor {
    
    enum Action {
        case changeProvinceInfo(ProvinceModel)
        case changeCityInfo(CityModel)
        case changeAreaInfo(AreaModel)
        
    }
    
    enum Mutation {
        case setProvinceInfo(ProvinceModel)
        case setCityInfo(CityModel)
        case setAreaInfo(AreaModel)
    }
    
    struct State {
        var addressModel: [ProvinceModel] = []
        var currentCity: [CityModel] = []
        var currentArea: [AreaModel] = []
        var section : [CitySection] = []
        var citySection: [CitySection] = []
        var areaSection: [CitySection] = []
        
        var provinceItem: ProvinceModel?
        var cityItem: CityModel?
        var areaItem: AreaModel?
    }
    
    var initialState: State = State()
    
    init() {
        guard let models = self.readLocationData()?.children else {
            return
        }
        self.initialState.addressModel = models
        let cellReactor = models.map({ (model) -> CitySectionItem in
            let reactor = ProvinceReactor.init(model: model)
            return CitySectionItem.provinceItem(reactor)
        })
        
//        let cityReactor = models.children?.first?.children?.map({ (model) -> CitySectionItem in
//            let reactor = CityCellReactor.init(model: model)
//            return CitySectionItem.cityItem(reactor)
//        })
//
//        let areaReactor = models.children?.first?.children?.first?.children?.map({ (area) -> CitySectionItem in
//            let reactor = AreaReactor.init(model: area)
//            return CitySectionItem.areaItem(reactor)
//        })
        
        self.initialState.section = [.citySection(cellReactor)]
//        self.initialState.citySection = [.citySection(cityReactor!)]
//        self.initialState.areaSection = [.citySection(areaReactor!)]
    }
    
    func readLocationData() -> CountryModel? {
        let path = Bundle.main.path(forResource: "location", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        do {
            let data = try Data(contentsOf: url)
            let jsonData:Any = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            let jsonDic = jsonData as! Dictionary<String,Any>
            let model = JSONDeserializer<CountryModel>.deserializeFrom(dict: jsonDic)
            return model
        } catch let error as Error? {
            print("读取本地数据出现错误!",error.debugDescription)
            return nil
        }
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .changeProvinceInfo(let provinces):
            return Observable.just(Mutation.setProvinceInfo(provinces))
        case.changeCityInfo(let city):
            return Observable.just(Mutation.setCityInfo(city))
        case .changeAreaInfo(let area):
            return Observable.just(Mutation.setAreaInfo(area))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setProvinceInfo(let provinceInfo):
            state.provinceItem = provinceInfo
            var cityArr: [CityModel]?
            let items = currentState.addressModel.map { (province) -> CitySectionItem in
                var newProvince = province
                if provinceInfo.value == newProvince.value {
                    newProvince.isSelect = true
                    cityArr = newProvince.children
                }else{
                    newProvince.isSelect = false
                }
                
                return .provinceItem(ProvinceReactor.init(model: newProvince))
            }
            state.section = [.citySection(items)]
            if let citys = cityArr {
                let items = citys.map({ (city) -> CitySectionItem in
                    var newCity = city
                    newCity.isSelect = false
                    return .cityItem(CityCellReactor.init(model: city))
                })
                state.citySection = [.citySection(items)]
                state.currentCity = citys
                state.cityItem = nil
                state.areaItem = nil
            }
        case .setCityInfo(let cityInfo):
            state.cityItem = cityInfo
            var areaArr: [AreaModel]?
            let items = state.currentCity.map({ (city) -> CitySectionItem in
                var newCity = city
                if newCity.value == cityInfo.value {
                    newCity.isSelect = true
                    areaArr = newCity.children
                }else{
                    newCity.isSelect = false
                }
                
                return .cityItem(CityCellReactor.init(model: newCity))
            })
            state.citySection = [.citySection(items)]
            if let areas = areaArr {
                let items = areas.map { (area) -> CitySectionItem in
                    return .areaItem(AreaReactor.init(model: area))
                }
                state.areaSection = [.citySection(items)]
                state.currentArea = areas
                state.areaItem = nil
            }
        case .setAreaInfo(let areaInfo):
            state.areaItem = areaInfo
            let items = state.currentArea.map { (area) -> CitySectionItem in
                var newArea = area
                if newArea.value == areaInfo.value {
                    newArea.isSelect = true
                }else{
                    newArea.isSelect = false
                }
                
                return .areaItem(AreaReactor.init(model: newArea))
            }
            state.areaSection = [.citySection(items)]
        }
        return state
    }
}



enum CitySection {
    case citySection([CitySectionItem])
}

enum CitySectionItem {
    case provinceItem(ProvinceReactor)
    case cityItem(CityCellReactor)
    case areaItem(AreaReactor)
}

extension CitySection: SectionModelType {

    var items: [CitySectionItem] {
        switch self {
        case .citySection(let items):
            return items
        }
    }
    
    init(original: CitySection, items: [CitySectionItem]) {
        switch original {
        case .citySection:
            self = .citySection(items)
        }
    }
}
