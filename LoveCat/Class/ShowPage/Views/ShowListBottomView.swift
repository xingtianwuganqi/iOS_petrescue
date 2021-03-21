//
//  ShowListBottomView.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/18.
//

import UIKit

class ShowListBottomView: UIView {
    
//    lazy var viewBtn: UIButton = {
//        let button = UIButton.init(type: .custom)
//        button.setImage(UIImage(named: "icon_home_find"), for: .normal)
//        button.setImage(UIImage(named: "icon_home_find"), for: .selected)
//        button.titleLabel?.font = UIFont.et.font(size: 13)
//        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
//        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
//        return button
//    }()

    lazy var likeBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "icon_zan_un"), for: .normal)
        button.setImage(UIImage(named: "icon_zan_se"), for: .selected)
        button.setTitleColor(UIColor.init(hexString: "#707070"), for: .normal)
        button.titleLabel?.font = UIFont.et.font(size: 13)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        return button
    }()
    
    
    lazy var collectionBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "icon_collection_un"), for: .normal)
        button.setImage(UIImage(named: "icon_collection_se"), for: .selected)
        button.setTitleColor(UIColor.init(hexString: "#707070"), for: .normal)
        button.titleLabel?.font = UIFont.et.font(size: 13)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        return button
    }()
    
    lazy var commentBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "icon_sh_commen"), for: .normal)
        button.setImage(UIImage(named: "icon_sh_commen"), for: .selected)
        button.titleLabel?.font = UIFont.et.font(size: 13)
        button.setTitleColor(UIColor.init(hexString: "#707070"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        return button
    }()
    
    fileprivate var btnWidth: CGFloat = 0
    
    init(width: CGFloat) {
        super.init(frame: .zero)
        self.btnWidth = width
        self.setUI()
    }
    
    func setUI() {
//        self.addSubview(viewBtn)
        self.addSubview(likeBtn)
        self.addSubview(commentBtn)
        self.addSubview(collectionBtn)
        
//        viewBtn.snp.makeConstraints { (make) in
//            make.top.bottom.equalToSuperview()
//            make.left.equalToSuperview()
//            make.width.equalTo(btnWidth / 4)
//        }
        
        likeBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalTo(btnWidth / 3)
        }
        
        collectionBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(likeBtn.snp.right)
            make.width.equalTo(likeBtn)

        }
        
        commentBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalTo(likeBtn)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
