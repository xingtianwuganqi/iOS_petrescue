//
//  ShowPageModel.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/18.
//

import Foundation
import HandyJSON

struct ShowPageModel: HandyJSON , Equatable{
    var show_id: Int?
    var user: UserInfoModel?
    var imgs: [String]?
    var views_num: Int?
    var likes_num: Int?
    var collection_num: Int?
    var comments_num: Int?
    var instruction: String?
    var gambit_type: GambitListModel?
    var instructAttribute: NSMutableAttributedString?
    var open: Bool = false
    var liked: Int?
    var collectioned: Int?
    var create_time: String?
    var commentInfo: CommentListModel?
    var commentAttr: NSAttributedString?
    var commNum: Int?

    mutating func didFinishMapping() {
        let para = NSMutableParagraphStyle.init()
        para.lineSpacing = 4
        para.lineBreakMode = .byTruncatingTail
        let attribute = NSMutableAttributedString.init()
        attribute.append(NSMutableAttributedString.init(string: self.instruction ?? "",
                                                        attributes: [NSMutableAttributedString.Key.font: UIFont.et.fontSize(),
                                                                     NSMutableAttributedString.Key.foregroundColor: UIColor.color(.content)!]
        ))
        self.instructAttribute = attribute
        
        let timeStr = self.create_time?.components(separatedBy: ".").first
        let time = timeStr?.replacingOccurrences(of: "T", with: " ")
        if let time = time {
            self.create_time = Tool.shared.timeTDate(time: time)
        }else{
            self.create_time = nil
        }
        
        if let commentText = self.commentInfo?.content,commentText.count > 0 {
            var text = ""
            if let username = self.commentInfo?.userInfo?.username,username.count > 0 {
                text = username + "：" + commentText
            }else{
                text = commentText
            }
    
            self.commentAttr = NSAttributedString.init(string: text, attributes: [NSAttributedString.Key.font: UIFont.et.fontSize(.regular, .desc),NSAttributedString.Key.foregroundColor: UIColor.color(.desc)!,NSAttributedString.Key.paragraphStyle: para])
        }else{
            let text = "添加评论..."
            self.commentAttr = NSAttributedString.init(string: text, attributes: [NSAttributedString.Key.font: UIFont.et.fontSize(.regular, .desc),NSAttributedString.Key.foregroundColor: UIColor.color(.desc)!,NSAttributedString.Key.paragraphStyle: para])
        }
        
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.show_id == rhs.show_id
    }
}

struct GambitListModel: HandyJSON, Equatable {
    var descript: String?
    var id: Int?
    var selected: Bool = false
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}


struct CommentListModel: HandyJSON {
    var comment_id: Int?
    var create_time : String?
    var topic_id : Int?
    var topic_type : Int? // 秀宠1，后面加领养的回复
    var content : String?
    var from_uid : Int?
    var replys: [ReplyListModel]?
    var isOpend: Bool? // 回复是否折叠，true 是全部展示,false 时展示折叠cell
    var showReply: [ReplyListModel]?
    var userInfo: UserInfoModel?
    var reply_count: Int?
    var next_page: Int = 2
    mutating func didFinishMapping() {
        if let replyList = replys,let reply_count = reply_count {

            if reply_count > replyList.count {
                isOpend = false
            }else{
                isOpend = true
            }
        }
        let timeStr = self.create_time?.components(separatedBy: ".").first
        let time = timeStr?.replacingOccurrences(of: "T", with: " ")
        if let time = time {
            self.create_time = Tool.shared.timeTDate(time: time)
        }else{
            self.create_time = nil
        }
    }
}
    


struct ReplyListModel: HandyJSON {
    var id: Int?
    var comment_id : Int?
    var reply_id : Int? // #表示回复目标的 id，如果 reply_type 是 comment 的话，那么 reply_id ＝ commit_id，如果 reply_type 是 reply 的话，这表示这条回复的父回复。
    var reply_type : Int? // #表示回复的类型，因为回复可以是针对评论的回复（comment），也可以是针对回复的回复（reply）， 通过这个字段来区分两种情景。
    var content : String?
    var from_uid : Int?
    var to_uid : Int?
    var fromInfo: UserInfoModel?
    var toInfo: UserInfoModel?
    var create_time: String?
    
    mutating func didFinishMapping() {
        let timeStr = self.create_time?.components(separatedBy: ".").first
        let time = timeStr?.replacingOccurrences(of: "T", with: " ")
        if let time = time {
            self.create_time = Tool.shared.timeTDate(time: time)
        }else{
            self.create_time = nil
        }
    }
}
    
