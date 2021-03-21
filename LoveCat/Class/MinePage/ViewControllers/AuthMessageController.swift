//
//  AuthMessageController.swift
//  LoveCat
//
//  Created by jingjun on 2021/2/3.
//

import UIKit
import ReactorKit
import RxDataSources
class AuthMessageController: BaseViewController,View, UIScrollViewDelegate {
    typealias Reactor = AuthMessageReactor
    lazy var tableview : UITableView = {
        let tableview = UITableView(frame: .zero, style: UITableView.Style.grouped)
        tableview.estimatedRowHeight = 0
        tableview.estimatedSectionFooterHeight = 0
        tableview.estimatedSectionHeaderHeight = 0
        tableview.showsVerticalScrollIndicator = false
        tableview.showsHorizontalScrollIndicator = false
        tableview.separatorStyle = .none
        tableview.backgroundColor = UIColor.color(.defIcon)
        tableview.register(MessageListCell.self, forCellReuseIdentifier: "MessageListCell")
        return tableview
    }()
    
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<MessageListSection>!
    fileprivate var popBack: (() -> Void)?
    init(navi: NavigatorServiceType,popBack: (() -> Void)?) {
        super.init(navi: navi)
        self.popBack = popBack
        dataSource = self.dataSourceFactory()
        defer {
            self.reactor = AuthMessageReactor.init()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "我的消息"
    }
    
    func dataSourceFactory() -> RxTableViewSectionedReloadDataSource<MessageListSection> {
        return RxTableViewSectionedReloadDataSource<MessageListSection>.init { (dataSource, tableView, indexPath, items) -> UITableViewCell in
            switch items {
            case .messageItem(let react):
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessageListCell", for: indexPath) as! MessageListCell
                cell.reactor = react
                return cell
            }
        }
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
        return true
    }
    
    override func hasFooterRefresh() -> Bool {
        return true
    }
    
    override func retryNewData() {
        super.retryNewData()
        reactor?.action.onNext(.loadData(.refresh))
    }
    
    override func refreshNetWorking(page: Paging) {
        reactor?.action.onNext(.loadData(page))
    }

}
extension AuthMessageController: UITableViewDelegate{
    func bind(reactor: AuthMessageReactor) {
        rx.viewDidLoad.map {
            Reactor.Action.loadData(.refresh)
        }.bind(to: reactor.action)
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.isLoading
        }.subscribe(onNext: { loading in
            self.isLoading = loading
        }).disposed(by: disposeBag)
        
        tableview.rx.setDelegate(self).disposed(by: disposeBag)
        reactor.state.map {
            $0.section
        }.bind(to: tableview.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.endRefreshing
        }.subscribe(onNext: { status in
            self.tableview.mj_header?.endRefreshing()
            self.tableview.mj_footer?.et.setRefState(state: status)
        }).disposed(by: disposeBag)
        
        rx.viewWillDisappear.subscribe(onNext: { _ in
            self.popBack?()
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
}
