//
//  CreateGambitController.swift
//  LoveCat
//
//  Created by jingjun on 2021/4/9.
//

import UIKit
import YYKit
import RxSwift
import MBProgressHUD

class CreateGambitController: UIViewController {
    let disposeBag = DisposeBag()
    lazy var releaseBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("确定", for: .normal)
        button.titleLabel?.font = UIFont.et.font(size: 13)
        button.setTitleColor(UIColor.color(.system), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        return button
    }()
    
    lazy var backView: UIView = {
        let backView = UIView.init()
        backView.backgroundColor = .white
        backView.layer.cornerRadius = 8
        backView.layer.masksToBounds = true
        return backView
    }()
    
    lazy var imgIcon : UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "icon_show_gb")
        return img
    }()
    
    lazy var textField: UITextField = {
        let textField = UITextField.init()
        textField.font = UIFont.et.fontSize()
        textField.placeholder = "发起一个有趣的话题"
        textField.returnKeyType = .done
        textField.keyboardType = .default
        return textField
    }()
    
    lazy var remindLab : YYLabel = {
        let remind = YYLabel.init()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = scaleXSize(3.0)     //设置行间距
        paragraphStyle.alignment = .justified      //文本对齐方向
        let attribute = NSMutableAttributedString.init()
        let title = "发起话题后需要审核，审核通过后将展示在话题列表，禁止出现商业广告、低俗、色情、暴力、具有侮辱性语音或与宠物无关等内容！"
        attribute.append(NSAttributedString(string: title,
                                            attributes: [
                                                NSAttributedString.Key.foregroundColor: UIColor.color(.desc)!,
                                                NSAttributedString.Key.font: UIFont.et.font(size: 13),
                                                NSAttributedString.Key.paragraphStyle: paragraphStyle
                                            ]))
        remind.attributedText = attribute
        remind.numberOfLines = 0
        remind.preferredMaxLayoutWidth = SCREEN_WIDTH - 30
        return remind
    }()
    
    lazy var networking = NetWorking<ShowPageApi>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "发起话题"
        self.view.backgroundColor = UIColor.color(.defIcon)
        layoutViews()
        self.textField.delegate = self
        NotificationCenter.default.addObserver(self, selector:
                    #selector(textFieldChanged), name:
                    NSNotification.Name(rawValue:
                        "UITextFieldTextDidChangeNotification"),
                                                              object:self.textField)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: releaseBtn)
        releaseBtn.addTarget(self, action: #selector(releaseBtnClick), for: .touchUpInside)
    }
    
    func layoutViews() {
        
        self.view.addSubview(backView)
        backView.addSubview(imgIcon)
        backView.addSubview(textField)
        self.view.addSubview(remindLab)
        
        backView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(55)
        }
        
        imgIcon.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 18, height: 18))
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        
        textField.snp.makeConstraints { (make) in
            make.left.equalTo(imgIcon.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
        
        self.remindLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(backView.snp.bottom).offset(15)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.textField.resignFirstResponder()
    }
}
extension CreateGambitController {
    @objc func textFieldChanged(obj:Notification) {
            let limit : Int = 20
            let textField : UITextField = obj.object as! UITextField
            //非markedText才继续往下处理
            guard let _: UITextRange = textField.markedTextRange else{
        
                if(textField.text! as NSString).length > limit{
                    MBProgressHUD.xy_hide()
                    MBProgressHUD.xy_show("最多支持20个字哦")
                    textField.text = (textField.text! as NSString).substring(to:limit)
                }
                return
            }
        }
    
    @objc func releaseBtnClick() {
        guard let text = self.textField.text,text.count > 0 else {
            MBProgressHUD.xy_hide()
            MBProgressHUD.xy_show("请输入话题")
            return
        }
        self.pushNetwoking(content: text)
    }
    
    func pushNetwoking(content: String) {
        let user_id = UserManager.shared.userId
        self.networking.request(.createGambit(content: content, user_id: user_id)).mapData(EmptyModel.self).subscribe(onNext: { [weak self] baseModel in
            guard let `self` = self else { return }
            if baseModel?.isSuccess ?? false {
                MBProgressHUD.xy_hide()
                MBProgressHUD.xy_show("提交成功")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    self.navigationController?.popViewController(animated: true)
                }
            }else{
                MBProgressHUD.xy_hide()
                MBProgressHUD.xy_show("提交失败")
            }
        }).disposed(by: disposeBag)
    }
}
extension CreateGambitController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = self.textField.text,text.count > 0 else {
            MBProgressHUD.xy_hide()
            MBProgressHUD.xy_show("请输入话题")
            return false
        }
        self.pushNetwoking(content: text)
        return true
    }
}

