//
//  URLExtension.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/4.
//

import Foundation

extension URL {
    /// @param ignoreEncodedCharacters 除了url里面的#不进行encoding，其他该转码的都会被encoing, 比如防止url中的#被转码成了%23
    init?(string: String, ignoreEncodedCharacters: [String]?) {
        var charSet = CharacterSet.urlQueryAllowed
        ignoreEncodedCharacters?.forEach({ (char) in
            charSet.insert(charactersIn: char)
        })
        //        charSet.insert(charactersIn: "#")
        let encodingStr = string.addingPercentEncoding(withAllowedCharacters: charSet ) ?? string
        self.init(string: encodingStr)
    }

}
