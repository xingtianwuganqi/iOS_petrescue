//
//  MessageTopicView.swift
//  LoveCat
//
//  Created by jingjun on 2021/3/29.
//

import UIKit
import YYKit

class MessageHeadView: UIView {
    lazy var headImg : UIImageView = {
        let imageView = UIImageView.init()
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var username: YYLabel = {
        let textView = YYLabel.init()
        textView.numberOfLines = 2
        textView.font = UIFont.et.fontSize()
        textView.textColor = UIColor.color(.content)
        textView.preferredMaxLayoutWidth = HomePageTableCell.contentWidth
        return textView
    }()
    
    lazy var timeLab: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.color(.desc)
        label.font = UIFont.et.font(size: 12)
        label.text = ""
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutViews()
    }
    
    func layoutViews() {
        self.addSubview(headImg)
        self.addSubview(username)
        self.addSubview(timeLab)
        
        self.headImg.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(15)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        username.snp.makeConstraints { (make) in
            make.top.equalTo(headImg)
            make.left.equalTo(headImg.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        timeLab.snp.makeConstraints { (make) in
            make.bottom.equalTo(headImg)
            make.left.equalTo(headImg.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

class MessageTopicView: UIView {
    
    lazy var imgView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var descLab: YYLabel = {
        let textView = YYLabel.init()
        textView.numberOfLines = 3
        textView.font = UIFont.et.fontSize()
        textView.textColor = UIColor.color(.content)
        textView.preferredMaxLayoutWidth = SCREEN_WIDTH - 120
        return textView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.color(.defIcon)
        layoutViews()
    }
    
    func layoutViews() {
        self.addSubview(imgView)
        self.addSubview(descLab)
        
        imgView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(1)
            make.bottom.equalToSuperview().offset(-1)
            make.size.equalTo(CGSize(width: 78, height: 78))
        }
        
        descLab.snp.makeConstraints { (make) in
            make.top.equalTo(imgView).offset(8)
            make.left.equalTo(imgView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.lessThanOrEqualTo(self.snp.bottom).offset(-8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
