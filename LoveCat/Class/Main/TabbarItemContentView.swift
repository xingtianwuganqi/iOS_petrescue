//
//  TabbarItemContentView.swift
//  LoveCat
//
//  Created by jingjun on 2020/11/5.
//

import UIKit
import ESTabBarController_swift
class TabbarItemContentView: ESTabBarItemContentView {

    public var duration = 0.2

    override init(frame: CGRect) {
        super.init(frame: frame)
        textColor = UIColor.color(.tabbar)!
        highlightTextColor = UIColor.color(.system)!
        iconColor = UIColor.color(.tabbar)!
        highlightIconColor = UIColor.color(.system)!
        renderingMode = .alwaysOriginal
        insets = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func selectAnimation(animated: Bool, completion: (() -> ())?) {
        self.bounceAnimation()
        completion?()
    }
    
    override func reselectAnimation(animated: Bool, completion: (() -> ())?) {
        self.bounceAnimation()
        completion?()
    }
    
    func bounceAnimation() {
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        impliesAnimation.values = [1.0 ,1.02, 0.95, 1.02, 0.95, 1.02, 1.0]
        impliesAnimation.duration = duration * 2
        impliesAnimation.calculationMode = CAAnimationCalculationMode.cubic
        imageView.layer.add(impliesAnimation, forKey: nil)
    }
}
