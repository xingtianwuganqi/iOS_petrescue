//
//  MinePageApi.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/6.
//

import Foundation
import Moya
enum MinePageApi {
    case getCollectionList(page: Int)
    case publishList(page: Int)
    case uploadUserInfo(avator: String?,username: String)
    case suggestion(content: String,contact: String)
    case changePswd(originPswd: String,newPswd: String,confrimPswd: String)
    case authMessage(page: Int,size: Int = 10)
    case authUnReadNum
    case authHistoryList(page: Int,size: Int)
    case violationList
    case reportAction(report_type: Int,report_Id: Int,user_id: Int,violation_id: Int)
}

extension MinePageApi: BaseTargetType  {
    var path: String {
        switch self {
        case .getCollectionList:
            return "/api/v1/authcollection/"
        case .publishList:
            return "/api/v1/authpublishlist/"
        case .uploadUserInfo:
            return "/api/v1/updateuserinfo/"
        case .suggestion:
            return "/api/v1/suggestion/"
        case .changePswd:
            return "/api/v1/updatetokenpassword/"
        case .authMessage:
            return "/api/v1/authmessage/"
        case .authUnReadNum:
            return "/api/v1/authunreadnum/"
        case .authHistoryList:
            return "/api/v1/authhistorylist/"
        case .violationList:
            return "/api/v1/violations/"
        case .reportAction:
            return "/api/v1/report/"
        }
    }
    
    var parameters: [String : Any] {
        var dic : [String: Any] = APPConfig.apiBasicParameters()
        switch self {
        case .getCollectionList(page: let page), .publishList(page: let page):
            dic["token"] = UserManager.shared.token
            dic["page"] = page
            dic["size"] = 10
        case .uploadUserInfo(avator: let avator, username: let username):
            dic["token"] = UserManager.shared.token
            dic["username"] = username
            dic["avator"] = avator
        case .suggestion(content: let content, contact: let contact):
            dic["token"] = UserManager.shared.token
            dic["content"] = content
            dic["contact"] = contact
        case .changePswd(originPswd: let origin, newPswd: let newPswd, confrimPswd: let confirm):
            dic["token"] = UserManager.shared.token
            dic["origin_pswd"] = origin
            dic["password"] = newPswd
            dic["confirm_pswd"] = confirm
        case .authMessage(page: let page, size: let size):
            dic["token"] = UserManager.shared.token
            dic["page"] = page
            dic["size"] = size
        case .authUnReadNum:
            dic["token"] = UserManager.shared.token
        case .authHistoryList(page: let page, size: let size):
            dic["token"] = UserManager.shared.token
            dic["page"] = page
            dic["size"] = size
        case .violationList:
            break
        case .reportAction(report_type: let report_type, report_Id: let report_id, user_id: let user_id, violation_id: let violation_id):
            dic["report_type"] = report_type
            dic["report_id"] = report_id
            dic["user_id"] = user_id
            dic["violation_id"] = violation_id
        }
        return dic
    }
}
