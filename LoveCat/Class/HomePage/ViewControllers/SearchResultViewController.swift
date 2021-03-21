//
//  SourchResultViewController.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/4.
//

import UIKit
import RxSwift
import ReactorKit
import RxDataSources
import DZNEmptyDataSet

class SearchResultViewController: BaseViewController,View {
    
    typealias Reactor = SearchResultReactor
    
    lazy var tableview : UITableView = {
        let tableview = UITableView(frame: .zero, style: UITableView.Style.grouped)
        tableview.estimatedRowHeight = 0
        tableview.estimatedSectionFooterHeight = 0
        tableview.estimatedSectionHeaderHeight = 0
        tableview.showsVerticalScrollIndicator = false
        tableview.showsHorizontalScrollIndicator = false
        tableview.separatorStyle = .none
        tableview.backgroundColor = UIColor.white
        tableview.register(HomePageTableCell.self, forCellReuseIdentifier: "HomePageTableCell")
        return tableview
    }()
    
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<HomePageSection>!
    
    private func dataSourceFactory() -> RxTableViewSectionedReloadDataSource<HomePageSection> {
        return RxTableViewSectionedReloadDataSource<HomePageSection>.init { (dataSource, tableView, indexPath, items) -> UITableViewCell in
            switch items {
            case .homepageItem(let reactor):
                let cell = tableView.dequeueReusableCell(withIdentifier: "HomePageTableCell", for: indexPath) as! HomePageTableCell
                cell.reactor = reactor
                cell.moreBtnClick = { model in
                    UserManager.shared.lazyAuthToDoThings {
                        let rect = cell.contentView.convert(cell.moreBtn.frame, to: self.view)
                        self.moreBtnClick(model: model, rect: rect)
                    }
                }
                return cell
            }
        }
    }
    
    override init(navi: NavigatorServiceType) {
        super.init(navi: navi)
        dataSource = self.dataSourceFactory()
        defer {
            self.reactor = SearchResultReactor.init()
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
        tableview.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.right.bottom.equalToSuperview()
        }
    }
    override func retryNewData() {
        super.retryNewData()
        self.reactor?.action.onNext(.beginSearch(self.reactor?.currentState.keyword ?? ""))
//        self.tableview
    }
    
    override func scrollViewInstance() -> UIScrollView? {
        return self.tableview
    }
}

extension SearchResultViewController {
    func bind(reactor: Reactor) {
        
        reactor.state.map {
            $0.isLoading
        }.subscribe(onNext: { [weak self] loading in
            guard let `self` = self else { return }
            self.isLoading = loading
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.errorMsg
        }.subscribe(onNext: { [weak self] errorMsg in
            guard let `self` = self else { return }
            if let msg = errorMsg {
                self.titleEmpty = msg
            }
        })
        .disposed(by: disposeBag)
        
        tableview.rx.setDelegate(self).disposed(by: disposeBag)
        reactor.state.map {
            $0.section
        }.bind(to: tableview.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
        
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
    }
}

extension SearchResultViewController: UITableViewDelegate { //, DZNEmptyDataSetSource,DZNEmptyDataSetDelegate
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func moreBtnClick(model: HomePageModel,rect: CGRect) {
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
