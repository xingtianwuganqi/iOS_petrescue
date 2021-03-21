//
//  HomePageApi.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/23.
//

import Foundation
import Moya

enum HomePageApi {
    case getUploadToken
    case releaseTopic(content: String,imgs: String,address: String,contact: String,tags: String?)
    case homePageList(page: Int)
    case beginSearch(keyWord: String)
    case getSearchKeys
    case likeTopicAction(like_mark: Int,topicId: Int)
    case collectionAction(collect_mark: Int,topicId: Int)
    case topicDetail(topicID: Int)
    case tagInfoList
    case getContact(topicId: Int)
    case completeRescue(topicId: Int)
    case addViewHistory(topicId: Int)
}

extension HomePageApi: BaseTargetType {
    
    var parameters: [String : Any] {
        var parameter: [String: Any] = APPConfig.apiBasicParameters()
        switch self {
        case .getUploadToken:
            parameter["token"] = UserManager.shared.token
        case .releaseTopic(content: let content, imgs: let imgs, address: let address, contact: let contact,tags: let tags):
            parameter["content"] = content
            parameter["imgs"] = imgs
            parameter["address_info"] = address
            parameter["contact"] = contact
            parameter["token"] = UserManager.shared.token
            parameter["tags"] = tags
        case .homePageList(page: let page):
            parameter["token"] = UserManager.shared.token
            parameter["page"] = page
            parameter["size"] = 10
        case .beginSearch(keyWord: let keyword):
            parameter["keyword"] = keyword
            parameter["token"] = UserManager.shared.token
            parameter["page"] = 1
            parameter["size"] = 10
        case .getSearchKeys:
            break
        case .likeTopicAction(like_mark: let like_mark, topicId: let topicId):
            parameter["token"] = UserManager.shared.token
            parameter["like_mark"] = like_mark
            parameter["topic_id"] = topicId
        case .collectionAction(collect_mark: let collect_mark, topicId: let topicId):
            parameter["token"] = UserManager.shared.token
            parameter["collect_mark"] = collect_mark
            parameter["topic_id"] = topicId
        case .topicDetail(topicID: let topic_id):
            parameter["topic_id"] = topic_id
            parameter["token"] = UserManager.shared.token
        case .tagInfoList:
            break
        case .getContact(topicId: let topicId):
            parameter["token"] = UserManager.shared.token
            parameter["topic_id"] = topicId
        case .completeRescue(topicId: let topicId):
            parameter["token"] = UserManager.shared.token
            parameter["topic_id"] = topicId
        case .addViewHistory(topicId: let topicId):
            parameter["token"] = UserManager.shared.token
            parameter["topic_id"] = topicId
        }
        return parameter
    }
    
    var method: Moya.Method {
        switch self {
        case .getSearchKeys:
            return .get
        default:
            return .post
        }
    }
        
    var path: String {
        switch self {
        case .getUploadToken:
            return "/api/v1/qiniu/"
        case .releaseTopic:
            return "/api/v1/releasetopic/"
        case .homePageList:
            return "/api/v1/topiclist/"
        case .beginSearch:
            return "/api/v1/search/"
        case .getSearchKeys:
            return "/api/v1/searchkeywords/"
        case .likeTopicAction:
            return "/api/v1/likeaction/"
        case .collectionAction:
            return "/api/v1/collection/"
        case .topicDetail:
            return "/api/v1/topicdetail/"
        case .tagInfoList:
            return "/api/v1/gettaglist/"
        case .getContact:
            return "/api/v1/getcontact/"
        case .completeRescue:
            return "/api/v1/completetopic/"
        case .addViewHistory:
            return "/api/v1/addviewhistory/"
        }
    }    
}
