//
//  LoginApi.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/15.
//

import Foundation
import Moya

enum LoginApi {
    case login(phone: String?, email: String?,pswd: String)
    case register(phone: String?, email: String?,pswd: String,confirm: String)
    case confirmPhone(account: String)
    case updateAccount(phone: String?, email: String?,pswd: String,confirm: String)
}

extension LoginApi: BaseTargetType {
    
    var parameters: [String : Any] {
        var parameter: [String: Any] = APPConfig.apiBasicParameters()
        switch self {
        case .register(phone: let phone, email: let email, pswd: let pswd, confirm: let confrim):
            parameter["phoneNum"] = phone
            parameter["email"] = email
            parameter["password"] = pswd
            parameter["confirm_password"] = confrim
            parameter["phone_type"] = PhoneType.getDeviceModel()
        case .login(phone: let phone, email: let email, pswd: let pswd):
            parameter["phoneNum"] = phone
            parameter["email"] = email
            parameter["password"] = pswd
            parameter["phone_type"] = PhoneType.getDeviceModel()
        case .confirmPhone(account: let contact):
            parameter["phone_or_email"] = contact
            parameter["phone_type"] = PhoneType.getDeviceModel()
        case .updateAccount(phone: let phone, email: let email, pswd: let pswd, confirm: let confirm):
            parameter["phoneNum"] = phone
            parameter["email"] = email
            parameter["password"] = pswd
            parameter["confirm_password"] = confirm
        }
        return parameter
    }

    
    var path: String {
        switch self {
        case .login:
            return "/api/v1/login/"
        case .register:
            return "/api/v1/register/"
        case .confirmPhone:
            return "/api/v1/confirminfo/"
        case .updateAccount:
            return "/api/v1/updatepswd/"
        }
    }
    
    
}

