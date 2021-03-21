//
//  AddressModel.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/24.
//

import Foundation
import HandyJSON
struct CountryModel: HandyJSON {
    var children : [ProvinceModel]?
    var id: String?
    var pid: String?
    var value: String?
}

struct ProvinceModel: HandyJSON {
    var children: [CityModel]?
    var id: String?
    var pid: String?
    var value: String?
    var isSelect: Bool = false
}

struct CityModel: HandyJSON {
    var children: [AreaModel]?
    var id: String?
    var pid: String?
    var value: String?
    var isSelect: Bool = false
}

struct AreaModel: HandyJSON {
    var id: String?
    var pid: String?
    var value: String?
    var isSelect: Bool = false
}
