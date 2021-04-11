//
//  MianTabbarController.swift
//  LoveCat
//
//  Created by jingjun on 2020/10/16.
//

import UIKit
import ESTabBarController_swift
import SnapKit
import RxSwift
import RxGesture
class MainTabbarController: ESTabBarController {
    var disposeBag = DisposeBag()
    enum TabbarItemTitle: String {
        case homePage = "首页"
        case video = "秀宠"
        case message = "消息"
        case mine = "我的"
    }
    
    fileprivate let naviService: NavigatorServiceType
    fileprivate var currentSelect: Int = -1
    fileprivate var lastSelectTime: TimeInterval?
    fileprivate lazy var networking = NetWorking<MessageApi>()
    init(naviService: NavigatorServiceType) {
        self.naviService = naviService
        super.init(nibName: nil, bundle: nil)
        

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var needsLoginItems: [TabbarItemTitle] = [.mine]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homePage = HomePageListController.init(navi: naviService)
        let showList = ShowPageListController.init(navi: naviService, type: .showInfoList)
        let gambit = GambitListController.init(navi: naviService, normal: nil, selected: nil)
        let video = ShowPageMainViewController.init(pages: [showList,gambit], defaultIndex: 0)
        let message = MessagePageController.init(navi: naviService)
        let minePage = MinePageViewController(navi: naviService)

        self.addChildVC(viewController: homePage, title: TabbarItemTitle.homePage.rawValue, selectImage: "icon_tabbar_cat_se", unselectImage: "icon_tabbar_cat_un")
        self.addChildVC(viewController: video, title: TabbarItemTitle.video.rawValue, selectImage: "icon_tabbar_dog_se", unselectImage: "icon_tabbar_dog_un")
        self.addChildVC(viewController: message, title: TabbarItemTitle.message.rawValue, selectImage: "icon_tabbar_msg_se", unselectImage: "icon_tabbar_msg_un")
        self.addChildVC(viewController: minePage, title: TabbarItemTitle.mine.rawValue, selectImage: "icon_tabbar_mi_se", unselectImage: "icon_tabbar_mi_un")
        
        self.delegate = self
//        self.setTabbarController()
        
        messageNumNetworking()
        
        AppHelper.shared.unreadNum.subscribe(onNext: { num in
            if let esTabbar = self.tabBar.items?[2] as? ESTabBarItem{
                if num > 0{
                    esTabbar.badgeValue = num.et_unread
                }else{
                    esTabbar.badgeValue = nil
                }
            }
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func addChildVC(viewController: UIViewController,title: String,selectImage: String,unselectImage: String) {
        let tabbarItem = ESTabBarItem.init(TabbarItemContentView(),title: title, image: UIImage(named: unselectImage), selectedImage: UIImage(named: selectImage))
        viewController.tabBarItem = tabbarItem
        viewController.navigationController?.title = title
        let navi = BaseNavigationController.init(rootViewController: viewController)
        if self.viewControllers == nil {
            self.viewControllers = [navi]
        }
        else {
            self.viewControllers?.append(navi)
        }
    }
    
    fileprivate func scrollToTop(_ viewController: UIViewController) {
        if let navigationController = viewController as? UINavigationController {
            let topViewController = navigationController.topViewController
            let firstViewController = navigationController.viewControllers.first
            if let vc = topViewController, vc === firstViewController {
                //                点击当前栏目时滚动到最上且刷新
                switch type(of: vc) {
                case is HomePageListController.Type:
                    (vc as? BaseViewController)?.rxRefresh.onNext(Void())
                case is ShowPageMainViewController.Type:
                    if let viewC = vc as? ShowPageMainViewController,viewC.currentIndex != -1 {
                        (viewC.pages?[viewC.currentIndex] as? BaseViewController)?.rxRefresh.onNext(Void())
                    }
                case is MessagePageController.Type:
                    (vc as? BaseViewController)?.rxRefresh.onNext(Void())
                case is MinePageViewController.Type:
                    break
                default:
                    break
                }
            }
            return
        }
        guard let scrollView = viewController.view.subviews.first as? UIScrollView else { return }
        scrollView.setContentOffset(.zero, animated: true)
    }
    
    @objc func didBecomeActive() {
        self.messageNumNetworking()
    }
    
    func messageNumNetworking() {
        let observal = networking.request(.authUnReadNum).mapData(MessageNumModel.self)
        observal.subscribe(onNext: { [weak self] baseModel in //
            guard let `self` = self else { return }
            if baseModel?.isSuccess ?? false {
                if let esTabbar = self.tabBar.items?[2] as? ESTabBarItem {
                    let num = (baseModel?.data?.like_unread ?? 0) + (baseModel?.data?.collec_unread ?? 0)
                    let sysNum = (baseModel?.data?.sys_unread ?? 0) + (baseModel?.data?.com_unread ?? 0)
                    let total = num + sysNum
                    if total > 0{
                        esTabbar.badgeValue = total.et_unread
                    }else{
                        esTabbar.badgeValue = nil
                    }
                }
            }
        }).disposed(by: disposeBag)
    }
}
extension MainTabbarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if self.currentSelect == self.selectedIndex {
            let current = Date.init().timeIntervalSince1970
            if current - (lastSelectTime ?? 0) < 0.8 {
                self.scrollToTop(viewController)
            }
        }
        self.lastSelectTime = Date.init().timeIntervalSince1970
        self.currentSelect = self.selectedIndex
    }
}
