//
//  ReportViewController.swift
//  LoveCat
//
//  Created by jingjun on 2021/3/15.
//

import UIKit
import ReactorKit
import RxDataSources
import MBProgressHUD

class ReportViewController: BaseViewController,View {
    
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.sectionHeadersPinToVisibleBounds = true
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: floor((SCREEN_WIDTH - 20) / 2), height: 60)
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        layout.headerReferenceSize = CGSize(width: SCREEN_WIDTH, height: 40)
        layout.footerReferenceSize = CGSize(width: SCREEN_WIDTH, height: 100)
        layout.sectionHeadersPinToVisibleBounds = false
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .onDrag
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = true
        collectionView.register(ViolationCollectionViewCell.self, forCellWithReuseIdentifier: "ViolationCollectionViewCell")
        collectionView.register(ViolationHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ViolationHeaderReusableView")
        collectionView.register(ViolationFooterReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "ViolationFooterReusableView")
        return collectionView
    }()
    
    typealias Reactor = ReportReactor
    
    
    fileprivate var dataSource: RxCollectionViewSectionedReloadDataSource<ViolationListSection>!
    init(navi: NavigatorServiceType,reactor: ReportReactor) {
        super.init(navi: navi)
        dataSource = self.dataSourceFactory()
        defer {
            self.reactor = reactor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "投诉举报"
    }
    
    func dataSourceFactory() -> RxCollectionViewSectionedReloadDataSource<ViolationListSection> {
        return RxCollectionViewSectionedReloadDataSource<ViolationListSection>.init {
            (dataSource, collectionView, indexpath, items) -> UICollectionViewCell in
               switch items {
               case .violationItem(let cellReactor):
                   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ViolationCollectionViewCell", for: indexpath) as! ViolationCollectionViewCell
                   cell.reactor = cellReactor
                   return cell
               }
        } configureSupplementaryView: { (dataSource, collctionView, reusableString, indexPath) -> UICollectionReusableView in
            if reusableString == UICollectionView.elementKindSectionHeader {
                let header = collctionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ViolationHeaderReusableView", for: indexPath)
                return header
            }else{
                let footer = collctionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "ViolationFooterReusableView", for: indexPath) as! ViolationFooterReusableView
                footer.clickActionHandler = { [weak self] index in
                    guard let `self` = self else { return }
                    self.clickPushHandler(index)
                }
                return footer
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupConstraints() {
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func scrollViewInstance() -> UIScrollView? {
        return self.collectionView
    }
    
    override func hasHeadRefresh() -> Bool {
        return false
    }
    
    override func hasFooterRefresh() -> Bool {
        return false
    }
    
    override func retryNewData() {
        super.retryNewData()
        reactor?.action.onNext(.loadData)
    }
    
    override func refreshNetWorking(page: Paging) {
        reactor?.action.onNext(.loadData)
    }

}
extension ReportViewController {
    func bind(reactor: ReportReactor) {
        
        rx.viewDidLoad.map {
            Reactor.Action.loadData
        }.bind(to: reactor.action)
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.isLoading
        }.subscribe(onNext: { [weak self] isloading in
            guard let `self` = self else { return }
            self.isLoading = isloading
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.dataSource
        }.bind(to: collectionView.rx.items(dataSource:dataSource))
        .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected.subscribe(onNext: { indexpath in
            let changeModel = reactor.currentState.dataModel[indexpath.item]
            reactor.action.onNext(.uploadData(model: changeModel))
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.changeResult
        }.filter({ (result) -> Bool in
            result != nil
        })
        .subscribe(onNext: { [weak self] result in
            if result ?? false {
                MBProgressHUD.xy_hide()
                MBProgressHUD.xy_show("提交成功")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self?.navigationController?.popViewController(animated: true)
                }
            }else{
                MBProgressHUD.xy_hide()
                MBProgressHUD.xy_show("提交失败")
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.isRefreshing
        }.subscribe(onNext: { refreshing in
            if refreshing {
                MBProgressHUD.xy_show(activity: nil)
            }else{
                
            }
        }).disposed(by: disposeBag)
    }
    
    func clickPushHandler(_ index: Int) {
    
        if index == 1 {
            guard let user_id = UserManager.shared.userInfo?.user_id else {
                return
            }
            guard let violation_id = reactor?.currentState.dataModel.filter({ (model) -> Bool in
                model.selected == true
            }).first?.id else {
                MBProgressHUD.xy_show("请选择对应理由")
                return
            }
            reactor?.action.onNext(.reportAction(user_id: user_id, violation_id: violation_id))
        }else{
            self.naviService.navigatorSubject.onNext(.webProtocalPage(url: baseUrlConfig.rawValue + UserProtocal.userAgreen.rawValue))
        }
    }
}
