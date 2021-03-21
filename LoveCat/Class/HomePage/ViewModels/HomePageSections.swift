//
//  TopicDetailSection.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/28.
//

import Foundation
import SectionReactor
import Differentiator

//MARK: 首页
enum HomePageSection {
    case sectionItem([HomePageItem])
}

enum HomePageItem {
    case homepageItem(HomePageItemReactor)
}

extension HomePageSection: SectionModelType {
    typealias Item = HomePageItem
    
    var items: [Item] {
        switch self {
        case .sectionItem(let items):
            return items
        }
    }
    
    init(original: HomePageSection, items: [HomePageItem]) {
        switch original {
        case .sectionItem(let items):
            self = .sectionItem(items)
        }
    }
    
}


//MARK: 详情页
enum TopicDetailSection {
    case detailItem([TopicDetailItem])
}

enum TopicDetailItem {
    case userInfoItem(TopicInfoCellReactor)
    case topicInfo(TopicContentCellReactor)
    case topicImg(TopicImgCellReactor)
}

extension TopicDetailSection: SectionModelType {
    typealias Item = TopicDetailItem
    
    var items: [Item] {
        switch self {
        case .detailItem(let items):
            return items
        }
    }
    
    init(original: TopicDetailSection, items: [Item]) {
        switch original {
        case .detailItem(let item):
            self = .detailItem(item)
        }
    }
    
}
