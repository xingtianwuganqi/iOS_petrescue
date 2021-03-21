//
//  SettingViewController.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/7.
//

import UIKit
import ReactorKit
import RxDataSources

class SettingViewController: BaseViewController, View {
    typealias Reactor = SettingViewReactor
    
    lazy var button : UIButton = {
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "icon_mi_setting"), for: .selected)
        button.setImage(UIImage(named: "icon_b_setting"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        return button
    }()
    
    lazy var tableview : UITableView = {
        let tableview = UITableView(frame: .zero, style: UITableView.Style.grouped)
        tableview.estimatedRowHeight = 0
        tableview.estimatedSectionFooterHeight = 0
        tableview.estimatedSectionHeaderHeight = 0
        tableview.showsVerticalScrollIndicator = false
        tableview.showsHorizontalScrollIndicator = false
        tableview.separatorStyle = .none
        tableview.register(MinePageCell.self, forCellReuseIdentifier: "MinePageCell")
        tableview.register(LogoutCell.self, forCellReuseIdentifier: "LogoutCell")
        tableview.backgroundColor = UIColor.color(.defIcon)
        return tableview
    }()
    
    fileprivate let dataSource : RxTableViewSectionedReloadDataSource<MinePageSection>
    private static func dataSourceFactory() -> RxTableViewSectionedReloadDataSource<MinePageSection> {
        return RxTableViewSectionedReloadDataSource<MinePageSection>.init { (dataSource, tableView, indexPath, items) -> UITableViewCell in
            switch items {
            case .topItem:
                return UITableViewCell()
            case .defaultItem(let reactor):
                let cell = tableView.dequeueReusableCell(withIdentifier: "MinePageCell", for: indexPath) as! MinePageCell
                cell.reactor = reactor
                return cell
            case .logoutItem:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LogoutCell", for: indexPath)
                return  cell
            }
        }
    }
    var gradientProgress: CGFloat?
    
    override init(navi: NavigatorServiceType) {
        dataSource = Self.dataSourceFactory()
        super.init(navi: navi)
        defer {
            self.reactor = SettingViewReactor.init()
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "设置"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: button)
        button.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            UserManager.shared.lazyAuthToDoThings {
                self.naviService.navigatorSubject.onNext(.settingPage)
            }
        }).disposed(by: disposeBag)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        self.view.addSubview(self.tableview)
        self.tableview.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
}
extension SettingViewController: UITableViewDelegate {
    func bind(reactor: SettingViewReactor) {
        tableview.rx.setDelegate(self).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.listData
        }.bind(to: tableview.rx.items(dataSource:dataSource))
        .disposed(by: disposeBag)
        
        tableview.rx.itemSelected.subscribe(onNext: { [weak self] index in
            guard let `self` = self else { return }
            
            guard let item = self.reactor?.currentState.listData[index.section].items[index.row] else {
                return
            }
            
            
            switch item {
            case .topItem:
                break
            case .defaultItem(let itemReactor):
                guard let title = itemReactor.currentState.model.title else {
                    return
                }
                if title == "我的发布" {
                    UserManager.shared.lazyAuthToDoThings {
                        self.naviService.navigatorSubject.onNext(.myPushList)
                    }
                }else if title == "我的收藏" {
                    UserManager.shared.lazyAuthToDoThings {
                        self.naviService.navigatorSubject.onNext(.myCollectionList)
                    }
                }else if title == "检测更新" {
                    
                }else if title == "隐私政策" {
                    self.naviService.navigatorSubject.onNext(.webProtocalPage(url: baseUrlConfig.rawValue + UserProtocal.pravicy.rawValue))

                }else if title == "用户协议" {
                    self.naviService.navigatorSubject.onNext(.webProtocalPage(url: baseUrlConfig.rawValue + UserProtocal.userAgreen.rawValue))
                }else if title == "意见反馈" {
                    self.naviService.navigatorSubject.onNext(.suggestion)
                }else if title == "修改密码" {
                    self.naviService.navigatorSubject.onNext(.settingChangePswd)
                }
            case .logoutItem:
                guard UserManager.shared.isLogin else {
                    return
                }
                JPUSHService.deleteAlias({ (_, _, _) in
                    
                }, seq: 0)
                UserManager.shared.logout()
            }
        }).disposed(by: disposeBag)
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}
