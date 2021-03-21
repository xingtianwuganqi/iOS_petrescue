//
//  AppDelegate.swift
//  LoveCat
//
//  Created by jingjun on 2020/10/16.
//

import UIKit
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var dependency: AppDependency!

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        dependency = dependency ?? CompositionRoot.resolve()
        window = dependency.window
        dependency.configureSDKs()
        
        let entity = JPUSHRegisterEntity.init()
        if #available(iOS 12.0, *) {
            entity.types = Int((JPAuthorizationOptions.alert.rawValue | JPAuthorizationOptions.badge.rawValue | JPAuthorizationOptions.sound.rawValue | JPAuthorizationOptions.providesAppNotificationSettings.rawValue))
        } else {
            entity.types = Int((JPAuthorizationOptions.alert.rawValue | JPAuthorizationOptions.badge.rawValue | JPAuthorizationOptions.sound.rawValue))
        }
        
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        
        //0（默认值）表示采用的是开发证书，1 表示采用生产证书发布应用。
        JPUSHService.setup(withOption: launchOptions, appKey: APPConfig.JGAPPKEY, channel: "App Store", apsForProduction: true)
        UIApplication.shared.applicationIconBadgeNumber = 0
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //sdk注册DeviceToken
        JPUSHService.registerDeviceToken(deviceToken)
    }

}

extension AppDelegate: JPUSHRegisterDelegate {
    // iOS 12 Support
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification!) {
        if (notification != nil) && (notification.request.trigger is  UNPushNotificationTrigger){
            //从通知界面直接进入应用
          }else{
            //从通知设置界面进入应用
          }
        }
    // iOS 10 Support
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
//          completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有 Badge、Sound、Alert 三种类型可以选择设置
        let userInfo = notification.request.content.userInfo
        if notification.request.trigger is UNPushNotificationTrigger {
            JPUSHService.handleRemoteNotification(userInfo)
        }
        completionHandler(1)
    }
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        
    }
    
    func jpushNotificationAuthorization(_ status: JPAuthorizationStatus, withInfo info: [AnyHashable : Any]!) {
        
    }
    
    
    
}

