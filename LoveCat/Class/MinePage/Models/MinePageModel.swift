//
//  MinePageModel.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/6.
//

import Foundation
import HandyJSON

struct MinePageCellModel {
    var iconImg: String?
    var title: String?
    var num: Int = 0
}

struct HistoryModel: HandyJSON {
    var history_id: Int?
    var topicInfo: HomePageModel?
    var topic_id: Int?
}


struct CollectionModel: HandyJSON {
    var collection_id: Int = 0
    var userInfo: UserInfoModel?
    var topicInfo: HomePageModel?
    var topic_id: Int = 0
}

struct TopicInfo: HandyJSON {
    var is_complete: Bool = false
    var topic_id: Int = 0
    var views_num: Int = 0
    var gambit_type: String?
    var comments_num: Int = 0
    var user: Int = 0
    var userInfo: UserInfoModel?
    var update_time: String?
    var create_time: String?
    var address_info: String?
    var liked: Bool = false
    var content: String?
    var collectioned: Bool = false
    var imgs: String?
    var likes_num: Int = 0
    var contact: String?
    var is_get_contact: Bool = false
}


struct UserEditModel {
    var title: String?
    var placeholder: String?
    var textValue: String?
    var avator: UIImage?
}


struct ShowCollectionModel: HandyJSON {
    var showcollect_id: Int = 0
    var userInfo: UserInfoModel?
    var showInfo: ShowPageModel?
    var topic_id: Int = 0
}

struct MessageInfoModel: HandyJSON {
    var msg_id: Int?
    var id: Int?
    var from_info: UserInfoModel?
    var to_info: UserInfoModel?
    var msg_type: MsgTypeInfo?
    var content: String?
    var text: String?
    var create_time: String?
    var msgAttr: NSAttributedString?
    
    mutating func didFinishMapping() {
        let timeStr = self.create_time?.components(separatedBy: ".").first
        let time = timeStr?.replacingOccurrences(of: "T", with: " ")
        if let time = time {
            self.create_time = Tool.shared.timeTDate(time: time)
        }else{
            self.create_time = nil
        }
        
        let attrbute = NSMutableAttributedString()
        if let content = self.content {
            //设置段落属性
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 3     //设置行间距
            paragraphStyle.alignment = .justified      //文本对齐方向
            
            attrbute.append(NSAttributedString(string: "您发表的", attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.content)!, NSAttributedString.Key.font: UIFont.et.fontSize(), NSAttributedString.Key.paragraphStyle: paragraphStyle]))
            
            attrbute.append(NSAttributedString(string: self.msg_type?.title ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.content)!, NSAttributedString.Key.font: UIFont.et.fontSize(), NSAttributedString.Key.paragraphStyle: paragraphStyle]))
            
            attrbute.append(NSAttributedString(string: " \(content) ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.urlColor)!, NSAttributedString.Key.font: UIFont.et.fontSize(), NSAttributedString.Key.paragraphStyle: paragraphStyle]))
            
            switch msg_type {
            case .rescueLike, .showLike:
                attrbute.append(NSAttributedString(string: "获得一条点赞", attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.content)!, NSAttributedString.Key.font: UIFont.et.fontSize(), NSAttributedString.Key.paragraphStyle: paragraphStyle]))
                break
            case .rescueCollection, .showCollection:
                if let from_name = from_info?.username,from_name.count > 0 {
                    attrbute.append(NSAttributedString(string: "被用户\(from_name)收藏了", attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.content)!, NSAttributedString.Key.font: UIFont.et.fontSize(), NSAttributedString.Key.paragraphStyle: paragraphStyle]))
                }else{
                    attrbute.append(NSAttributedString(string: "被他人收藏了", attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.content)!, NSAttributedString.Key.font: UIFont.et.fontSize(), NSAttributedString.Key.paragraphStyle: paragraphStyle]))
                }
                break
            case .rescueComment, .showComment:
                attrbute.append(NSAttributedString(string: "收到一条评论。", attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.content)!, NSAttributedString.Key.font: UIFont.et.fontSize(), NSAttributedString.Key.paragraphStyle: paragraphStyle]))
                if let text = self.text,text.count > 0 {
                    attrbute.append(NSAttributedString(string: "他说：\(text)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.content)!, NSAttributedString.Key.font: UIFont.et.fontSize(), NSAttributedString.Key.paragraphStyle: paragraphStyle]))
                }
                break
            case .rescueReply, .showReply:
                attrbute.append(NSAttributedString(string: "收到一条回复。", attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.content)!, NSAttributedString.Key.font: UIFont.et.fontSize(), NSAttributedString.Key.paragraphStyle: paragraphStyle]))
                if let text = self.text,text.count > 0 {
                    attrbute.append(NSAttributedString(string: "他说：\(text)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.content)!, NSAttributedString.Key.font: UIFont.et.fontSize(), NSAttributedString.Key.paragraphStyle: paragraphStyle]))
                }
                break
            default:
                break
            }
        }
        self.msgAttr = attrbute
        
        
    }
}

enum MsgTypeInfo: Int ,HandyJSONEnum{
    
    case rescueLike = 1
    case rescueCollection = 2
    case rescueComment = 3
    case rescueReply = 4
    case showLike = 5
    case showCollection = 6
    case showComment = 7
    case showReply = 8
    
    var title: String {
        switch self {
        case .rescueLike, .rescueCollection,.rescueComment:
            return "领养"
        case .showLike, .showCollection,.showComment:
            return "秀宠"
        case .showReply, .rescueReply:
            return "评论"
        }
    }
    
    var desc: String {
        switch self {
        case .rescueLike,.showLike:
            return "点赞"
        case .rescueCollection, .showCollection:
            return "收藏"
        case .rescueComment, .showComment:
            return "评论"
        case .rescueReply, .showReply:
            return "回复"
        }
    }
}

struct UnreadModel: HandyJSON {
    var number: Int?
}

struct ViolationModel: HandyJSON {
    var id: Int?
    var vio_name: String?
    var selected: Bool = false
}
