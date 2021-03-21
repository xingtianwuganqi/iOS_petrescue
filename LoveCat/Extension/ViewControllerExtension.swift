//
//  ViewControllerExtension.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/25.
//

import Foundation
extension UIViewController {
    // MARK: - 查找当前显示的控制器
    
    // 获取顶层控制器 根据window
    static func topViewController() -> UIViewController? {
        var window = UIApplication.shared.keyWindow
        //是否为当前显示的window
        if window?.windowLevel != UIWindow.Level.normal {
            let windows = UIApplication.shared.windows
            for  windowTemp in windows{
                if windowTemp.windowLevel == UIWindow.Level.normal {
                    window = windowTemp
                    break
                }
            }
        }
        return topViewControllerBy(window?.rootViewController)
    }
    /// 根据控制器获取 顶层控制器
    private static func topViewControllerBy(_ viewController :UIViewController?) -> UIViewController? {
        guard let viewController = viewController else {
            printLog("找不到顶层控制器")
            return nil
        }
        if let presentVC = viewController.presentedViewController {
            //modal出来的 控制器
            return topViewControllerBy(presentVC)
        }
        else if let tabVC = viewController as? UITabBarController {
            if let selectVC = tabVC.selectedViewController {
                return topViewControllerBy(selectVC)
            }
            return nil
        } else if let naiVC = viewController as? UINavigationController {
            return topViewControllerBy(naiVC.visibleViewController)
        } else {
            return viewController
        }
    }

}
