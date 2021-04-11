//
//  Tool.swift
//  App-720yun
//
//  Created by jingjun on 2018/5/14.
//  Copyright © 2018年 720yun. All rights reserved.
//

import UIKit
import Photos


class Tool: NSObject  {
    
    static let shared = Tool()
    
    private override init(){
        
    }
    
    func getTextHeigh(textStr:String,font:UIFont,width:CGFloat) -> CGFloat {
        let normalText: NSString = textStr as NSString
        let size = CGSize(width: ceil(width), height: CGFloat(MAXFLOAT))//CGSizeMake(width,1000)
        let dic = NSDictionary(object: font, forKey: kCTFontAttributeName as! NSCopying)
        let stringSize = normalText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedString.Key : Any], context:nil).size
        return ceil(stringSize.height)
    }
    
    func getSpaceLabelHeight(textStr:String,font:UIFont,width:CGFloat,space: CGFloat) -> CGFloat {
        
        let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .justified
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineSpacing = space //调整行间距
        let values = [font,paragraphStyle]
        let dis = [kCTFontAttributeName as! NSCopying,kCTParagraphStyleAttributeName as! NSCopying]
        let dic = NSDictionary(objects: values, forKeys: dis)
        let normalText: NSString = textStr as NSString
        let size = CGSize(width: ceil(width), height: CGFloat(MAXFLOAT))
        let stringSize = normalText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedString.Key : Any], context:nil).size
        return ceil(stringSize.height)
    }
    
    
    func getLabelSize(textStr:String,font:UIFont,width:CGFloat) -> CGSize {
        
        let normalText: NSString = textStr as NSString
        let size = CGSize(width: width, height: CGFloat(MAXFLOAT))//CGSizeMake(width,1000)
        let dic = NSDictionary(object: font, forKey: kCTFontAttributeName as! NSCopying)
        let stringSize = normalText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedString.Key : Any], context:nil).size
        return CGSize(width: ceil(stringSize.width), height: ceil(stringSize.height))
    }
    
    func dateType(dateString: Int, format: String) -> String {
        
        let time : TimeInterval = Double(dateString)
        
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = format
        
        let date = Date(timeIntervalSince1970: time)
        
        return dfmatter.string(from: date)
        
    }
    
    func timeUptoNow(time: Int,mate: String) -> String {
        let nowDate: Date = Date()
        let t : TimeInterval = Double(time)
        let date = Date(timeIntervalSince1970: t)
        let userCalendar = Calendar.current
        let cmps = userCalendar.dateComponents([Calendar.Component.year,Calendar.Component.month,Calendar.Component.day], from: date, to: nowDate)
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = mate
        if cmps.year! > 0 {
            
            return "\(cmps.year!)年(\(dfmatter.string(from: date)))"
        }else {
            if cmps.month! > 0 {
                return "\(cmps.month!)月(\(dfmatter.string(from: date)))"
            }else {
                return "\(cmps.day!)天(\(dfmatter.string(from: date)))"
            }
        }
    }
    
    func timeWithFramate(time: Int,mate: String) -> String {
        let nowDate: Date = Date()
        let t : TimeInterval = Double(time)
        let date = Date(timeIntervalSince1970: t)
        let userCalendar = Calendar.current
        let cmps = userCalendar.dateComponents([Calendar.Component.year,Calendar.Component.month,Calendar.Component.day], from: date, to: nowDate)
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = mate
        return  dfmatter.string(from: date)

    }
    
    func timeDifference(time: Int) -> String {
        
        let nowDate : Date = Date()
        
        let t : TimeInterval = Double(time)
        
        let date = Date(timeIntervalSince1970: t)
        
        
        let userCalendar = Calendar.current
        
        let cmps = userCalendar.dateComponents([Calendar.Component.hour,Calendar.Component.minute,Calendar.Component.second], from: date, to: nowDate)
        
        if cmps.hour! >= 96 {
            let dfmatter = DateFormatter()
            dfmatter.dateFormat = "yyyy.MM.dd"
            
            let date = Date(timeIntervalSince1970: t)
            
            return dfmatter.string(from: date)
            
        }else if cmps.hour! >= 72 {
            return "3天前"
        }else if cmps.hour! >= 48{
            return "2天前"
        }else if cmps.hour! >= 24{
            return "1天前"
        }else if cmps.hour! >= 1{
            return "\(cmps.hour!)小时前"
        }else if cmps.minute! >= 1{
            return "\(cmps.minute!)分钟前"
        }else{
            return "\(cmps.second!)秒前"
        }
        
    }
    
    /// 中间带T的时间字符串
    func timeTDate(time: String) -> String {
        var timeStr = time
        if let firstStr = time.components(separatedBy: ".").first {
            timeStr = firstStr
        }
        timeStr = timeStr.replacingOccurrences(of: "T", with: " ")
        let nowDate : Date = Date()
        
        let dateForm : DateFormatter = DateFormatter.init()
        dateForm.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateForm.date(from: timeStr) ?? Date()
        let userCalendar = Calendar.current
        
        let cmps = userCalendar.dateComponents([Calendar.Component.hour,Calendar.Component.minute,Calendar.Component.second], from: date, to: nowDate)
        
        if cmps.hour! >= 96 {
            let dfmatter = DateFormatter()
            dfmatter.dateFormat = "yyyy.MM.dd"
            
            let date = dateForm.date(from: time) ?? Date()
            
            return dfmatter.string(from: date)
            
        }else if cmps.hour! >= 72 {
            return "3天前"
        }else if cmps.hour! >= 48{
            return "前天"
        }else if cmps.hour! >= 24{
            return "昨天"
        }else if cmps.hour! >= 1{
            return "\(cmps.hour!)小时前"
        }else if cmps.minute! >= 1{
            return "\(cmps.minute!)分钟前"
        }else{
            if let second = cmps.second,second > 0 {
                return "\(second)秒前"
            }else{
                return "1秒前"
            }
        }
        
    }

    func setAttributed(changeString: String,originString: String,color:String,font:CGFloat) -> NSMutableAttributedString{
        let attrubuteStr = NSMutableAttributedString(string: originString)
        
        let nsString = NSString(string: originString)
        let range = nsString.range(of: changeString)
        
        attrubuteStr.addAttribute(NSAttributedString.Key.font, value:  UIFont.systemFont(ofSize: font), range: range)
        attrubuteStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hexString: "\(color)")!, range: range)
        
        
        return attrubuteStr
    }
    
    func getContentAttribute(text: String,fontSize: CGFloat,textColor: UIColor,lineSpacing: CGFloat = 3) -> NSAttributedString {
        // 标签显示
        let para = NSMutableParagraphStyle.init()
        para.lineSpacing = lineSpacing
        para.lineBreakMode = .byTruncatingTail
        para.alignment = .justified
        let attribute = NSMutableAttributedString.init()
        attribute.append(NSMutableAttributedString.init(string: text,
                                                        attributes: [NSMutableAttributedString.Key.font: UIFont.et.font(size: fontSize),
                                                                     NSMutableAttributedString.Key.foregroundColor: textColor]
        ))
        return attribute
    }
  
    func TopViewController() -> UIViewController {
        return topViewControllerWithRootViewController(rootViewContrller: (UIApplication.shared.keyWindow?.rootViewController)!)
    }
    func topViewControllerWithRootViewController(rootViewContrller: UIViewController) -> UIViewController {
        if rootViewContrller.isKind(of: UITabBarController.self) {
            let tabbar: UITabBarController = (rootViewContrller as? UITabBarController)!
            return topViewControllerWithRootViewController(rootViewContrller:tabbar.selectedViewController!)
        }else if rootViewContrller.isKind(of: UINavigationController.self) {
            let navi : UINavigationController = (rootViewContrller as? UINavigationController)!
            return topViewControllerWithRootViewController(rootViewContrller:navi.visibleViewController!)
        }else if (rootViewContrller.presentedViewController != nil) {
            let root : UIViewController = rootViewContrller.presentedViewController!
            return topViewControllerWithRootViewController(rootViewContrller:root)
        }else {
            return rootViewContrller
        }
    }
    
    func getTime() -> Int {
        //获取当前时间
        let now = NSDate()
        
        //当前时间的时间戳
        let timeInterval:TimeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        return timeStamp
    }
    
    func getOrientation() -> UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }
    // 字符串数组转json字符串
    func stringFromArr(from object: Any) -> String? {
        if let objectData = try? JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions(rawValue: 0)) {
            let objectString = String(data: objectData, encoding: .utf8)
            return objectString
        }
        return nil
    }
    
    func getRefreshState(page: Paging,datas: [Any]) -> RefreshState {
        if page == .refresh {
            if datas.count == 0 {
                return .empty
            }else if datas.count < 10{
                return .noMoreData
            }else{
                return .idle
            }
        }else{

            if datas.count < 10 {
                return .noMoreData
            }else{
                return .idle
            }
        }
    }
    
    func cacheReleaseImage(imgInfo: ReleasePhotoModel,cachePath: CacheImgPath) -> String? {
        let manager = FileManager.default
        let file = "/Library/\(cachePath.rawValue)_\(UserManager.shared.userId)/"
        let basefile = NSHomeDirectory() + file
        if !manager.fileExists(atPath: basefile) {
            try? manager.createDirectory(atPath: basefile, withIntermediateDirectories: true, attributes: nil)
        }
        let imageName = imgInfo.photoKey.components(separatedBy: "/").last ?? "\(Tool.shared.getTime())"
        let imagePath = basefile + imageName
        if !manager.fileExists(atPath: imagePath) {
            do {
                try imgInfo.image?.pngData()?.write(to: URL(fileURLWithPath: imagePath))
                return file + imageName
            }catch {
                return nil
            }
        }else{
            return file + imageName
        }
    }
    
    func loadCacheImage(filePath: String) -> UIImage? {
        let path = NSHomeDirectory() + filePath
        let manager = FileManager.default
        if manager.fileExists(atPath: path) {
            let fileData = try? Data.init(contentsOf: URL(fileURLWithPath: path))
            if let data = fileData {
                let image = UIImage.init(data: data)
                return image
            }else{
                return nil
            }
        }
        return nil
    }
    
    func removeCacheImage(cachePath: CacheImgPath) {
        let path = NSHomeDirectory() + "/Library/\(cachePath.rawValue)_\(UserManager.shared.userId)/"
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            }catch {
                printLog("移除失败")
            }
        }
    }
    
    func removeCacheImageItem(cachePath: CacheImgPath,item: ReleasePhotoModel) {
        if let imageName = item.photoKey.components(separatedBy: "/").last {
            let path = NSHomeDirectory() + "/Library/\(cachePath.rawValue)_\(UserManager.shared.userId)/\(imageName)"
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                }catch {
                    printLog("移除失败")
                }
            }
        }
        
    }
}


