//
//  TopicDetailBottomView.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/11.
//

import UIKit

class TopicDetailBottomView: UIView {

    lazy var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.color(.tableBack)
        return line
    }()
    
    lazy var bottomView: TopicBottomView = {
        let btmView = TopicBottomView.init(width: SCREEN_WIDTH)
        return btmView
    }()

    lazy var contactBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("点击获取联系方式", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.color(.system)
        button.titleLabel?.font = UIFont.et.fontSize(.medium, .content)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 40)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    func setupConstraints() {
        self.addSubview(self.bottomView)
        self.addSubview(self.contactBtn)
        self.addSubview(self.lineView)
        self.bottomView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(50)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        self.contactBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(5)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(40)
        }
        
        self.lineView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.height.equalTo(0.5)
            make.left.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
