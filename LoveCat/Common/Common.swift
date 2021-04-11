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
