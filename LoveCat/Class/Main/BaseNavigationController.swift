//
//  BaseNavigationController.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/11.
//

import UIKit

class BaseNavigationController: HBDNavigationController {
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        UINavigationBar.appearance().tintColor = .black
        UINavigationBar.appearance().barTintColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.interactivePopGestureRecognizer?.delegate = self
        self.navigationBar.shadowImage = UIImage.image(UIColor.color(.defIcon)!)
        
        /*设置了NO之后View自动下沉navigationBar的高度
         UINavigationBar.appearance().barTintColor = .white
         设置了navigationBar的背景颜色后，navigationBar，变为不透明，self.view的布局起始位置依旧是从导航栏下方开始
         
         1.edgesForExtendedLayout属性的系统默认值为UIRectEdgeAll：意味着当导航控制器的导航栏为半透明效果时，子控制器self.view布局的起始位置将从屏幕边缘左上角开始。

         2.extendedLayoutIncludesOpaqueBars属性系统默认为NO，Opaque代表非透明，not Includes意味着导航栏不是半透明时，即便当前是UIRectEdgeAll，self.view的布局起始位置依旧是从导航栏下方开始。

         3.translucent属性值会决定导航栏是否有半透明效果。translucent为NO，意味着导航栏为非透明，此时如上文所述，即便当前是UIRectEdgeAll，由于extendedLayoutIncludesOpaqueBars为默认NO，self.view的布局起始位置依旧是从导航栏下方开始。

         */
        self.navigationBar.isTranslucent = true
    }

}
extension BaseNavigationController {
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        // 这个方法是在当前控制器执行push的时候，禁止手势右划返回，避免出现crash的现象
        if self.responds(to: #selector(getter: interactivePopGestureRecognizer)) == true {
            self.interactivePopGestureRecognizer?.isEnabled = false
        }

        if children.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
            if children.count > 0 {
                viewController.hidesBottomBarWhenPushed = true
                if viewController.navigationItem.leftBarButtonItem == nil || viewController.navigationItem.leftBarButtonItem?.isKind(of: UIBarButtonItem.self) == false  {
                    let backNavBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40.0))
                    backNavBtn.contentHorizontalAlignment = .left
                    backNavBtn.setImage(UIImage(named: "icon_a_back"), for: .normal)
                    backNavBtn.setImage(UIImage(named: "icon_a_back"), for: .highlighted)
                    backNavBtn.addTarget(viewController, action: #selector(gobackByPopViewController), for: .touchUpInside)
//                    backNavBtn.qmui_outsideEdge = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                    let backItem = UIBarButtonItem(customView: backNavBtn)
                    viewController.navigationItem.leftBarButtonItem = backItem
                }
                
            }
        }
        super.pushViewController(viewController, animated: animated)//一定要写在最后，要不然无效
        //处理了push后隐藏底部UITabBar的情况，并解决了iPhonX上push时UITabBar上移的问题。
        if var rect = self.tabBarController?.tabBar.frame {
            rect.origin.y = UIScreen.main.bounds.size.height - rect.size.height
            self.tabBarController?.tabBar.frame = rect
        }
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        super.popViewController(animated: animated)
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        super.popToViewController(viewController, animated: animated)
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        super.popToRootViewController(animated: animated)
    }
}

extension BaseNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // 这个方法是在当前控制器执行push的时候，禁止手势右划返回，避免出现crash的现象
        if self.responds(to: #selector(getter: interactivePopGestureRecognizer)) == true {
            self.interactivePopGestureRecognizer?.isEnabled = self.viewControllers.count > 1
        }
        if let vc = viewController as? UserEditViewController ,vc.fromType == 1 {
            self.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
}
extension UIViewController {
    @objc func  gobackByPopViewController() {
        self.navigationController?.popViewController(animated: true)
    }
}
