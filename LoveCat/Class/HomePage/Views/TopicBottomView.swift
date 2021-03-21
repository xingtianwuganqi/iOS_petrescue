//
//  TopicBottomView.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/1.
//

import UIKit

class TopicBottomView: UIView {

    lazy var viewBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "icon_home_find"), for: .normal)
        button.setTitleColor(UIColor.init(hexString: "#707070"), for: .normal)
        button.titleLabel?.font = UIFont.et.font(size: 13)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        return button
    }()
    
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
    fileprivate var btnWidth: CGFloat = 0
    init(width: CGFloat) {
        super.init(frame: .zero)
        self.btnWidth = width
        layoutUI()
    }
    
    func layoutUI() {
        self.addSubview(viewBtn)
        self.addSubview(likeBtn)
        self.addSubview(collectionBtn)
        
        viewBtn.snp.makeConstraints { (make) in
            make.width.equalTo(btnWidth / 3)
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        likeBtn.snp.makeConstraints { (make) in
            make.width.equalTo(btnWidth / 3)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        collectionBtn.snp.makeConstraints { (make) in
            make.width.equalTo(btnWidth / 3)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
