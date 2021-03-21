//
//  ColorExtension.swift
//  LoveCat
//
//  Created by jingjun on 2020/10/19.
//

import Foundation
/// r g b a color
func RGBA(_ red: CGFloat = 255.0, _ green: CGFloat = 255.0, _ blue: CGFloat = 255.0, _ alpha: CGFloat = 1) -> UIColor {
    return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
}
func RGB(_ red: CGFloat = 255.0, _ green: CGFloat = 255.0, _ blue: CGFloat = 255.0) -> UIColor {
    return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
}
func rgb(_ red: CGFloat = 255.0, _ green: CGFloat = 255.0, _ blue: CGFloat = 255.0) -> UIColor {
    return RGB(red, green, blue)
}

///随机色
func RandomColor() ->  UIColor{
    let r = Int(arc4random_uniform(255))
    let g = Int(arc4random_uniform(255))
    let b = Int(arc4random_uniform(255))
    return RGBA(CGFloat(r), CGFloat(g), CGFloat(b))
}



extension UIColor {
    ///16进制转rgb
    public convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var formatted = hexString.replacingOccurrences(of: "0x", with: "")
        formatted = formatted.replacingOccurrences(of: "#", with: "")
        if let hex = Int(formatted, radix: 16) {
            let red = CGFloat(CGFloat((hex & 0xFF0000) >> 16)/255.0)
            let green = CGFloat(CGFloat((hex & 0x00FF00) >> 8)/255.0)
            let blue = CGFloat(CGFloat((hex & 0x0000FF) >> 0)/255.0)
            self.init(red: red, green: green, blue: blue, alpha: alpha)        }
        else {
            return nil
        }
    }
    
    static func color(_ color: ColorEnum, alpha: CGFloat = 1.0) -> UIColor? {
        var formatted = color.rawValue.replacingOccurrences(of: "0x", with: "")
        formatted = formatted.replacingOccurrences(of: "#", with: "")
        if let hex = Int(formatted, radix: 16) {
            let red = CGFloat(CGFloat((hex & 0xFF0000) >> 16)/255.0)
            let green = CGFloat(CGFloat((hex & 0x00FF00) >> 8)/255.0)
            let blue = CGFloat(CGFloat((hex & 0x0000FF) >> 0)/255.0)
            return self.init(red: red, green: green, blue: blue, alpha: alpha)
        }
        else {
            return nil
        }
    }
}

enum ColorEnum : String {
    case system = "#ffa500"  // 系统色，橘色
    case title = "#000000"   // 标题色，纯黑
    case content = "#292929"  // 内容
    case note = "#666666"     //
    case desc = "#8b8b8b"     // 描述
    case mark = "#999999"     // 标记
    case tableBack = "#EDEDED"  //
    case defIcon = "#F5F5F5"    // 列表背景色，默认头像颜色
    case tabbar = "#515151"
    case urlColor = "#4169E1"   // URL 蓝色
}

enum FontSize: CGFloat {
    case big = 20
    case title = 16
    case content = 14
    case desc = 12
    case small = 10
}

enum FontName: String {
    case regular = "PingFangSC-Regular"
    case medium  = "PingFangSC-Medium"
    case bold    = "PingFangSC-Semibold"
}



extension UIFont: ETExtensionCompatible {}

extension ET where Base: UIFont {
    /*
     let Bold    = "PingFangSC-Semibold"
     let Medium  = "PingFangSC-Medium"
     let Regular = "PingFangSC-Regular"
     */
    
    
    static func font(_ name: FontName = .regular,size: CGFloat) -> UIFont {
        if let font = UIFont.init(name: name.rawValue, size: size) {
            return font
        }else{
            return UIFont.systemFont(ofSize: size)
        }
    }
    
    static func fontSize(_ name: FontName = .regular,_ size: FontSize = .content) -> UIFont {
        if let font = UIFont.init(name: name.rawValue, size: size.rawValue) {
            return font
        }else{
            return UIFont.systemFont(ofSize: size.rawValue)
        }
    }

}


extension Float {
    func intValue() -> String  {
        let value = String(format: "%.2f", self)
        let current = (Float(value) ?? 0.0) * 100
        return "\(current)"
    }
}

extension Int {
    var wFormatted: String {
        if self > 10000 {
            let value = Float(self) / 10000
            return String(format: "%.1fw", value)
        }else{
            return "\(self)"
        }
    }
}
