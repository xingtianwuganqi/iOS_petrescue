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
