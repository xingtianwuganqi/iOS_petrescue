//
//  HomePageListController.swift
//  LoveCat
//
//  Created by jingjun on 2020/10/19.
//

import UIKit
import RxSwift
import RxCocoa
import RxViewController
import ReactorKit
import RxDataSources
import MJRefresh
import DZNEmptyDataSet

enum HomePageType {
    case homePageList
    case authPublish
    case authCollect
}

class HomePageListController: BaseViewController {
    
    typealias Reactor = HomePageListReactor
    
    lazy var tableview : UITableView = {
        let tableview = UITableView(frame: .zero, style: UITableView.Style.grouped)
        tableview.estimatedRowHeight = 0
        tableview.estimatedSectionFooterHeight = 0
        tableview.estimatedSectionHeaderHeight = 0
        tableview.showsVerticalScrollIndicator = false
        tableview.showsHorizontalScrollIndicator = false
        tableview.separatorStyle = .none
        tableview.backgroundColor = UIColor.color(.defIcon)
        tableview.register(HomePageTableCell.self, forCellReuseIdentifier: "HomePageTableCell")
        return tableview
    }()
    
    lazy var releaseBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "icon_home_write"), for: .normal)
        button.setImage(UIImage(named: "icon_home_write"), for: .highlighted)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 25
        button.backgroundColor = UIColor.color(.system)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        return button
    }()
    
    lazy var searchBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("  搜索", for: .normal)
        button.setTitleColor(UIColor.color(.desc), for: .normal)
        button.titleLabel?.font = UIFont.et.fontSize(.regular, .desc)
        button.backgroundColor = UIColor.color(.defIcon)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 40, height: 30)
        button.setImage(UIImage(named: "icon_wx_search"), for: .normal)
        return button
    }()
        
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<HomePageSection>!
    init(navi: NavigatorServiceType,type: HomePageType = .homePageList) {
        super.init(navi: navi)
        self.dataSource = self.dataSourceFactory()
        defer{
            self.reactor = HomePageListReactor.init(type: type)
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = searchBtn
        if reactor?.currentState.pageType == .authCollect {
            self.titleEmpty = "暂无收藏"
            self.descEmpty = "快去收藏喜欢的宠物吧"
        }else{
            self.titleEmpty = "暂无数据"
            self.descEmpty = "快去发布领养吧"
        }
        
    }
    
    private func dataSourceFactory() -> RxTableViewSectionedReloadDataSource<HomePageSection> {
        return RxTableViewSectionedReloadDataSource<HomePageSection>.init { [weak self] (dataSource, tableView, indexPath, items) -> UITableViewCell in
            guard let `self` = self else { return UITableViewCell() }
            switch items {
            case .homepageItem(let react):
                let cell = tableView.dequeueReusableCell(withIdentifier: "HomePageTableCell", for: indexPath) as! HomePageTableCell
                cell.reactor = react
                cell.moreBtnClick = { model in
                    UserManager.shared.lazyAuthToDoThings {
                        let rect = cell.contentView.convert(cell.moreBtn.frame, to: self.view)
                        self.moreBtnClick(model: model, rect: rect)
                    }
                }
                return cell
            }
        } titleForHeaderInSection: { (dataSource, index) -> String? in
            if self.reactor?.currentState.pageType == .authPublish && index == 0 && (self.reactor?.currentState.dataModels.count ?? 0) > 0 {
                return "点击右上角更多，点击完成领养，即代表宠物已被领养，他人将无法获取你的联系方式"
            }else{
                return nil
            }
        }
    }
    
    override func setupConstraints() {

        releaseBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            UserManager.shared.lazyAuthToDoThings {
                self.naviService.navigatorSubject.onNext(.releaseTopic(result: { (result) in
                    guard result else {
                        return
                    }
                    self.reactor?.action.onNext(.loadList(.refresh))
                }))
            }
        }).disposed(by: disposeBag)
        
        self.view.addSubview(self.tableview)
        tableview.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            if self.reactor?.currentState.pageType == .homePageList {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }else{
                make.bottom.equalToSuperview()
            }
        }
        if self.reactor?.currentState.pageType == .homePageList {
            self.view.addSubview(releaseBtn)
            releaseBtn.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-15)
                make.bottom.equalToSuperview().offset(-(SystemTabBarHeight + 30))
                make.size.equalTo(CGSize(width: 50, height: 50))
            }
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
        if self.reactor?.currentState.pageType == .homePageList {
            self.reactor?.action.onNext(.loadList(.refresh))
        }else if self.reactor?.currentState.pageType == .authPublish {
            self.reactor?.action.onNext(.loadPubLishData(.refresh))
        }else if self.reactor?.currentState.pageType == .authCollect {
            self.reactor?.action.onNext(.loadCollectionData(.refresh))
        }
    }
    
    override func refreshNetWorking(page: Paging) {
        if self.reactor?.currentState.pageType == .homePageList {
            self.reactor?.action.onNext(.loadList(page))
        }else if self.reactor?.currentState.pageType == .authPublish {
            self.reactor?.action.onNext(.loadPubLishData(page))
        }else if self.reactor?.currentState.pageType == .authCollect {
            self.reactor?.action.onNext(.loadCollectionData(page))
        }
    }
}

extension HomePageListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.reactor?.currentState.pageType == .authPublish && section == 0 && (self.reactor?.currentState.dataModels.count ?? 0) > 0 {
            return 50
        }else{
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}
extension HomePageListController: View {
    func bind(reactor: HomePageListReactor) {
        
        reactor.state.map {
            $0.isLoading
        }.subscribe(onNext: { [weak self] loading in
            guard let `self` = self else { return }
            self.isLoading = loading
        })
        .disposed(by: disposeBag)
        
        tableview.rx.setDelegate(self).disposed(by: disposeBag)
        reactor.state.map {
            $0.section
        }.bind(to: tableview.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
        
        rx.viewDidLoad.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            if self.reactor?.currentState.pageType == .homePageList {
                self.reactor?.action.onNext(.loadList(.refresh))
            }else if self.reactor?.currentState.pageType == .authPublish {
                self.reactor?.action.onNext(.loadPubLishData(.refresh))
            }else if self.reactor?.currentState.pageType == .authCollect {
                self.reactor?.action.onNext(.loadCollectionData(.refresh))
            }
        }).disposed(by: disposeBag)
        
        
        tableview.rx.itemSelected.subscribe(onNext: { [weak self] index in
            guard let `self` = self else { return }
            guard let model = self.reactor?.currentState.section.first?.items[index.row] else {
                return
            }
            switch model {
            case .homepageItem(let itemReactor):
                if let model = itemReactor.currentState.model,let topic_id = model.topic_id {
                    
                    self.naviService.navigatorSubject.onNext(.topicDetail(topicId: topic_id, model: model, changeBlock: { model in
                        if let model = model {
                            self.reactor?.action.onNext(.updateItemModel(model))
                        }
                    }))
                }
            }
        }).disposed(by: disposeBag)
        
        searchBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.naviService.navigatorSubject.onNext(.searchPage)
        }).disposed(by: disposeBag)
        
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
        
    }
    
    func moreBtnClick(model: HomePageModel,rect: CGRect) {
        if reactor?.currentState.pageType == .authPublish {
            
            guard let completion = model.is_complete,completion == 0 else {
                return
            }
            
            let alert = UIAlertController.init(title: nil, message: "点击完成领养，即代表宠物已被领养，他人将无法获取你的联系方式，确定完成吗？", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction.init(title: "完成领养", style: .default, handler: { [weak self](_) in
                guard let `self` = self else { return }
                self.reactor?.action.onNext(.completeRescue(model))
            }))
            
            alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { (_) in

            }))
            DispatchQueue.main.async {
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    alert.popoverPresentationController?.sourceRect = rect
                    alert.popoverPresentationController?.sourceView = self.view
                }
                
                self.present(alert, animated: true, completion: nil)
            }
        }else if reactor?.currentState.pageType == .authCollect || reactor?.currentState.pageType == .homePageList  {
            let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction.init(title: "屏蔽/拉黑", style: .default, handler: { [weak self](_) in
                guard let `self` = self else { return }
                guard let id = model.topic_id else {
                    return
                }
                UserManager.shared.setUserShieldContent(shieldId: id, shieldType: .rescue_sh_page)
                self.reactor?.action.onNext(.shieldItem(id))
            }))
            
            alert.addAction(UIAlertAction.init(title: "投诉举报", style: .default, handler: { [weak self](_) in
                guard let `self` = self else { return }
                guard let id = model.topic_id else {
                    return
                }
                self.naviService.navigatorSubject.onNext(.violationsPage(report_type: .rescue_page, report_id: id))
            }))
            
            alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { (_) in

            }))
            DispatchQueue.main.async {
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    alert.popoverPresentationController?.sourceRect = rect
                    alert.popoverPresentationController?.sourceView = self.view
                }
                    
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
