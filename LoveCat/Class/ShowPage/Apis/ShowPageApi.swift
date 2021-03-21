//
//  ShowPageApi.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/20.
//

import Foundation
enum ShowPageApi {
    case showInfoList(page: Int,gambit_id: Int?)
    case releaseShowInfo(instruction: String,imgs: String,gambitId: Int?)
    case gambitList
    case likeShowInfo(show_id: Int,like_mark: Int)
    case collectionShowInfo(showId: Int,collect_mark: Int)
    /// 我收藏的秀宠
    case authCollectionShowInfo(page: Int)
    /// 我发布的秀宠
    case authPublishShowinfo(page: Int)
    /// 评论列表
    case commentList(topic_id: Int,page: Int)
    /// 发表评论
    case commentAction(content: String,topic_id: Int,comment_type: Int = 2)
    /// 回复
    case replyComment(content: String, comment_id: Int, reply_id: Int,reply_type: Int,to_uid: Int)
    /// 更多回复
    case loadMoreReply(comment_id: Int,page: Int)
}
extension ShowPageApi: BaseTargetType {
    
    var path: String {
        switch self {
        case .showInfoList:
            return "/api/v1/showinfolist/"
        case .releaseShowInfo:
            return "/api/v1/releaseshowinfo/"
        case .gambitList:
            return "/api/v1/gambitlist/"
        case .likeShowInfo:
            return "/api/v1/showinfolikeaction/"
        case .collectionShowInfo:
            return "/api/v1/showcollectionaction/"
        case .authCollectionShowInfo:
            return "/api/v1/authcollectionshowinfo/"
        case .authPublishShowinfo:
            return "/api/v1/authpublishshowinfo/"
        case .commentAction:
            return "/api/v1/commentaction/"
        case .replyComment:
            return "/api/v1/replycomment/"
        case .commentList:
            return "/api/v1/commentlist/"
        case .loadMoreReply:
            return "/api/v1/replypageinfo/"
        }
    }
    
    var parameters: [String : Any] {
        var dic: [String: Any] = APPConfig.apiBasicParameters()
        switch self {
        case .showInfoList(page: let page,gambit_id: let gambit_id):
            dic["page"] = page
            dic["size"] = 10
            dic["token"] = UserManager.shared.token
            dic["gambit_id"] = gambit_id
        case .releaseShowInfo(instruction: let instrction, imgs: let imgs, gambitId: let gambit_id):
            dic["token"] = UserManager.shared.token
            dic["instruction"] = instrction
            dic["imgs"] = imgs
            dic["gambit_id"] = gambit_id
        case .gambitList:
            break
        case .likeShowInfo(show_id: let showId,like_mark: let like_mark):
            dic["token"] = UserManager.shared.token
            dic["like_mark"] = like_mark
            dic["show_id"] = showId
        case .collectionShowInfo(showId: let showId, collect_mark: let collect_mark):
            dic["token"] = UserManager.shared.token
            dic["collect_mark"] = collect_mark
            dic["show_id"] = showId
        case .authCollectionShowInfo(page: let page):
            dic["page"] = page
            dic["size"] = 10
            dic["token"] = UserManager.shared.token
        case .authPublishShowinfo(page: let page):
            dic["page"] = page
            dic["size"] = 10
            dic["token"] = UserManager.shared.token
        case .commentAction(content: let content, topic_id: let topic_id, comment_type: let comment_type):
            dic["token"] = UserManager.shared.token
            dic["content"] = content
            dic["topic_id"] = topic_id
            dic["topic_type"] = comment_type
        case .replyComment(content: let content, comment_id: let comment_id, reply_id: let reply_id, reply_type: let reply_type,to_uid: let to_uid):
            dic["token"] = UserManager.shared.token
            dic["content"] = content
            dic["comment_id"] = comment_id
            dic["reply_id"] = reply_id
            dic["reply_type"] = reply_type
            dic["to_uid"] = to_uid
        case .commentList(topic_id: let topic_id,page: let page):
            dic["topic_id"] = topic_id
            dic["page"] = page
            dic["size"] = 10
        case .loadMoreReply(comment_id: let comment_id, page: let page):
            dic["comment_id"] = comment_id
            dic["page"] = page
        }
        return dic
    }
}
