//
//  MyPublishSection.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/10.
//

import Foundation
import SectionReactor
import Differentiator

enum MyPublishSection  {
    case publishSection([MyPublishItem])
}

enum MyPublishItem {
    case publishItem(PublishCellReactor)
}

extension MyPublishSection: SectionModelType {
    
    typealias Item = MyPublishItem
    var items: [Item] {
        switch self {
        case .publishSection(let items):
            return items
        }
    }
    init(original: MyPublishSection, items: [Item]) {
        switch original {
        case .publishSection(let items):
            self = .publishSection(items)
        }
    }
}


enum UserEditSection  {
    case userEditItem([UserEditItem])
}

enum UserEditItem {
    case editHeadImg(UserEditModel)
    case editItem(UserEditModel)
}

extension UserEditSection: SectionModelType {
    
    typealias Item = UserEditItem
    var items: [Item] {
        switch self {
        case .userEditItem(let items):
            return items
        }
    }
    init(original: UserEditSection, items: [Item]) {
        switch original {
        case .userEditItem(let items):
            self = .userEditItem(items)
        }
    }
}
