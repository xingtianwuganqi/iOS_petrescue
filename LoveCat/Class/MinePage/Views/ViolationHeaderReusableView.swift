//
//  ViolationHeaderReusableView.swift
//  LoveCat
//
//  Created by jingjun on 2021/3/15.
//

import UIKit
import YYKit
import RxSwift
class ViolationHeaderReusableView: UICollectionReusableView {
    
    lazy var descStr: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.color(.content)
        label.font = UIFont.et.fontSize()
        label.text = "请选择对应理由，理由与内容不符，会延迟处理"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(descStr)
        descStr.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ViolationFooterReusableView: UICollectionReusableView {
    var disposeBag = DisposeBag()
    lazy var pushBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("提交", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.color(.system)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    lazy var protocalStr: UILabel = {
        let label = UILabel.init()
        label.textAlignment = .center
        return label
    }()
    
    var clickActionHandler:((Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(pushBtn)
        self.addSubview(protocalStr)
        
        pushBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(40)
        }
        
        protocalStr.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(pushBtn.snp.bottom).offset(15)
            make.height.equalTo(16)
        }
        
        let attrbute = NSMutableAttributedString()
        attrbute.append(NSAttributedString(string: "了解", attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.content)!, NSAttributedString.Key.font: UIFont.et.fontSize()]))
        attrbute.append(NSAttributedString(string: " 用户协议 ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.system)!, NSAttributedString.Key.font: UIFont.et.fontSize()]))

        self.protocalStr.attributedText = attrbute
        protocalStr.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.clickActionHandler?(2)
        }).disposed(by: disposeBag)
        
        pushBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.clickActionHandler?(1)
        }).disposed(by: disposeBag)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
