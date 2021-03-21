//
//  Common.swift
//  LoveCat
//
//  Created by jingjun on 2020/10/19.
//

import Foundation



let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
let SCREEN_WIDTH  = UIScreen.main.bounds.size.width


func isIphoneXSeries() -> Bool {
    guard let window = UIApplication.shared.keyWindow else {
        return false
    }
    if #available(iOS 11.0, *) {
        return window.safeAreaInsets.bottom > 0
    } else {
        return false
    }
}

// 相对iPhoneXS max的宽度适配
func scaleSize(_ size: CGFloat) -> CGFloat { size * min((SCREEN_WIDTH / 414), 1.5) }
// 相对iPhoneX 的宽度适配
func scaleXSize(_ size: CGFloat) -> CGFloat { size * min((SCREEN_WIDTH / 375), 1.5) }



let SystemStatusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
let SystemNavigationBarContentHeight: CGFloat = 44.0
let SystemNavigationBarHeight: CGFloat = SystemNavigationBarContentHeight + SystemStatusBarHeight
let SystemTabBarContentHeight: CGFloat = 49.0
let SystemTabBarHeight: CGFloat = isIphoneXSeries() ? SystemTabBarContentHeight + 34.0 : SystemTabBarContentHeight
let isIOS10Later = (NSFoundationVersionNumber >= NSFoundationVersionNumber10_0)
let SystemSafeBottomHeight: CGFloat = isIphoneXSeries() ? 34.0 : 0

let IMGURL      = "http://img.rxswift.cn/"
let IMGMARK     = "?imageView2/0/q/70|watermark/2/text/QOecn-WRveWkqeWWtQ==/font/5a6L5L2T/fontsize/240/fill/IzY2NjY2Ng==/dissolve/75/gravity/SouthEast/dx/10/dy/10"
let IMGTHUMBNAIL = "?imageView2/0/q/40"
let RescueReleased = "RescueReleased"
let ShowReleased   = "ShowReleased"

func printLog<N>(_ message:N,fileName:String = #file,methodName:String = #function,lineNumber:Int = #line){
    #if DEBUG
    print("message:\(message)\nway:\(fileName as NSString) methods:\(methodName) line:\(lineNumber)")
    #endif
}

enum GlobalConstants {
    
    #if DEBUG
    static let isEnabledDebugShowTimeTouch = true
    #else
    static let isEnabledDebugShowTimeTouch = false
    #endif
    
    // 2.3.5
    static let AppVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
    static let AppBundleIdentifier = (Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String) ?? ""
    // 235
    static let AppIntegerVersion = AppVersion.replacingOccurrences(of: ".", with: "", options: .literal, range: nil)
    static let iOSVersion = UIDevice.current.systemVersion
    static let AppDisplayName = (Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String) ?? ""
    static let AppLookLink = (Bundle.main.infoDictionary?["RTAppLookLink"] as? String) ?? ""
    static let AppDownloadLink = (Bundle.main.infoDictionary?["RTNewAppDownLoadLink"] as? String) ?? ""
    static let AppStoreDownloadLink = (Bundle.main.infoDictionary?["RTAppDownloadLink"] as? String) ?? ""
}

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

