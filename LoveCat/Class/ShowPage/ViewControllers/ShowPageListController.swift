//
//  ShowPageListController.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/4.
//

import UIKit
import ReactorKit
import RxDataSources

enum ShowPageType {
    case showInfoList
    case authShowInfo
    case collectShowInfo
}

class ShowPageListController: BaseViewController,View {

    typealias Reactor = ShowPageListReactor
    
    lazy var tableview : UITableView = {
        let tableview = UITableView(frame: .zero, style: UITableView.Style.grouped)
        tableview.estimatedRowHeight = 0
        tableview.estimatedSectionFooterHeight = 0
        tableview.estimatedSectionHeaderHeight = 0
        tableview.showsVerticalScrollIndicator = false
        tableview.showsHorizontalScrollIndicator = false
        tableview.separatorStyle = .none
        tableview.backgroundColor = UIColor.color(.defIcon)
        tableview.register(ShowListCell.self, forCellReuseIdentifier: "ShowListCell")
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
    fileprivate var dataSource : RxTableViewSectionedReloadDataSource<ShowPageListSection>!
    
    func dataSourceFactory() ->  RxTableViewSectionedReloadDataSource<ShowPageListSection> {
        return RxTableViewSectionedReloadDataSource<ShowPageListSection>.init { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case .showPageItem(let reac):
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShowListCell", for: indexPath) as! ShowListCell
                cell.reactor = reac
                if self.reactor?.currentState.pageType == .authShowInfo {
                    cell.moreBtn.isHidden = true
                }
                cell.commentBtnClickBlock = { (model,type) in
                    // 点击了评论
                    if type == 1 {
                        self.naviService.navigatorSubject.onNext(.ShowCommentList(topicId: model?.show_id ?? 0))
                    }else if type == 2{
                        guard let gambitId = model?.gambit_type?.id else {
                            return
                        }
                        self.naviService.navigatorSubject.onNext(.showInfoPage(type: .showInfoList, gambitId: gambitId))
                    }else if type == 3 {
                        UserManager.shared.lazyAuthToDoThings {
                            let rect = cell.contentView.convert(cell.moreBtn.frame, to: self.view)
                            self.moreBtnClick(model: model, rect: rect)
                        }
                    }
                }
                return cell
            }
        }
    }
    
    init(navi: NavigatorServiceType,type: ShowPageType,gambitId: Int? = nil) {
        super.init(navi: navi)
        dataSource = self.dataSourceFactory()
        defer {
            self.reactor = ShowPageListReactor.init(type: type,gambit_id: gambitId)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "秀宠"
    }

    override func setupConstraints() {
        super.setupConstraints()
        self.view.addSubview(tableview)
        tableview.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            if self.reactor?.currentState.pageType == .showInfoList,self.reactor?.currentState.gambitId == nil {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }else{
                make.bottom.equalToSuperview()
            }
        }
        
        
        if self.reactor?.currentState.pageType == .showInfoList {
            self.view.addSubview(releaseBtn)
            releaseBtn.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-15)
                make.bottom.equalToSuperview().offset(-(SystemTabBarHeight + 30))
                make.size.equalTo(CGSize(width: 50, height: 50))
            }
            releaseBtn.rx.tap.subscribe(onNext: { [weak self] _ in
                UserManager.shared.lazyAuthToDoThings {
                    self?.showReleasePage()
                }
            }).disposed(by: disposeBag)
        }else if self.reactor?.currentState.pageType == .authShowInfo {
            self.titleEmpty = "暂无发布"
            self.descEmpty = "快去发布秀宠吧"
        }else if self.reactor?.currentState.pageType == .collectShowInfo {
            self.titleEmpty = "暂无收藏"
            self.descEmpty = "快去收藏喜欢的宠物吧"
        }
    }
    override func scrollViewInstance() -> UIScrollView? {
        return self.tableview
    }
    
    override func retryNewData() {
        super.retryNewData()
        if self.reactor?.currentState.pageType == .collectShowInfo{
            self.reactor?.action.onNext(.loadAuthCollection(.refresh))
        }else if self.reactor?.currentState.pageType == .authShowInfo {
            self.reactor?.action.onNext(.loadAuthPublish(.refresh))
        }else {
            self.reactor?.action.onNext(.loadShowData(.refresh))
        }
    }
    
    override func hasHeadRefresh() -> Bool {
        return true
    }
    
    override func hasFooterRefresh() -> Bool {
        return true
    }
    
    override func refreshNetWorking(page: Paging) {
        if self.reactor?.currentState.pageType == .collectShowInfo{
            self.reactor?.action.onNext(.loadAuthCollection(page))
        }else if self.reactor?.currentState.pageType == .authShowInfo {
            self.reactor?.action.onNext(.loadAuthPublish(page))
        }else {
            self.reactor?.action.onNext(.loadShowData(page))
        }
    }
    
    func showReleasePage() {
        self.naviService.navigatorSubject.onNext(.releaseShowInfo(result: { _ in
            // 刷新数据
            self.reactor?.action.onNext(.loadShowData(.refresh))
        }))
    }
}
extension ShowPageListController : UITableViewDelegate{
    func bind(reactor: ShowPageListReactor) {
        
        reactor.state.map {
            $0.isLoading
        }.subscribe(onNext: { [weak self] loading in
            guard let `self` = self else { return }
            self.isLoading = loading
        }).disposed(by: disposeBag)
        
        rx.viewDidLoad.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            if self.reactor?.currentState.pageType == .collectShowInfo{
                self.reactor?.action.onNext(.loadAuthCollection(.refresh))
            }else if self.reactor?.currentState.pageType == .authShowInfo {
                self.reactor?.action.onNext(.loadAuthPublish(.refresh))
            }else {
                self.reactor?.action.onNext(.loadShowData(.refresh))
            }
        }).disposed(by: disposeBag)
        
        tableview.rx.setDelegate(self).disposed(by: disposeBag)
        reactor.state.map {
            $0.section
        }.bind(to: tableview.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.isLoading
        }.subscribe(onNext: { [weak self] loading in
            self?.isLoading = loading
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.endRefreshing
        }.subscribe(onNext: { [weak self] endState in
            guard let `self` = self else { return }
            if let state = endState {
                self.tableview.mj_header?.endRefreshing()
                self.tableview.mj_footer?.et.setRefState(state: state)
            }
        }).disposed(by: disposeBag)
    
        reactor.state.map {
            $0.errorMsg
        }.subscribe(onNext: { [weak self] message in
            guard let `self` = self else { return }
            guard let msg = message else {
                return
            }
            self.view.xy_show(msg)
        }).disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func moreBtnClick(model: ShowPageModel?,rect: CGRect) {
        guard let model = model else {
            return
        }
        if reactor?.currentState.pageType == .authShowInfo {
            
        
        }else if reactor?.currentState.pageType == .showInfoList || reactor?.currentState.pageType == .collectShowInfo  {
            let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction.init(title: "屏蔽/拉黑", style: .default, handler: { [weak self](_) in
                guard let `self` = self else { return }
                guard let id = model.show_id else {
                    return
                }
                UserManager.shared.setUserShieldContent(shieldId: id, shieldType: .show_sh_page)
                self.reactor?.action.onNext(.shieldItem(id))
            }))
            
            alert.addAction(UIAlertAction.init(title: "投诉举报", style: .default, handler: { [weak self](_) in
                guard let `self` = self else { return }
                guard let id = model.show_id else {
                    return
                }
                self.naviService.navigatorSubject.onNext(.violationsPage(report_type: .show_page, report_id: id))
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
