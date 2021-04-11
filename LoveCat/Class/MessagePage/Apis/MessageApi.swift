//
//  MessageApi.swift
//  LoveCat
//
//  Created by jingjun on 2021/3/28.
//

import Foundation
import Moya
enum MessageApi {
    case authUnReadNum
    case authMessage(msg_type: Int,page: Int,size: Int = 10)
    case systemMessage
}

extension MessageApi: BaseTargetType  {
    var path: String {
        switch self {
        case .authUnReadNum:
            return "/api/v1/authunreadnum/"
        case .authMessage:
            return "/api/v1/authmessage/"
        case .systemMessage:
            return "/api/v1/systemnotification/"
        }
    }
    
    var parameters: [String : Any] {
        var dic : [String: Any] = APPConfig.apiBasicParameters()
        switch self {
        case .authUnReadNum:
            dic["token"] = UserManager.shared.token
        case .authMessage(msg_type: let msgType,page: let page, size: let size):
            dic["token"] = UserManager.shared.token
            dic["page"] = page
            dic["size"] = size
            dic["msg_type"] = msgType
        case .systemMessage:
            break;
        }
        return dic
    }
}
