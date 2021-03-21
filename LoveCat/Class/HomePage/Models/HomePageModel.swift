//
//  HomePageModel.swift
//  LoveCat
//
//  Created by jingjun on 2020/10/28.
//

import Foundation
import HandyJSON
import YYKit

struct HomePageModel: HandyJSON {
    var topic_id: Int?
    var content: String?
    var userInfo: UserInfoModel?
    var imgs: [String]?
    var create_time: String?
    var update_time: String?
    var views_num: Int?
    var likes_num: Int?
    var collection_num: Int?
    var comments_num: Int?
    var address_info: String?
    var is_complete: Int?
    var tags: [Int]?
    var liked: Int?
    var collectioned: Int?
    var user: Int?
    var attribute: NSMutableAttributedString?
    var tagInfos: [TagInfoModel]?
    var contact_info: String?
    var getedcontact: Int?
    
    mutating func didFinishMapping() {        
        let timeStr = self.create_time?.components(separatedBy: ".").first
        let time = timeStr?.replacingOccurrences(of: "T", with: " ")
        if let time = time {
            self.create_time = Tool.shared.timeTDate(time: time)
        }else{
            self.create_time = nil
        }
        
        // 标签显示
        
        let tagsAtt = NSMutableAttributedString.init()
        if let tags = self.tagInfos,tags.count > 0 {
            let infos = tags.map { (model) -> String in
                return model.tag_name ?? ""
            }
            for i in infos {
                let temp = " " + i + " "
                let para = NSMutableParagraphStyle.init()
                para.lineSpacing = 6
                para.lineBreakMode = .byTruncatingTail
                let tempAtt = NSMutableAttributedString(string: temp)
                let range = NSRange(location: 0, length: temp.count)
                let border = YYTextBorder(fill: UIColor(hexString: "#ffa500"), cornerRadius: 3)
                border.insets = UIEdgeInsets(top: -2, left: 0, bottom: -2, right: 0)
                border.lineStyle = []
                tempAtt.setTextBackgroundBorder(border, range: range)
                tempAtt.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.white,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10),NSAttributedString.Key.paragraphStyle: para], range:range)
                tagsAtt.append(tempAtt)
                tagsAtt.append(NSAttributedString.init(string: "  "))

            }
        }
        
//        var contentText: String?
//        if self.content?.contains("\n\n\n\n") ?? false {
//            contentText = self.content?.replacingOccurrences(of: "\n\n", with: "\n")
//        }else if self.content?.contains("\n\n\n") ?? false {
//            contentText = self.content?.replacingOccurrences(of: "\n\n", with: "\n")
//        }else if self.content?.contains("\n\n") ?? false {
//            contentText = self.content?.replacingOccurrences(of: "\n\n", with: "\n")
//        }else{
//            contentText = self.content
//        }
        let contentText = (self.content ?? "").et.removeHeadAndTailSpacePro
        let para = NSMutableParagraphStyle.init()
        para.lineSpacing = 4
        para.lineBreakMode = .byTruncatingTail
        let attribute = NSMutableAttributedString.init()
        if tagsAtt.string.count > 0 {
            attribute.append(tagsAtt)
            attribute.append(NSMutableAttributedString.init(string: "\n"))
        }
        attribute.append(NSMutableAttributedString.init(string: contentText, attributes: [NSMutableAttributedString.Key.font: UIFont.et.fontSize(),NSMutableAttributedString.Key.foregroundColor: UIColor.color(.content)!]))
        self.attribute = attribute
    }
}

struct TopicInfoModel: HandyJSON {
    var topicName: String?
    var topicId: String?
    var desc: String?
}

//struct TopicTagsModel: HandyJSON {
//    var tagName: String?
//}

struct TopicImgModel: HandyJSON {
    
}


struct SearchKeysInfo: HandyJSON,Equatable {
    var id: Int?
    var keyword: String?
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.keyword == rhs.keyword
    }
}

struct LikeStatusModel: HandyJSON {
    var like: Int?
    var mark: Int?
}

struct CollectionStatusModel: HandyJSON {
    var collection: Int?
    var mark: Int?
}

struct ContactModel: HandyJSON {
    var contact: String?
}
