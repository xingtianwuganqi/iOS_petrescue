//
//  StringExtension.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/16.
//

import Foundation
import CommonCrypto

extension String: ETExtensionCompatible {

}

extension ET where Base: ExpressibleByStringLiteral {
    
    var isChinaMobile: Bool {
//        let phoneRegex = "^((13[0-9])|(16[0-9])|(19[0-9])|(17[0-9])|(14[^4,\\D])|(15[^4,\\D])|(18[0-9]))\\d{8}$|^1(7[0-9])\\d{8}$";
//        let phoneTest = NSPredicate(format: "SELF MATCHES %@" , phoneRegex)
//        return phoneTest.evaluate(with: self)
        let str = base as! String
        return str.count == 11
    }
    
    var isMobile: Bool {
//        let phoneRegex = "^((13[0-9])|(17[0-9])|(14[^4,\\D])|(15[^4,\\D])|(18[0-9]))\\d{8}$|^1(7[0-9])\\d{8}$";
//        let phoneTest = NSPredicate(format: "SELF MATCHES %@" , phoneRegex)
//        return phoneTest.evaluate(with: self)
        return (base as! String).count >= 3
    }
    
    var isValidPassword : Bool {
        return (base as! String).count >= 6
    }
    
    var isValidNickname : Bool {
        return (base as! String).count > 0
    }
    
    var isValidEmail: Bool {
        // http://emailregex.com/
        let regex = "^(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])$"
        return (base as! String).range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    public static func random(ofLength length: Int) -> String {
        guard length > 0 else { return "" }
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString = ""
        for _ in 1...length {
            let randomIndex = Int.random(in: 0..<base.count)
            let randomCharacter = base.et.charactersArray[Int(randomIndex)]
            randomString.append(randomCharacter)
        }
        return randomString
    }
    
    /// SwifterSwift: Array of characters of a string.
    public var charactersArray: [Character] {
        return Array((base as! String))
    }
    
    /*
     *去掉首尾空格
     */
    var removeHeadAndTailSpace:String {
        let whitespace = NSCharacterSet.whitespaces
        return (base as! String).trimmingCharacters(in: whitespace)
    }
    /*
     *去掉首尾空格 包括后面的换行 \n
     */
    var removeHeadAndTailSpacePro:String {
        let whitespace = NSCharacterSet.whitespacesAndNewlines
        return (base as! String).trimmingCharacters(in: whitespace)
    }
    /*
     *去掉所有空格
     */
    var removeAllSapce: String {
        return (base as! String).replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
    }
    /*
     *去掉首尾空格 后 指定开头空格数
     */
    func beginSpaceNum(num: Int) -> String {
        var beginSpace = ""
        for _ in 0..<num {
            beginSpace += " "
        }
        return beginSpace + self.removeHeadAndTailSpacePro
    }
    
    var md5String: String {
        let str = (base as! String)
        let utf8 = str.cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02X", $1) }
    }
    
    //MARK:截取字符串
    func subStringWith(startIndex: Int,endIndex: Int) -> String{
        let startIndex = (base as! String).index((base as! String).startIndex, offsetBy: 0)
        let endIndex = (base as! String).index((base as! String).startIndex, offsetBy: endIndex)
        let resultStr = (base as! String)[startIndex ... endIndex]
        return String(resultStr)
    }
}
