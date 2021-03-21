//
//  RefreshViewControllerProtocal.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/15.
//

import Foundation

protocol RefreshViewControllerProtocal {
    func hasHeadRefresh() -> Bool
    func hasFooterRefresh() -> Bool
    // MARK: 重新请求新数据
    func retryNewData()
    // MARK: 上拉刷新和下拉加载调用
    func refreshNetWorking(page: Paging)
}
