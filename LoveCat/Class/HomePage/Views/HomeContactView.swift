//
//  HomeContactView.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/6.
//

import UIKit
import RxSwift

class HomeAddressView: UIView {
    
    lazy var addressBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitleColor(UIColor(hexString: "#707070"), for: .normal)
        button.titleLabel?.font = UIFont.et.font(size: 13)
        button.backgroundColor = .white
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    func setupConstraints() {
        self.addSubview(addressBtn)
        
        self.addressBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.right.lessThanOrEqualTo(self.snp.right)
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HomeContactView: UIView {
    
    lazy var contactBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("点击获取联系方式", for: .normal)
        button.setTitleColor( UIColor.color(.content), for: .normal)
        button.titleLabel?.font = UIFont.et.fontSize()
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor.color(.defIcon)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    func setupConstraints() {
        self.addSubview(contactBtn)
        
        self.contactBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
