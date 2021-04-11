//
//  MessageListController.swift
//  LoveCat
//
//  Created by jingjun on 2021/3/29.
//

import UIKit
import ReactorKit
import RxDataSources

enum MsgType: Int {
    /*
     like: 点赞
     collect: 收藏
     comment: 评论
     */
    case like = 1
    case collect
    case comment
}

class MessageListController: BaseViewController,View {
    
    typealias Reactor = MessageListReactor
    
    lazy var tableview : UITableView = {
        let tableview = UITableView(frame: .zero, style: UITableView.Style.grouped)
        tableview.estimatedRowHeight = 0
        tableview.estimatedSectionFooterHeight = 0
        tableview.estimatedSectionHeaderHeight = 0
        tableview.showsVerticalScrollIndicator = false
        tableview.showsHorizontalScrollIndicator = false
        tableview.separatorStyle = .none
        tableview.backgroundColor = UIColor.color(.defIcon)
        tableview.register(MessageCommonListCell.self, forCellReuseIdentifier: "MessageCommonListCell")
        return tableview
    }()
    var dataSource: RxTableViewSectionedReloadDataSource<MessageCommonSection>!
    
    private func configTableView() -> RxTableViewSectionedReloadDataSource<MessageCommonSection>  {
        return RxTableViewSectionedReloadDataSource<MessageCommonSection>.init { (dataSource, tableView, index, items) -> UITableViewCell in
            switch items {
            case .CommonItem(let react):
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCommonListCell", for: index) as! MessageCommonListCell
                cell.reactor = react
                return cell
            }
        }
    }
    var readedBlock: (() -> Void)?
    init(navi: NavigatorServiceType,msgType: MsgType,readedBlock: (() -> Void)?) {
        super.init(navi: navi)
        self.dataSource = self.configTableView()
        self.readedBlock = readedBlock
        defer {
            self.reactor = MessageListReactor.init(msgType: msgType)
            switch msgType {
            case .like:
                self.title = "点赞"
            case .collect:
                self.title = "收藏"
            case .comment:
                self.title = "评论"
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
        reactor?.action.onNext(.reloadData(page: .refresh))
    }
    
    override func refreshNetWorking(page: Paging) {
        reactor?.action.onNext(.reloadData(page: .refresh))
    }

}
extension MessageListController {
    func bind(reactor: Reactor) {
        
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
        
        tableview.rx.itemSelected.subscribe(onNext: { index in
            guard let model = self.reactor?.currentState.dataModels[index.row] else {
                return
            }
            if model.msg_type == 1 || model.msg_type == 2 || model.msg_type == 3 || model.msg_type == 4 {
                self.naviService.navigatorSubject.onNext(.topicDetail(topicId: model.topicInfo?.topic_id ?? 0, model: nil, changeBlock: nil))
            }else{
                self.naviService.navigatorSubject.onNext(.showInfoPage(type: .showInfoList, gambitId: nil, showId: model.showInfo?.show_id))
            }
        }).disposed(by: disposeBag)
        
        rx.viewDidLoad.map {
            Reactor.Action.reloadData(page: .refresh)
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

        rx.viewWillDisappear.subscribe(onNext: { _ in
            self.readedBlock?()
        }).disposed(by: disposeBag)
    }
}

extension MessageListController: UITableViewDelegate  {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
