//
//  UserManager.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/16.
//

import Foundation
import HandyJSON
import RxSwift
final class UserManager {
    static let shared = UserManager.init()
    let userInfoKey = "userinfokey"
    public init() {
    
    }
    var naviServer: NavigatorServiceType?
    
    var userInfo: UserInfoModel?
    
    var userSubject: PublishSubject<UserInfoModel?> = PublishSubject.init()
    
    var isLogin: Bool {
        return self.userInfo?.token?.count ?? 0 > 0
    }
    
    var token: String {
        get {
            return self.userInfo?.token ?? ""
        }
    }
    
    
    func upLoadUserInfo(_ info: UserInfoModel? = nil) {
        if let userInfo = info {
            self.userInfo = userInfo
            if let json = self.userInfo?.toJSONString() {
                UserDefaults.standard.setValue(json, forKey: userInfoKey)
            }
            self.userSubject.onNext(userInfo)
        }else{
            guard let infoStr = UserDefaults.standard.value(forKey: userInfoKey) as? String,infoStr.count > 0 else{
                return
            }
            let model = JSONDeserializer<UserInfoModel>.deserializeFrom(json: infoStr)
            self.userInfo = model
            if let info = model {
                self.userSubject.onNext(info)
            }
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: userInfoKey)
        UserDefaults.standard.removeObject(forKey: Shield_type.rescue_sh_page.rawValue)
        UserDefaults.standard.removeObject(forKey: Shield_type.rescue_sh_comment.rawValue)
        UserDefaults.standard.removeObject(forKey: Shield_type.rescue_sh_reply.rawValue)
        UserDefaults.standard.removeObject(forKey: Shield_type.show_sh_page.rawValue)
        UserDefaults.standard.removeObject(forKey: Shield_type.show_sh_comment.rawValue)
        UserDefaults.standard.removeObject(forKey: Shield_type.show_sh_reply.rawValue)
        UserDefaults.standard.removeObject(forKey: RescueReleased)
        UserDefaults.standard.removeObject(forKey: ShowReleased)
        self.userInfo = nil
        // 退回首页
        AppHelper.topNavigationController()?.popToRootViewController(animated: false)
        AppHelper.currentTabBarController()?.selectedIndex = 0
        self.userSubject.onNext(nil)
    }
    
    
    /// 必须要登陆以后才能做的事情
    func lazyAuthToDoThings(_ block: @escaping (() -> Void)) {
        
        if UserManager.shared.isLogin == false {
            self.naviServer?.navigatorSubject.onNext(.login)
        }
        else {
            block()
        }
    }
    
    /// 用户屏蔽的内容读取
    func setUserShieldContent(shieldId: Int,shieldType: Shield_type) {
        
        if var shieldArr = UserDefaults.standard.value(forKey: shieldType.rawValue) as? [Int] {
            if shieldArr.contains(shieldId) {
                return
            }
            shieldArr.append(shieldId)
            UserDefaults.standard.setValue(shieldArr, forKey: shieldType.rawValue)
            UserDefaults.standard.synchronize()
        }else{
            var shieldArr : [Int] = []
            shieldArr.append(shieldId)
            UserDefaults.standard.setValue(shieldArr, forKey: shieldType.rawValue)
            UserDefaults.standard.synchronize()
        }
        
    }
    
    /// 用户屏蔽的内容读取
    func getUserShieldContent(shieldType: Shield_type) -> [Int] {
        if let shieldArr = UserDefaults.standard.value(forKey: shieldType.rawValue) as? [Int] {
            return shieldArr
        }else{
            return []
        }
    }
    
}


