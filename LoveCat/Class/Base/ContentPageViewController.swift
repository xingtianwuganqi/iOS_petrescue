//
//  ContentPageViewController.swift
//  PageController
//
//  Created by jingjun on 2020/12/1.
//  Copyright © 2020 jingjun. All rights reserved.
//

import UIKit

@objc(RTHomeContentPageViewControllerDelegate)
protocol ContentPageViewControllerDelegate: NSObjectProtocol {
    @objc optional func didChangePageWithIndex(index: Int, controller: ContentPageViewController)
    @objc optional func willChangePageWithIndex(index: Int, controller: ContentPageViewController)
}

class ContentPageViewController: UIViewController {
    fileprivate var isViewDidLoad = false
    public weak var delegate: ContentPageViewControllerDelegate?
    public var pages: [UIViewController]? = nil {
        didSet {
            if (self.pages == oldValue) {
                return;
            }
            self.updatePages()
        }
    }

    public var currentIndex: Int = -1
    fileprivate var defaultIndex: Int = 0
    fileprivate var transitionFinish: Bool = true
    fileprivate var pendingViewController: UIViewController?
    public lazy var pageController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: UIPageViewController.TransitionStyle.scroll, navigationOrientation: UIPageViewController.NavigationOrientation.horizontal, options: [UIPageViewController.OptionsKey.spineLocation : UIPageViewController.SpineLocation.min])
        vc.dataSource = self
        vc.delegate = self
        vc.isDoubleSided = true
        return vc
    }()
    
    public weak var scrollView: UIScrollView?
    
    fileprivate var categoryViewHeightConstraint: NSLayoutConstraint?
    public var didChangePage: ((_ index: Int) -> Void)?
    
    public var isScrollEnabled: Bool = true {
        didSet {
            if let scrollView = self.scrollView {
                scrollView.isScrollEnabled = isScrollEnabled
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public init(pages: [UIViewController]?, defaultIndex: Int) {
        super.init(nibName: nil, bundle: nil)
        self.pages = pages
        self.defaultIndex = defaultIndex
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.isViewDidLoad = true
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self._setupUI()
        self.updatePages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    public func showPage(index: Int, animated: Bool) {
        
        guard let pages = self.pages else {
            return
        }
        var newIndex = index
        if index >= pages.count {
            newIndex = pages.count - 1
        }
        if newIndex == self.currentIndex {
            return
        }
        let vc = pages[newIndex]
        var direction = UIPageViewController.NavigationDirection.reverse
        if newIndex > self.currentIndex {
            direction = UIPageViewController.NavigationDirection.forward
        }
        self.currentIndex = newIndex
        self.transitionFinish = false
        self.pageController.setViewControllers([vc], direction: direction, animated: animated) {[weak self] (isFinished) in
            if isFinished == true {
                self?.transitionFinish = true
                self?.currentIndex = index
//                self?.fd_interactivePopDisabled = self?.currentIndex != 0
            }
        }
        
    }
    
    public func reloadPage(index: Int, animated: Bool) {
        
        guard let pages = self.pages else {
            return
        }
        var newIndex = index
        if index >= pages.count {
            newIndex = pages.count - 1
        }
        let vc = pages[newIndex]
        var direction = UIPageViewController.NavigationDirection.reverse
        if newIndex > self.currentIndex {
            direction = UIPageViewController.NavigationDirection.forward
        }
        self.currentIndex = newIndex
        self.transitionFinish = false
        self.pageController.setViewControllers([vc], direction: direction, animated: animated) {[weak self] (isFinished) in
            if isFinished == true {
                self?.transitionFinish = true
                self?.currentIndex = index
//                self?.fd_interactivePopDisabled = self?.currentIndex != 0
            }
        }
        
    }
    
    public func index(controller: UIViewController?) -> Int {
        guard let pages = self.pages else {
            return NSNotFound
        }
        var index = 0
        for page in pages {
            if controller == page {
                break
            }
            index += 1
        }
        return index
    }
    
    fileprivate func _setupUI() {
        self.addChild(self.pageController)
        self.view.addSubview(self.pageController.view)
        self.pageController.didMove(toParent: self)
        self.pageController.view.backgroundColor = UIColor.clear
        
        for view in self.pageController.view.subviews {
            if view.isKind(of: UIScrollView.self) {
                self.scrollView = view as? UIScrollView
                break
            }
        }
        self.pageController.view.translatesAutoresizingMaskIntoConstraints = false

        if #available(iOS 11.0, *) {
            self.pageController.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0.0).isActive = true
        } else {
            self.pageController.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0).isActive = true
        }
        self.pageController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0).isActive = true
        self.pageController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0).isActive = true
        self.pageController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0).isActive = true
        
        self.scrollView?.scrollsToTop = false
        self.scrollView?.backgroundColor = UIColor.white
        self.scrollView?.keyboardDismissMode = .onDrag
        self.scrollView?.isScrollEnabled = self.isScrollEnabled
    }
    
    public func updatePages() {
        if self.isViewDidLoad == false {
            return
        }
        var showIndex = self.defaultIndex
        if self.currentIndex > 0 {
            showIndex = self.currentIndex
        }
        self.view.setNeedsLayout()
        self.showPage(index: showIndex, animated: false)
    }
    
}


extension ContentPageViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.isScrollEnabled == false {
            return true
        }
        var flag = true
        if gestureRecognizer is UIPanGestureRecognizer {
            let pan = gestureRecognizer as? UIPanGestureRecognizer
            guard let translation = pan?.translation(in: pan?.view) else { return true }
            if translation.x <= CGFloat(0.0) {
                flag = self.currentIndex == (self.pages?.count ?? 0) - 1 && self.transitionFinish == true
            }
            else {
                flag = self.currentIndex == 0 && self.transitionFinish == true
            }
        }
        return flag
    }
    
}
extension ContentPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        self.transitionFinish = false
        self.pendingViewController = pendingViewControllers.first
        let index = self.index(controller: self.pendingViewController)
        if index != NSNotFound {
            self.currentIndex = index
        }
        
        if let delegate = self.delegate, delegate.responds(to: #selector(ContentPageViewControllerDelegate.didChangePageWithIndex(index:controller:))) {
            delegate.willChangePageWithIndex?(index: index, controller: self)
        }
        
        if let didChangePage = self.didChangePage {
            didChangePage(self.currentIndex);
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        let vc = previousViewControllers.last
        let previousIndexx = self.index(controller: vc)
        let displayController = pageViewController.viewControllers?.first
        let currentIndex = self.index(controller: displayController)
        if completed {
            // 完成页面切换
            if self.currentIndex != previousIndexx {
                self.currentIndex = currentIndex
            }
        }
        else {
            // 未完成页面切换，还原index
            self.currentIndex = previousIndexx
        }
        
        self.transitionFinish = true
        // 不是第一个控制器时禁止pop返回手势
//        self.fd_interactivePopDisabled = self.currentIndex != 0
        
        if let delegate = self.delegate, delegate.responds(to: #selector(ContentPageViewControllerDelegate.didChangePageWithIndex(index:controller:))) {
            delegate.didChangePageWithIndex?(index: self.currentIndex, controller: self)
        }
    }
    
}

extension ContentPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.index(controller: viewController)
        if index == 0 || index == NSNotFound {
            return nil
        }
        index -= 1
        if let pages = self.pages, pages.count > index {
            return pages[index]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.index(controller: viewController)
        guard let pages = self.pages else {
            return nil;
        }
        if index >= pages.count || index == NSNotFound {
            return nil
        }
        index += 1

        if pages.count > index {
            return pages[index]
        }
        return nil
    }
    
    
}


