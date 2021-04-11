//
//  SystemMessageController.swift
//  LoveCat
//
//  Created by jingjun on 2021/4/2.
//

import UIKit
import ReactorKit
import RxDataSources
class SystemMessageController: BaseViewController,View {
    
    typealias Reactor = SystemMessageReactor
    
    lazy var tableview : UITableView = {
        let tableview = UITableView(frame: .zero, style: UITableView.Style.grouped)
        tableview.estimatedRowHeight = 0
        tableview.estimatedSectionFooterHeight = 0
        tableview.estimatedSectionHeaderHeight = 0
        tableview.showsVerticalScrollIndicator = false
        tableview.showsHorizontalScrollIndicator = false
        tableview.separatorStyle = .none
        tableview.backgroundColor = UIColor.color(.defIcon)
        tableview.register(SystemMsgCell.self, forCellReuseIdentifier: "SystemMsgCell")
        return tableview
    }()
    
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<SystemMessageSection>!
    
    private func configTableView() -> RxTableViewSectionedReloadDataSource<SystemMessageSection>  {
        return RxTableViewSectionedReloadDataSource<SystemMessageSection>.init { (dataSource, tableView, index, items) -> UITableViewCell in
            switch items {
            case .sysItem(let reac):
                let cell = tableView.dequeueReusableCell(withIdentifier: "SystemMsgCell", for: index) as! SystemMsgCell
                cell.reactor = reac
                return cell
            }
        }
    }
    fileprivate var readedBlock: (() -> Void)?
    init(navi: NavigatorServiceType,readedBlock: (() -> Void)?) {
        super.init(navi: navi)
        self.dataSource = self.configTableView()
        self.readedBlock = readedBlock
        defer {
            self.reactor = SystemMessageReactor.init()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.color(.defIcon)
        self.title = "系统消息"
    }
    
    override func setupConstraints() {
        self.view.addSubview(self.tableview)
        self.tableview.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
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
        reactor?.action.onNext(.reloadData(.refresh))
    }
    
    override func refreshNetWorking(page: Paging) {
        reactor?.action.onNext(.reloadData(page))
    }
    
}
extension SystemMessageController {
    func bind(reactor: Reactor) {
        
        reactor.state.map {
            $0.isLoading
        }.subscribe(onNext: { [weak self] loading in
            guard let `self` = self else { return }
            self.isLoading = loading
        }).disposed(by: disposeBag)
        
        tableview.rx.setDelegate(self).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.section
        }.bind(to: tableview.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
        
        rx.viewDidLoad.map {
            Reactor.Action.reloadData(.refresh)
        }.bind(to: reactor.action)
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.endRefreshing
        }.subscribe(onNext: { [weak self] state in
            guard let `self` = self else { return }
            guard let value = state else {
                return
            }
            self.tableview.mj_header?.endRefreshing()
            self.tableview.mj_footer?.et.setRefState(state: value)
            
        }).disposed(by: disposeBag)
        
        tableview.rx.itemSelected.subscribe(onNext: { index in
            switch index.section {
            case 0:
                break;
            default:
                return
            }
        }).disposed(by: disposeBag)
        
        rx.viewWillDisappear.subscribe(onNext: { _ in
            self.readedBlock?()
        }).disposed(by: disposeBag)
    }
}

extension SystemMessageController: UITableViewDelegate  {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
