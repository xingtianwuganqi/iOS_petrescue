//
//  SuggestionViewController.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/12.
//

import UIKit
import YYKit
import MBProgressHUD
class SuggestionViewController: BaseViewController {
    
    lazy var descLab: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.color(.desc)
        label.font = UIFont.et.fontSize()
        label.text = "请输入您的建议"
        return label
    }()
    
    lazy var textView: YYTextView = {
        let textView = YYTextView.init()
        textView.placeholderText = "您的意见对我们非常重要"
        textView.placeholderFont = UIFont.et.fontSize()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.color(.defIcon)?.cgColor
        textView.layer.cornerRadius = 6
        textView.layer.masksToBounds = true
        textView.font = UIFont.et.fontSize()
        textView.textColor = UIColor.color(.content)
        textView.returnKeyType = .next
        return textView
    }()
    
    lazy var contactDesc: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.color(.desc)
        label.font = UIFont.et.fontSize()
        label.text = "请输入您的联系方式"
        return label
    }()
    
    lazy var saveBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("提交", for: .normal)
        button.setTitleColor(UIColor.color(.system), for: .normal)
        button.titleLabel?.font = UIFont.et.fontSize(.medium, .content)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 40)
        return button
    }()
    
    lazy var phoneTextField: UITextField = {
        let textView = UITextField.init()
        textView.font = UIFont.et.fontSize()
        textView.textColor = UIColor.color(.content)
        textView.placeholder = "请输入联系方式"
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.color(.defIcon)?.cgColor
        textView.layer.cornerRadius = 6
        textView.layer.masksToBounds = true
        textView.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 10))
        textView.leftViewMode = .always
        textView.returnKeyType = .done
        return textView
    }()
    
    lazy var networking = NetWorking<MinePageApi>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "意见反馈"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: self.saveBtn)
        self.saveBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.resignFirst()
            guard let content = self.textView.text,content.count > 0 else {
                self.view.xy_show("请输入意见或建议")
                return
            }
            guard let contact = self.phoneTextField.text,contact.count > 0 else {
                self.view.xy_show("请输入联系方式")
                return
            }
            self.networking(content: content, contact: contact)
        }).disposed(by: disposeBag)
//        self.textView.delegate = self
        self.phoneTextField.delegate = self
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        self.view.addSubview(self.descLab)
        self.view.addSubview(textView)
        self.view.addSubview(contactDesc)
        self.view.addSubview(phoneTextField)
        
        self.descLab.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        self.textView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: SCREEN_WIDTH - 40, height: 170))
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(descLab.snp.bottom).offset(10)
        }
        
        self.contactDesc.snp.makeConstraints { (make) in
            make.top.equalTo(textView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        self.phoneTextField.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: SCREEN_WIDTH - 40, height: 40))
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(contactDesc.snp.bottom).offset(10)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.resignFirst()
    }
    
    func resignFirst() {
        self.textView.resignFirstResponder()
        self.phoneTextField.resignFirstResponder()
    }
}

extension SuggestionViewController: UITextFieldDelegate,YYTextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resignFirst()
        return true
    }
    
    func networking(content: String,contact: String) {
        MBProgressHUD.xy_show(activity: "提交中...")
        self.networking.request(.suggestion(content: content, contact: contact)).mapData(EmptyModel.self).subscribe(onNext: { [weak self] model in
            guard let `self` = self else { return }
            MBProgressHUD.xy_hide()
            if model?.isSuccess ?? false {
                MBProgressHUD.xy_show("提交成功")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.navigationController?.popViewController(animated: true)
                }
            }else{
                MBProgressHUD.xy_show("提交失败")
            }
        },onError: { _ in
            MBProgressHUD.xy_show("提交失败")
        }).disposed(by: disposeBag)
    }
    
}
