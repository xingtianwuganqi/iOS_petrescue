////
////  HUD.swift
////  App-720yun
////
////  Created by AntScript on 29/03/2018.
////  Copyright © 2018 720yun. All rights reserved.
////
//
//import Foundation
//import MBProgressHUD
//
//class HUD {
//
//	static let shared = HUD()
//
//	private var hud: MBProgressHUD?
//	private var completionBlock: (() -> Void)?
//    private let image = UIImageView()
//	private init() {
//
//	}
//
//
//    func show(_ content: HUDContent, view: UIView? = nil,isRootView: Bool? = true, completionBlock: (() -> Void)? = nil ) {
//
////
////		guard message.message != "" || message.type == .loading else {
////			return
////		}
//        
//        let rootView : UIView
//        if isRootView ?? true {
//
//            guard let view = view ?? UIApplication.shared.keyWindow?.rootViewController?.view else {
//                return
//            }
//            rootView = view
//        }else{
//            guard let view = view ?? UIApplication.shared.keyWindow else {
//                return
//            }
//            rootView = view
//        }
//
//		hud?.hide(animated: false)
//
//		hud = MBProgressHUD.showAdded(to: rootView , animated: true)
//		hud?.bezelView.color = UIColor.white //.withAlphaComponent(0.8)
//        hud?.bezelView.borderColor = UIColor(hexString: "#d8d8d8")
//        hud?.bezelView.borderWidth = 1
//		hud?.bezelView.style = .solidColor
//		hud?.removeFromSuperViewOnHide = true
//		hud?.contentColor = UIColor(hexString: "#5f5f5f")
//		hud?.autoresizesSubviews = true
//		hud?.minSize = CGSize(width: 100, height: 100)
//        hud?.label.font = UIFont.init(name: Regular, size: 12)
//
//		self.completionBlock = completionBlock
//
//		switch content {
//		case .loading:
//            
//            self.showImage()
//            hud?.mode = .customView
//            hud?.customView = image
//            
//		case .info(let msg):
//			hud?.label.text = msg
//			hud?.mode = .text
//			delayHide()
//		case .success(let msg):
//			hud?.mode = .customView
//			hud?.customView = UIImageView(image: UIImage(named: "t_success")!)
//			hud?.label.text = msg
//			delayHide()
//		case .error(let msg):
//			hud?.mode = .customView
//			hud?.customView = UIImageView(image: UIImage(named: "t_error")!)
//			hud?.label.text = msg
//			delayHide()
//        case .download(let msg):
//            
//            let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
//            var imgArray : [UIImage] = []
//            for i in 0...50
//            {
//                // 拼接名称
//                let name: String? = "1_000\(i)"
//                let img : UIImage? = UIImage(named: name!)
//                imgArray.append(img!)
//            }
//            // 给动画数组赋值
//            image.animationImages = imgArray
//            // 设置重复次数, 学过的都知道...0 代表无限循环,其他数字是循环次数,负数效果和0一样...
//            image.animationRepeatCount = 0
//            // 动画完成所需时间
//            image.animationDuration = 50*0.03
//            // 开始动画
//            image.startAnimating()
//            
//            hud?.mode = .customView
//            hud?.customView = image
//            hud?.label.text = msg
//            
////        case .downloadVideo(let msg):
////            let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
////            var imgArray : [UIImage] = []
////            for i in 0...50
////            {
////                // 拼接名称
////                let name: String? = "1_000\(i)"
////                let img : UIImage? = UIImage(named: name!)
////                imgArray.append(img!)
////            }
////            // 给动画数组赋值
////            image.animationImages = imgArray
////            // 设置重复次数, 学过的都知道...0 代表无限循环,其他数字是循环次数,负数效果和0一样...
////            image.animationRepeatCount = 0
////            // 动画完成所需时间
////            image.animationDuration = 50*0.03
////            // 开始动画
////            image.startAnimating()
////            
////            hud?.mode = .customView
////            hud?.customView = image
////            hud?.label.text = msg
////            let blur = UIBlurEffect.init(style: .light)
////            let hudview = UIVisualEffectView.init(effect: blur)
////            hudview.alpha = 1
////            hudview.frame = CGRect(x: 0, y: 0, width: ScreenW, height: ScreenH)
////            hud?.backgroundView.addSubview(hudview)
//		}
//	}
//
//	func delayHide() {
//		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {[unowned self] in
//			self.hud?.hide(animated: true)
//			self.hud = nil
//			self.completionBlock?()
//		}
//	}
//
//	func hide() {
//		hud?.hide(animated: true)
//		hud = nil
//	}
//    
//    func showImage() {
//        
//        var imgArray : [UIImage] = []
//        for i in 0...50
//        {
//            // 拼接名称
//            let name: String? = "1_000\(i)"
//            let img : UIImage? = UIImage(named: name!)
//            imgArray.append(img!)
//        }
//        // 给动画数组赋值
//        self.image.animationImages = imgArray
//        // 设置重复次数, 学过的都知道...0 代表无限循环,其他数字是循环次数,负数效果和0一样...
//        self.image.animationRepeatCount = 0
//        // 动画完成所需时间
//        self.image.animationDuration = 50*0.03
//        // 开始动画
//        self.image.startAnimating()
//    }
//    
//    func updateText(_ text: String) {
//        hud?.label.text = text
//    }
//}
//
//enum HUDContent {
//	case loading
//	case info(String)
//	case error(String?)
//	case success(String?)
//    case download(String?)
//}
//
