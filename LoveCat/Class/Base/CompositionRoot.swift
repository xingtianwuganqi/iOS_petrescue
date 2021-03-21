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
        
        let homepage = HomePageListController.init(navi: naviService)
        let showList = ShowPageListController.init(navi: naviService, type: .showInfoList)
        let gambit = GambitListController.init(navi: naviService, normal: nil, selected: nil)
        let video = ShowPageMainViewController.init(pages: [showList,gambit], defaultIndex: 0)
        let mine = MinePageViewController(navi: naviService)
        
        let mainTB = MainTabbarController.init(naviService: naviService, homePage: homepage, videoPage: video, minePage: mine)
        
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
