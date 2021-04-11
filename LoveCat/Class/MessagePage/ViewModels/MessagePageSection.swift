//
//  MessagePageSection.swift
//  LoveCat
//
//  Created by jingjun on 2021/3/22.
//

import Foundation
import SectionReactor
import Differentiator

/// 首页
enum MessagePageSection  {
    case msgPageItem([MessagePageItems])
}

enum MessagePageItems {
    case sysMsgItem(MinePageCellReactor)
    case chartMsgItem
}

extension MessagePageSection: SectionModelType {
    
    typealias Item = MessagePageItems
    var items: [Item] {
        switch self {
        case .msgPageItem(let items):
            return items
        }
    }
    init(original: MessagePageSection, items: [Item]) {
        switch original {
        case .msgPageItem(let items):
            self = .msgPageItem(items)
        }
    }
}

/// 点赞、收藏、评论
enum MessageCommonSection {
    case msgCommonItem([MessageCommonItems])
}

enum MessageCommonItems {
    case CommonItem(MessageCommonCellReactor)
}

extension MessageCommonSection: SectionModelType {
    typealias Item = MessageCommonItems
    var items: [Item] {
        switch self {
        case .msgCommonItem(let items):
            return items
        }
    }
    
    init(original: MessageCommonSection, items: [MessageCommonItems]) {
        switch original {
        case .msgCommonItem(let items):
            self = .msgCommonItem(items)
        }
    }
}

/// 系统消息
enum SystemMessageSection {
    case systemSection([SystemMessageItem])
}

enum SystemMessageItem {
    case sysItem(SystemMsgCellReactor)
}

extension SystemMessageSection: SectionModelType {
    typealias Item = SystemMessageItem
    var items: [SystemMessageItem] {
        switch self {
        case .systemSection(let items):
            return items
        }
    }
    
    init(original: SystemMessageSection, items: [SystemMessageItem]) {
        switch original {
        case .systemSection(let items):
            self = .systemSection(items)
        }
    }
}
