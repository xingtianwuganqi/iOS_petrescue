//
//  AccountHeaderView.swift
//  App-720yun
//
//  Created by jingjun on 2019/2/20.
//  Copyright © 2019 720yun. All rights reserved.
//

import UIKit
import RxSwift

let ScreenW = UIScreen.main.bounds.size.width
let statusBarH = UIApplication.shared.statusBarFrame.size.height

class AccountHeaderView: UIView {
    
    static let backHeight = 110 + SystemNavigationBarHeight
    
    var disposeBag = DisposeBag()
    
    lazy var panoView : UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage.image(UIColor.color(.system)!)
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        return imgView
    }()
    
    
    var bgImgFrame: CGRect
    
    // 展示其他信息
    lazy var infoView: UserInfoView = {
        let infoView = UINib(nibName: "UserInfoView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! UserInfoView
        return infoView
    }()
    
    lazy var backPanoView :  UIView = {
        let view = UIView()
        return view
    }()
    
    var cellModel: UserInfoModel? {
        didSet {
            self.infoView.cellModel = cellModel
        }
    }
        
    override init(frame:CGRect) {
        
        self.bgImgFrame = CGRect(x: 0, y: 0, width: ScreenW, height: AccountHeaderView.backHeight)
        super.init(frame: frame)
                
        self.addSubview(backPanoView)
        self.backPanoView.addSubview(panoView)
        // 展示其他信息
        self.addSubview(infoView)
        
        self.backPanoView.frame = self.bgImgFrame
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.panoView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.infoView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20)
            make.left.right.equalToSuperview()
            make.height.equalTo(80)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func scrollVieDidScroll(offsetY: CGFloat) {
        
        // 在tableview滑动过程中重新这只backPanoView 的frame
        if offsetY <= 0{
            var rect = self.backPanoView.frame
            rect.origin.y = offsetY
            rect.size.height = AccountHeaderView.backHeight - offsetY
            self.backPanoView.frame = rect
            self.panoView.setNeedsLayout()
            
        }
        
    }
}
