//
//  PublishMainViewController.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/20.
//

import UIKit
import JXSegmentedView

enum PageType {
    case publish
    case collection
}

class PublishMainViewController: ContentPageViewController {
    
//    lazy var publishPage : MyPublishViewController = {
//        let viewController = MyPublishViewController.init(navi: self.naviService)
//        return viewController
//    }()
    
    lazy var publishPage : HomePageListController = {
        let viewController = HomePageListController.init(navi: self.naviService, type: .authPublish)
        return viewController
    }()
    
//    lazy var collectionPage: MyCollectionViewController = {
//        let vc = MyCollectionViewController.init(navi: self.naviService)
//        return vc
//    }()
    
    lazy var collectionPage: HomePageListController = {
        let vc = HomePageListController.init(navi: self.naviService, type: .authCollect)
        return vc
    }()
    
    lazy var showPage : ShowPageListController = {
        let viewController = ShowPageListController.init(navi: self.naviService, type: .authShowInfo)
        return viewController
    }()
    
    lazy var collectShowPage : ShowPageListController = {
        let viewController = ShowPageListController.init(navi: self.naviService, type: .collectShowInfo)
        return viewController
    }()
    
    lazy var segmentedView: JXSegmentedView = {
        let segment = JXSegmentedView()
        segment.delegate = self
        let indicator = JXSegmentedIndicatorLineView()
//        indicator.indicatorWidth = 35
        indicator.indicatorColor = UIColor.color(.system)!
        segment.indicators = [indicator]
        return segment
    }()
    
    lazy var segmentDataSource: JXSegmentedTitleDataSource = {
        let dataSource = JXSegmentedTitleDataSource()
        dataSource.titleNormalColor = UIColor.color(.desc)!
        dataSource.titleSelectedColor = UIColor.color(.content)!
        dataSource.titleSelectedFont = UIFont.et.font(size: 16)
        dataSource.titleNormalFont = UIFont.et.font(size: 14)
        dataSource.itemSpacing = 15
        dataSource.itemWidth = 90
        return dataSource
    }()
    
    fileprivate var naviService: NavigatorServiceType
    fileprivate var pageType: PageType?
    init(navi: NavigatorServiceType,type: PageType?) {
        self.naviService = navi
        super.init(pages: nil, defaultIndex: 0)
        self.pageType = type
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.delegate = self
        
        self.updatePageControllerConstraints()
        self.segmentedView.dataSource = self.segmentDataSource
        
        if self.pageType == PageType.publish {
            self.title = "我的发布"
            self.segmentDataSource.titles = ["我发布的领养","我发布的秀宠"]
            self.pages = [publishPage,showPage]
        }else{
            self.title = "我的收藏"
            self.segmentDataSource.titles = ["我收藏的领养","我收藏的秀宠"]
            self.pages = [collectionPage,collectShowPage]
        }
        
    }

     func updatePageControllerConstraints() {
        
        let pageControllerTop = self.view.constraints.first { (layout) -> Bool in
            (layout.firstItem as? UIView) == self.pageController.view && layout.firstAttribute == .top
        }
        pageControllerTop?.constant = 46
        
        self.view.addSubview(segmentedView)
        segmentedView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.width.equalTo(250)
            make.centerX.equalToSuperview()
            make.height.equalTo(45)
        }
        
        let lineView = UIView()
        lineView.backgroundColor = UIColor.color(.defIcon)
        self.view.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(segmentedView.snp.bottom)
        }
    }
}
extension PublishMainViewController: ContentPageViewControllerDelegate,JXSegmentedViewDelegate {
    func didChangePageWithIndex(index: Int, controller: ContentPageViewController) {
        self.segmentedView.selectItemAt(index: index)
    }
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        self.showPage(index: index, animated: true)
    }
}
