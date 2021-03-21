//
//  ShowPageSection.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/18.
//

import Foundation
import SectionReactor
import Differentiator

//
enum ShowPageListSection {
    case showListSection([ShowPageListItem])
}
enum ShowPageListItem {
    case showPageItem(ShowListCellReactor)
}

extension ShowPageListSection: SectionModelType {
    typealias Item = ShowPageListItem
    var items: [ShowPageListItem] {
        switch self {
        case .showListSection(let items):
            return items
        }
    }
    
    init(original: ShowPageListSection, items: [ShowPageListItem]) {
        switch original {
        case .showListSection(let items):
            self = .showListSection(items)
        }
    }
    
}

// MARK: 话题页
enum GambitListSection {
    case gambitSection([GambitListItem])
}
enum GambitListItem {
    case gambitItem(GambitListModel)
}

extension GambitListSection: SectionModelType {
    typealias Item = GambitListItem
    var items: [GambitListItem] {
        switch self {
        case .gambitSection(let items):
            return items
        }
    }
    
    init(original: GambitListSection, items: [GambitListItem]) {
        switch original {
        case .gambitSection(let item):
            self = .gambitSection(item)
        }
    }
}


enum CommentListSection {
    case commentSection([CommentListItem])
}

enum CommentListItem {
    case commentItem(CommentListCellReactor)
    case replyItem(ReplyListCellReactor)
    case moreItem
}

extension CommentListSection : SectionModelType {
    typealias Item = CommentListItem
    var items: [CommentListItem] {
        switch self {
        case .commentSection(let items):
            return items
        }
    }
    
    init(original: CommentListSection, items: [CommentListItem]) {
        switch original {
        case .commentSection(let items):
            self = .commentSection(items)
        }
    }
}
