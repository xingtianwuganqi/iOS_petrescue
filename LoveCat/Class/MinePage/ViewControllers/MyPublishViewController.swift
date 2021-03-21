//
//  MyPublishViewController.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/6.
//

import UIKit
import ReactorKit
import RxDataSources

class MyPublishViewController: BaseViewController,View {

    typealias Reactor = MyPublishReactor
    
    lazy var tableview : UITableView = {
        let tableview = UITableView(frame: .zero, style: UITableView.Style.grouped)
        tableview.estimatedRowHeight = 0
        tableview.estimatedSectionFooterHeight = 0
        tableview.estimatedSectionHeaderHeight = 0
        tableview.showsVerticalScrollIndicator = false
        tableview.showsHorizontalScrollIndicator = false
        tableview.separatorStyle = .none
        tableview.backgroundColor = UIColor.color(.defIcon)
        tableview.register(MyCollectionCell.self, forCellReuseIdentifier: "MyCollectionCell")
        return tableview
    }()
    
    fileprivate let dataSource: RxTableViewSectionedReloadDataSource<HomePageSection>
    private static func dataSourceFactory() -> RxTableViewSectionedReloadDataSource<HomePageSection>
    {
        return RxTableViewSectionedReloadDataSource<HomePageSection>.init { (dataSource, tableView, indexPath, items) -> UITableViewCell in
            switch items {
            case .homepageItem(let reactor):
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyCollectionCell", for: indexPath) as! MyCollectionCell
                cell.reactor = reactor
                return cell
            }
        }
    }
    
    init(navi: NavigatorServiceType,type: PageType? = nil) {
        dataSource = Self.dataSourceFactory()
        super.init(navi: navi)
        defer {
            self.reactor = MyPublishReactor.init()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "浏览记录"
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        self.view.addSubview(tableview)
        tableview.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.bottom.equalToSuperview()
        }
    }
    override func scrollViewInstance() -> UIScrollView? {
        return self.tableview
    }
    override func hasHeadRefresh() -> Bool {
        return false
    }
    override func hasFooterRefresh() -> Bool {
        return false
    }
    
    override func refreshNetWorking(page: Paging) {
        self.reactor?.action.onNext(.loadPubLishData(page))
    }
    
    override func retryNewData() {
        super.retryNewData()
        self.reactor?.action.onNext(.loadPubLishData(.refresh))
    }
}
extension MyPublishViewController: UITableViewDelegate {
    func bind(reactor: MyPublishReactor) {
        
        reactor.state.map {
            $0.isLoading
        }.subscribe(onNext: { loading in
            self.isLoading = loading
        }).disposed(by: disposeBag)
        
        rx.viewDidLoad.map {
            Reactor.Action.loadPubLishData(.refresh)
        }.bind(to: reactor.action)
        .disposed(by: disposeBag)
        
        tableview.rx.setDelegate(self).disposed(by: disposeBag)
        
        reactor.state.map{
            $0.section
        }.bind(to: tableview.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
        
        tableview.rx.itemSelected.subscribe(onNext: { index in
            guard let data = self.reactor?.currentState.section.first?.items[index.row] else {
                return
            }
            switch data {
            case .homepageItem(let reac):
                if let topicId = reac.currentState.model?.topic_id {
                    self.naviService.navigatorSubject.onNext(.topicDetail(topicId: topicId, changeBlock: nil))
                }
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.endRefreshing
        }.subscribe(onNext: { status in
            guard let status = status else {
                return
            }
            self.tableview.mj_header?.endRefreshing()
            self.tableview.mj_footer?.et.setRefState(state: status)
        }).disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction.init(style: .default, title: "已完成") { (action, indexPath) in
            let alert = UIAlertController.init(title: nil, message: "左滑点击完成，即代表宠物已被领养，他人将无法获取你的联系方式，确定完成吗", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (_) in
                tableView.setEditing(false, animated: true)
//                self?.deleteAction(indexPath: indexPath)
            }))
            
            alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { (_) in
//                alert.dismissAlertViewController()
            }))
            self.present(alert, animated: true, completion: nil)
        }
        return [action]
    }
    
    // iOS 11及 之后的方法
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cancelAction = UIContextualAction(style: .normal, title: "已完成") {[weak self] (action, view, completion) in
            tableView.setEditing(false, animated: true)
            completion(true)
            
            let alert = UIAlertController.init(title: nil, message: "左滑点击完成，即代表完成领养，他人将无法获取你的联系方式，确定完成吗", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (_) in
                tableView.setEditing(false, animated: true)
//                self?.deleteAction(indexPath: indexPath)
            }))
            
            alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { (_) in
//                alert.dismissAlertViewController()
            }))
            self?.present(alert, animated: true, completion: nil)
        }
        cancelAction.backgroundColor = rgb(255,49,75)
        let config = UISwipeActionsConfiguration(actions: [cancelAction])
        
        // 禁止侧滑无线拉伸
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}
