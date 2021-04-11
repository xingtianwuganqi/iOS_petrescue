//
//  ReleasePhotoModel.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/22.
//

import Foundation
import HandyJSON

struct ReleasePhotoModel: HandyJSON, Equatable {
    
    var image: UIImage?
    var isAdd: Bool = false // 是不是添加的图片
    var progress: Float = 0
    var complete: Bool = false
    var photoKey: String = "\(Tool.shared.getTime())/\(String.et.random(ofLength: 8)).jpeg"
    var photoUrl: String = ""
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.photoKey == rhs.photoKey
    }
}



struct ReleaseInfo {
    var content: String = ""
    var photos: [ReleasePhotoModel] = []
    var contact: String = ""
    var address: String = ""
}

// 缓存时的图片信息
struct CacheReleasePhoto: HandyJSON {
    var image: String?
    var photoKey: String?
    var isAdd: Bool = false
}
// 缓存的数据结构
struct CacheReleaseInfo: HandyJSON {
    var photos: [CacheReleasePhoto]?
    var tagInfos: [TagInfoModel]?
    var content: String?
    var contact: String?
    var address: String?
    var gambit: GambitListModel?
}

struct ReleaseShowInfo {
    var content: String = ""
    var photos: [ReleasePhotoModel] = []
}

struct TokenModel: HandyJSON {
    var token: String?
}


struct TagInfoModel: HandyJSON,Equatable {
    var id: Int?
    var tag_name: String?
    
    var select: Bool = false
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.tag_name == rhs.tag_name
    }
}
