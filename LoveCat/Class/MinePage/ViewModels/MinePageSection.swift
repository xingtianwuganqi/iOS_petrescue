//
//  MinePageSection.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/6.
//

import Foundation
import SectionReactor
import Differentiator

enum MinePageSection  {
    case minePageItems([MinePageItem])
}

enum MinePageItem {
    case topItem
    case defaultItem(MinePageCellReactor)
    case logoutItem
}

extension MinePageSection: SectionModelType {
    
    typealias Item = MinePageItem
    var items: [Item] {
        switch self {
        case .minePageItems(let items):
            return items
        }
    }
    init(original: MinePageSection, items: [Item]) {
        switch original {
        case .minePageItems(let items):
            self = .minePageItems(items)
        }
    }
}

/// 消息页面组
enum MessageListSection {
    case messageListItems([MessageListItem])
}
enum MessageListItem {
    case messageItem(AuthMsgCellReactor)
}

extension MessageListSection: SectionModelType {
    typealias Item = MessageListItem
    var items: [Item] {
        switch self {
        case .messageListItems(let item):
            return item
        }
    }
    
    init(original: MessageListSection, items: [Item]) {
        switch original {
        case .messageListItems(let items):
            self = .messageListItems(items)
        }
    }
}

/// 举报页面组
enum ViolationListSection {
    case violationListItems([ViolationListItem])
}
enum ViolationListItem {
    case violationItem(ViolationCellReactor)
}

extension ViolationListSection: SectionModelType {
    typealias Item = ViolationListItem
    var items: [Item] {
        switch self {
        case .violationListItems(let item):
            return item
        }
    }
    
    init(original: ViolationListSection, items: [Item]) {
        switch original {
        case .violationListItems(let items):
            self = .violationListItems(items)
        }
    }
}
