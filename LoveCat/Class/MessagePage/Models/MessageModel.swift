//
//  MessageModel.swift
//  LoveCat
//
//  Created by jingjun on 2021/3/22.
//

import Foundation
import HandyJSON

struct MessageModel: HandyJSON {
    var headIcon: String?
    var nickName: String?
    var unreadNum: Int = 0
}

struct MessageNumModel: HandyJSON {
    var sys_unread: Int?
    var like_unread: Int?
    var collec_unread: Int?
    var com_unread: Int?
}

struct MessageListModel: HandyJSON {
    var id: Int?
    var create_time: String?
    var msg_type: Int?
    var msg_id: Int?
    var from_info: UserInfoModel?
    var to_info: UserInfoModel?
    var is_read: Int?
    var topicInfo: HomePageModel?
    var showInfo: ShowPageModel?
    var replyInfo: ReplyListModel?
    var commentInfo: CommentListModel?
    var reply_type: Int?
    var reply_id: Int?
}

struct SystemMsgModel: HandyJSON {
    var create_time: String?
    var content: String?
    var msg_type: Int?
    var user_id: Int?
    var timeStr: String?
    
    mutating func didFinishMapping() {
        timeStr = Tool.shared.timeTDate(time: create_time ?? "")
    }
}
