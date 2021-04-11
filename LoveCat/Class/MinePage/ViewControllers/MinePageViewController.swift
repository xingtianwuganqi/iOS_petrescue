//
//  MinePageViewController.swift
//  LoveCat
//
//  Created by jingjun on 2020/10/30.
//

import UIKit
import RxSwift
import RxDataSources
import ReactorKit
import HBDNavigationBar

class MinePageViewController: BaseViewController,View {
    
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
    
    lazy var headView : AccountHeaderView = {
        let backview = AccountHeaderView(frame: CGRect(x: 0, y: 0, width: ScreenW, height: AccountHeaderView.backHeight))
        return backview
    }()
    
    typealias Reactor = MineViewReactor
    
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
            self.reactor = MineViewReactor.init()
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "我的"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: button)
        button.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            UserManager.shared.lazyAuthToDoThings {
                self.naviService.navigatorSubject.onNext(.settingPage)
            }
        }).disposed(by: disposeBag)
        
        self.hbd_barAlpha = 0
        self.hbd_barStyle = .black
        self.hbd_tintColor = .white
        self.hbd_titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.color(.title)!.withAlphaComponent(0.0)]
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        self.view.addSubview(self.tableview)
        self.tableview.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.bottom.equalToSuperview()
        }
        self.tableview.tableHeaderView = headView
        tableview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: SystemNavigationBarHeight, right: 0)
    }
    
    override func scrollViewInstance() -> UIScrollView? {
        return self.tableview
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
}
extension MinePageViewController: UITableViewDelegate {
    func bind(reactor: MineViewReactor) {
        
//        rx.viewDidLoad.map {
//            Reactor.Action.uploadUnread
//        }.bind(to: reactor.action)
//        .disposed(by: disposeBag)
        
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
                if title == "浏览记录" {
                    UserManager.shared.lazyAuthToDoThings {
                        self.naviService.navigatorSubject.onNext(.myCollectionList)
                    }
                }else if title == "我的发布" {
                    UserManager.shared.lazyAuthToDoThings {
                        self.naviService.navigatorSubject.onNext(.publishMain(type: .publish))
                    }
                }else if title == "我的收藏" {
                    UserManager.shared.lazyAuthToDoThings {
                        self.naviService.navigatorSubject.onNext(.publishMain(type: .collection))
                    }
                }else if title == "我的消息" {
                    UserManager.shared.lazyAuthToDoThings {
                        self.naviService.navigatorSubject.onNext(.messagePage(popBack: {
//                            self.reactor?.action.onNext(.uploadUnread)
                        }))
                    }
                }
                else if title == "意见反馈" {
                    UserManager.shared.lazyAuthToDoThings {
                        self.naviService.navigatorSubject.onNext(.suggestion)
                    }
                }else if title == "检测更新" {
                    if let appid = Bundle.main.infoDictionary?["RescueAppID"] as? String {
                        let appUrl = "itms-apps://itunes.apple.com/cn/app/\(appid)?mt=8"
                        UIApplication.shared.open(URL(string: appUrl)!, options: [:], completionHandler: nil)
                    }
                    
                }else if title == "应用评分" {
                    if let appid = Bundle.main.infoDictionary?["RescueAppID"] as? String {
                        let appUrl = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(appid)&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"
                            UIApplication.shared.open(URL(string: appUrl)!, options: [:], completionHandler: nil)
                    }
                    
                }else if title == "关于我们" {
                    self.naviService.navigatorSubject.onNext(.webProtocalPage(url: baseUrlConfig.rawValue + UserProtocal.aboutUs.rawValue))
                }else if title == "隐私政策" {
                    self.naviService.navigatorSubject.onNext(.webProtocalPage(url: baseUrlConfig.rawValue + UserProtocal.pravicy.rawValue))

                }else if title == "用户协议" {
                    self.naviService.navigatorSubject.onNext(.webProtocalPage(url: baseUrlConfig.rawValue + UserProtocal.userAgreen.rawValue))
                }
            case .logoutItem:
                guard UserManager.shared.isLogin else {
                    return
                }
                UserManager.shared.logout()
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.userInfo
        }.subscribe(onNext: { [weak self] info in
            guard let `self` = self else { return }
            self.headView.cellModel = info
        }).disposed(by: disposeBag)
        
        UserManager.shared.userSubject.subscribe(onNext: { [weak self] info in
            guard let `self` = self else { return }
            self.reactor?.action.onNext(.reloadUserInfo(info))
        }).disposed(by: disposeBag)
        
        self.headView.infoView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                UserManager.shared.lazyAuthToDoThings {
                    self.naviService.navigatorSubject.onNext(.userEdit(fromType: 0))
                }
        }).disposed(by: disposeBag)
        
//        reactor.state.map {
//            $0.unreadNum
//        }.subscribe(onNext: { number in
//            if let num = number {
//                AppHelper.shared.unreadNum.onNext(num)
//            }
//        }).disposed(by: disposeBag)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        printLog(scrollView.contentOffset.y)
        self.headView.scrollVieDidScroll(offsetY: scrollView.contentOffset.y)
        
        var headerHeight = self.headView.frame.size.height
        if #available(iOS 11, *) {
            headerHeight -= self.view.safeAreaInsets.top
        }else{
            headerHeight -= self.topLayoutGuide.length
        }
        let progress = scrollView.contentOffset.y + scrollView.contentInset.top
        var gradientProgress = min(1, max(0,progress / headerHeight))
        gradientProgress = gradientProgress * gradientProgress * gradientProgress * gradientProgress;
        if gradientProgress != self.gradientProgress {
            self.gradientProgress = gradientProgress
            if (self.gradientProgress ?? 0) < 0.1 {
                self.hbd_barStyle = .black
                self.hbd_tintColor = .white
                self.hbd_titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.0)]
            }else{
                self.hbd_barStyle = .default
                self.hbd_tintColor = .black
                self.hbd_titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.color(.title)!.withAlphaComponent(self.gradientProgress ?? 0)]
            }
            self.hbd_barAlpha = Float(self.gradientProgress ?? 0)
            self.hbd_setNeedsUpdateNavigationBar()
            
            if self.gradientProgress ?? 0 >= 0.3 {
                self.button.isSelected = true
            }else{
                self.button.isSelected = false
            }
        }
    }
}
