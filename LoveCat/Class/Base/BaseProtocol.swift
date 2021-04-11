//
//  BaseProtocol.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/28.
//

import Foundation

public protocol HeaderRepresentable {
    var height: CGFloat { get }
    var identifier: String { get }
    func headerView(_ tableView: UITableView, section: Int) -> UITableViewHeaderFooterView?
}

public protocol CellRepresentable {
    var rowHeight: CGFloat { get }
    var cellIdentifier: String { get }
    func cellInstance(_ tableView: UITableView, indexPath: IndexPath, currentController: UIViewController?) -> UITableViewCell
}


enum Paging {
    case refresh
    case next
}

/// 常用状态
protocol StateProtocal {
    var isLoading: Bool {get set}
    var isRefreshing: Bool {get set}
    var endRefreshing: RefreshState? {get set}
    var netError: Bool {get set}
    var errorMsg: String? {get set}
    var page: Int {get set}
}
