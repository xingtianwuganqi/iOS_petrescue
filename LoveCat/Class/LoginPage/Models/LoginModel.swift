//
//  LoginModel.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/16.
//

import Foundation
import HandyJSON

struct UserInfoModel: HandyJSON {
    var username: String?
    var avator: String?
    var token: String?
    var phone_number: String?
    var email: String?
    var create_time: String?
    var user_id: Int?
    var wx_id: String?
}
