//
//  MyCollectionViewController.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/6.
//

import UIKit
import ReactorKit
import RxDataSources

class MyCollectionViewController: BaseViewController ,View{
    
    typealias Reactor = MyCollectionReactor
    
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
    
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<HomePageSection>!
    private func dataSourceFactory() -> RxTableViewSectionedReloadDataSource<HomePageSection>
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
    
    override init(navi: NavigatorServiceType) {
        super.init(navi: navi)
        dataSource = self.dataSourceFactory()
        defer {
            self.reactor = MyCollectionReactor.init()
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
        self.view.addSubview(self.tableview)
        self.tableview.snp.makeConstraints { (make) in
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
        return true
    }
    
    override func refreshNetWorking(page: Paging) {
        self.reactor?.action.onNext(.loadCollectionData(page))
    }
    
    override func retryNewData() {
        self.reactor?.action.onNext(.loadCollectionData(.refresh))
    }
}
extension MyCollectionViewController: UITableViewDelegate {
    func bind(reactor: MyCollectionReactor) {
        
        reactor.state.map {
            $0.isLoading
        }.subscribe(onNext: { loading in
            self.isLoading = loading
        }).disposed(by: disposeBag)
        
        rx.viewDidLoad.map {
            Reactor.Action.loadCollectionData(.refresh)
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
        let action = UITableViewRowAction.init(style: .default, title: "取消收藏") { [weak self] (action, indexPath) in
            guard let `self` = self else { return }
            guard let item = self.reactor?.currentState.section.first?.items[indexPath.row] else {
                return
            }
            switch item {
            case .homepageItem(let reac):
                guard let model = reac.currentState.model else {
                    return
                }
                self.reactor?.action.onNext(.cancelCollection(model))
            }
        }
        return [action]
    }
    
    // iOS 11及 之后的方法
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cancelAction = UIContextualAction(style: .normal, title: "取消收藏") {[weak self] (action, view, completion) in
            tableView.setEditing(false, animated: true)
            completion(true)
            
            guard let item = self?.reactor?.currentState.section.first?.items[indexPath.row] else {
                return
            }
            switch item {
            case .homepageItem(let reac):
                guard let model = reac.currentState.model else {
                    return
                }
                self?.reactor?.action.onNext(.cancelCollection(model))
            }
        }
        cancelAction.backgroundColor = rgb(255,49,75)
        let config = UISwipeActionsConfiguration(actions: [cancelAction])
        
        // 禁止侧滑无线拉伸
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
}
