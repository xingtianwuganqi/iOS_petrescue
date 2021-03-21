//
//  CommentInputView.swift
//  LoveCat
//
//  Created by jingjun on 2021/2/1.
//

import UIKit
class CommentInputView: UIView {
    lazy var textField : UITextField = {
        let backview = UITextField()
        backview.returnKeyType = .done
        backview.layer.cornerRadius = 2
        backview.layer.masksToBounds = true
        backview.backgroundColor = .white
        backview.placeholder = "请输入评论"
        backview.font = UIFont.et.font(size: 14)
        backview.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        backview.leftViewMode = .always
        return backview
    }()
    
    lazy var sendBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("发送", for: .normal)
        button.setTitleColor(rgb(52,52,52), for: .normal)
        button.titleLabel?.font = UIFont.et.fontSize(.medium, .content)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = rgb(246,246,246)
        self.setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        self.addSubview(textField)
        self.addSubview(sendBtn)
        
        self.textField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(5)
            make.height.equalTo(40)
            make.right.equalTo(sendBtn.snp.left).offset(-10)
        }
        
        self.sendBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.size.equalTo(CGSize(width: 50, height: 40))
            make.top.equalToSuperview().offset(5)
        }
    }
}
