//
// RTExtensionCompatible.swift
// rebate
//
// Created by xiaoyuan on 2020/2/17.
// Copyright © 2020 寻宝天行. All rights reserved.
//

import Foundation

public struct ET<Base> {
    // 要扩展的基础对象
    public let base: Base
    init(_ base: Base) {
        self.base = base
    }
}

// 利用协议扩展类、结构体、对象的前缀属性
public protocol ETExtensionCompatible {
    associatedtype ComplatibleType
    // 实现此协议的类或者class的对象 可以直接调用 .rt，比如"123".rt
    var et: ET<ComplatibleType> { get set }
    // 实现此协议的类或者class 可以直接调用 .rt，比如String.rt
    static var et: ET<ComplatibleType>.Type { get set }
}
public extension ETExtensionCompatible {
    
    var et: ET<Self> {
        set {} // 原本使用计算属性就够了，但是为了让我们可以以后使用mutating声明的可变对象
        get {
            ET<Self>(self)
        }
    }
    
    static var et: ET<Self>.Type {
        set {} // 原本使用计算属性就够了，但是为了让我们可以以后使用mutating声明的可变对象
        get {
            ET<Self>.self
        }
    }
    
}
