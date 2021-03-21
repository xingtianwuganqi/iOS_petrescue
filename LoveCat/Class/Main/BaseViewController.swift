//
//  BaseViewController.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/16.
//

import UIKit
import RxSwift
import ReactorKit
import RxGesture
import RxCocoa
import RxDataSources

class BaseViewController: UIViewController,RefreshViewControllerProtocal {
    
    var disposeBag = DisposeBag()
    
    var naviService: NavigatorServiceType
    
    var automaticallyAdjustsLeftBarButtonItem = true
    
    /// There is a bug when trying to go back to previous view controller in a navigation controller
    /// on iOS 11, a scroll view in the previous screen scrolls weirdly. In order to get this fixed,
    /// we have to set the scrollView's `contentInsetAdjustmentBehavior` property to `.never` on
    /// `viewWillAppear()` and set back to the original value on `viewDidAppear()`.
    private var scrollViewOriginalContentInsetAdjustmentBehaviorRawValue: Int?
    
    // MARK: Initializing
    init(navi: NavigatorServiceType) {
        self.naviService = navi
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        printLog("DEINIT: \(String(describing: self.className))")
    }
    
    // MARK: Rx
    var rxRefresh = PublishSubject<Void>()
    
    // MARK: Layout Constraints
    var titleEmpty: String?
    
    var descEmpty: String?
    
    var isLoading: Bool?
    
    private(set) var didSetupConstraints = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.setNeedsUpdateConstraints()
        self.setNetWorkMonitoring()
        rxRefresh.subscribe(onNext: { _ in
            self.scrollViewInstance()?.mj_header?.beginRefreshing()
        }).disposed(by: disposeBag)
    }
    
    override func updateViewConstraints() {
        if !self.didSetupConstraints {
            self.setupConstraints()
            self.didSetupConstraints = true
            self.configurations()
        }
        super.updateViewConstraints()
        
        endLayoutAction()
    }
    // 配置空页面
    func configurations() {
        
        guard let scrollView = self.scrollViewInstance() else {
            return
        }
        if #available(iOS 11, *) {
            self.scrollViewOriginalContentInsetAdjustmentBehaviorRawValue =
                scrollView.contentInsetAdjustmentBehavior.rawValue
            scrollView.contentInsetAdjustmentBehavior = .never
        }else{
            self.automaticallyAdjustsScrollViewInsets = false;
        }
        // 设置代理
        scrollView.emptyDataSetDelegate = self
        scrollView.emptyDataSetSource = self
        scrollView.reloadEmptyDataSet()
        if hasHeadRefresh() {
            scrollView.mj_header = BaseRefresh.init(refreshingBlock: {
                self.refreshNetWorking(page: .refresh)
            })
        }

        if hasFooterRefresh() {
            let refresh = BaseFooterRefresh.init(refreshingBlock: {
                self.refreshNetWorking(page: .next)
            })
            refresh.et.setRefState(state: .empty)
            scrollView.mj_footer = refresh
        }
        
    }
    // MARK: 布局
    func setupConstraints() {
        // Override point
    }
    // MARK: 布局完成之后设置
    func endLayoutAction() {
        // Override point
    }
    // MARK: 重新请求新数据
    func retryNewData() {
        // Override point
        self.setNetWorkMonitoring()
        
    }
    // MARK: 上拉刷新和下拉加载调用
    func refreshNetWorking(page: Paging) {
        
    }
    // 是否有下拉刷新
    func hasHeadRefresh() -> Bool {
        return false
    }
    // 是否有下拉加载
    func hasFooterRefresh() -> Bool {
        return false
    }
    // 是否有scroll对象
    public func scrollViewInstance() -> UIScrollView? {
//        fatalError("scrollView 子类实现")
        return nil
    }
    
    func setNetWorkMonitoring() {
        if let netState = NetWorkMonitoring.shareMonitor.currentNetState,netState == .unavailable {
            self.titleEmpty = "网络不可用"
            self.descEmpty = "请检查网络后重试"
        }else{
            self.titleEmpty = nil
            self.descEmpty = nil
        }
    }
}
extension BaseViewController: DZNEmptyDataSetSource,DZNEmptyDataSetDelegate{
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        let attrbute = NSMutableAttributedString()
        attrbute.append(NSAttributedString(string: titleEmpty ?? "暂无数据", attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.content)!, NSAttributedString.Key.font: UIFont.et.fontSize(.medium, .title)]))
        return attrbute
        
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrbute = NSMutableAttributedString()
        attrbute.append(NSAttributedString(string: descEmpty ?? "请点击重试", attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.desc)!, NSAttributedString.Key.font: UIFont.et.fontSize(.regular, .content)]))
        return attrbute
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        self.refreshNetWorking(page: .refresh)
    }
    
    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        if let loading = self.isLoading,loading == true {
            if (scrollView.mj_header?.isRefreshing ?? false) {
                return nil
            }else{
                let indicatorView = UIActivityIndicatorView(style: .gray)
                DispatchQueue.main.async {
                    indicatorView.startAnimating()
                }
                return indicatorView
            }
        }
        return nil
    }
}
