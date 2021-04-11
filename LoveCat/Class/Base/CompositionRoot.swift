//
//  CompositionRoot.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/16.
//

import Foundation
import URLNavigator
import IQKeyboardManagerSwift
struct AppDependency {
    let window: UIWindow
    let navigator: Navigator
    let configureSDKs: () -> Void
}


final class CompositionRoot {
    static func resolve() -> AppDependency {
        let navi = Navigator()
        let naviService = NavigatorService.init(navigator: navi)
        
        UserManager.shared.upLoadUserInfo()
        UserManager.shared.naviServer = naviService
        
        let mainTB = MainTabbarController.init(naviService: naviService)
        
        let window = UIWindow.init(frame: UIScreen.main.bounds)
        window.rootViewController = mainTB
        window.makeKeyAndVisible()
        
        return AppDependency(window: window, navigator: navi,configureSDKs: configureSDKs)
    }
    
    static func configureSDKs() {
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        
    }
}
