//
//  Reachability.swift
//  App-720yun
//
//  Created by jingjun on 2018/5/24.
//  Copyright © 2018年 720yun. All rights reserved.
//

import Foundation
import Reachability

final class NetWorkMonitoring {
    
    static let shareMonitor = NetWorkMonitoring()
    
    var reachability : Reachability?
    
    private var noReachability: ((_ net: Bool) -> Void)?
    
    private init() {
        do {
            reachability = try? Reachability.init(hostname: "www.baidu.com")
        }
        self.startRun()
    }
    
    func startRun() {
        do {
            try reachability?.startNotifier()
        } catch {
            printLog("Unable to start notifier")
        }
    }
    
    func stopRun() {
        reachability?.stopNotifier()
    }

    
    func monitoring(noReachability:((_ net: Bool) -> Void)? = nil) {
        reachability?.whenReachable = {
            reachability in
            if reachability.connection == .wifi {
                printLog("WIFI")
                
            }else if reachability.connection == .cellular{
                printLog("移动网络")
                
            }else{
                printLog("NoNetWorking")
                
            }
            self.noReachability = noReachability
            
            if self.noReachability != nil {
                self.noReachability!(true)
            }
            return
        }
        reachability?.whenUnreachable = { reachability in
            printLog("Not reachable")
            self.noReachability = noReachability
            
            if self.noReachability != nil {
                self.noReachability!(false)
            }
            return
        }
    }
    
    var currentNetState: Reachability.Connection?  {
        return reachability?.connection
    }
    
}
