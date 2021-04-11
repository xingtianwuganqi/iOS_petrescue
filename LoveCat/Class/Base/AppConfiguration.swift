//
//  AppConfiguration.swift
//  LoveCat
//
//  Created by jingjun on 2021/4/9.
//

import Foundation

let IMGURL      = "http://img.rxswift.cn/"
let IMGMARK     = "?imageView2/0/q/70|watermark/2/text/QOecn-WRveWkqeWWtQ==/font/5a6L5L2T/fontsize/240/fill/IzY2NjY2Ng==/dissolve/75/gravity/SouthEast/dx/10/dy/10"
let IMGTHUMBNAIL = "?imageView2/0/q/40"
let RescueReleased = "RescueReleased"
let ShowReleased   = "ShowReleased"

enum UserProtocal: String {
    case pravicy = "/api/pravicy/"
    case userAgreen = "/api/useragreen/"
    case aboutUs = "/api/aboutus/"
}

struct APPConfig {
    static let QNACCESSKEY = "1vLUgTSJEyyElB_EFpsCzua84QJJqrtrPrueICw2"
    static let QNSECRETKEY = "QvOlYbG0my-CGh7nfjnBnOxVP1j3ClqhR1Ocf0Ug"
    static let JGAPPKEY = "d3d833b59e00683a1cba7323"
    
    static func apiBasicParameters() -> [String:Any] {
        [
            "appType": "ios",
            "token":UserManager.shared.token,
            "appVersion": GlobalConstants.AppVersion,
            "iOSVersion": GlobalConstants.iOSVersion,
        ]
    }
}

enum Report_type: Int { //# 1.领养举报 2.领养评论 3.领养回复 4.秀宠举报 5.秀宠评论 6.秀宠回复
    case rescue_page = 1
    case rescue_comment = 2
    case rescue_reply = 3
    case show_page = 4
    case show_comment = 5
    case show_reply = 6
}

enum Shield_type: String {
    case rescue_sh_page = "rescue_sh_page"
    case rescue_sh_comment = "rescue_sh_comment"
    case rescue_sh_reply = "rescue_sh_reply"
    case show_sh_page = "show_sh_page"
    case show_sh_comment = "show_sh_comment"
    case show_sh_reply = "show_sh_reply"
}

enum CacheImgPath: String {
    case rescue = "CacheRescueImages"
    case show   = "CacheShowImages"
}
