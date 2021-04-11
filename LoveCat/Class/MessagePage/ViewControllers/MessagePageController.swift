//
//  MessagePageController.swift
//  LoveCat
//
//  Created by jingjun on 2021/3/22.
//

import UIKit
import ReactorKit
import RxDataSources
class MessagePageController: BaseViewController,View {
    
    typealias Reactor = MessagePageReactor
    
    lazy var tableview : UITableView = {
        let tableview = UITableView(frame: .zero, style: UITableView.Style.grouped)
        tableview.estimatedRowHeight = 0
        tableview.estimatedSectionFooterHeight = 0
        tableview.estimatedSectionHeaderHeight = 0
        tableview.showsVerticalScrollIndicator = false
        tableview.showsHorizontalScrollIndicator = false
        tableview.separatorStyle = .none
        tableview.backgroundColor = UIColor.white
        tableview.register(MessagePageCell.self, forCellReuseIdentifier: "MessagePageCell")
        return tableview
    }()
    
    var dataSource: RxTableViewSectionedReloadDataSource<MessagePageSection>!
    
    private func configTableView() -> RxTableViewSectionedReloadDataSource<MessagePageSection>  {
        return RxTableViewSectionedReloadDataSource<MessagePageSection>.init { (dataSource, tableView, index, items) -> UITableViewCell in
            switch items {
            case .sysMsgItem(let react):
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessagePageCell", for: index) as! MessagePageCell
                cell.reactor = react
                return cell
            case .chartMsgItem:
                return UITableViewCell()
            }
        }
    }
    
    override init(navi: NavigatorServiceType) {
        super.init(navi: navi)
        self.dataSource = self.configTableView()
        defer {
            self.reactor = MessagePageReactor.init()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "消息"
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
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
        return false
    }
    
    override func retryNewData() {
        super.retryNewData()
        reactor?.action.onNext(.reloadMessageNum)
    }
    
    override func refreshNetWorking(page: Paging) {
        reactor?.action.onNext(.reloadMessageNum)
    }

    @objc func didBecomeActive() {
        reactor?.action.onNext(.reloadMessageNum)
    }

}
extension MessagePageController {
    func bind(reactor: Reactor) {
        tableview.rx.setDelegate(self).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.section
        }.bind(to: tableview.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
        
        rx.viewDidLoad.map {
            Reactor.Action.reloadMessageNum
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
        
        tableview.rx.itemSelected.subscribe(onNext: { [weak self] index in
            guard let `self` = self else { return }
            switch index.section {
            case 0:
                let model = reactor.currentState.msgDatas[index.row]
                if model.title == "系统消息" {
                    self.naviService.navigatorSubject.onNext(.sysMsgPage(readedBlock: {
                        self.reactor?.action.onNext(.reloadMessageNum)
                    }))
                }else if model.title == "点赞"{
                    UserManager.shared.lazyAuthToDoThings {
                        self.naviService.navigatorSubject.onNext(.messageList(msg_type: .like, readedBlock: {
                            self.reactor?.action.onNext(.reloadMessageNum)
                        }))
                    }
                }else if model.title == "收藏"{
                    UserManager.shared.lazyAuthToDoThings {
                        self.naviService.navigatorSubject.onNext(.messageList(msg_type: .collect, readedBlock: {
                            self.reactor?.action.onNext(.reloadMessageNum)
                        }))
                    }
                    
                }else if model.title == "评论"{
                    UserManager.shared.lazyAuthToDoThings {
                        self.naviService.navigatorSubject.onNext(.messageList(msg_type: .comment, readedBlock: {
                            self.reactor?.action.onNext(.reloadMessageNum)
                        }))
                    }
                }
            default:
                return
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model
        }.subscribe(onNext: { model in
            var num = 0
            let msg_num = (model?.sys_unread ?? 0) + (model?.like_unread ?? 0)
            let sys_num = (model?.collec_unread ?? 0) + (model?.com_unread ?? 0)
            num = msg_num + sys_num
            if num >= 0 {
                AppHelper.shared.unreadNum.onNext(num)
            }
        }).disposed(by: disposeBag)

        UserManager.shared.loginSuccess.subscribe(onNext: { _ in
            self.reactor?.action.onNext(.reloadMessageNum)
        }).disposed(by: disposeBag)
    }
}

extension MessagePageController: UITableViewDelegate  {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
