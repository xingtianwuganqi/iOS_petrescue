//
//  ChangePswdViewController.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/21.
//

import UIKit
import RxSwift
import MBProgressHUD
class ChangePswdViewController: UIViewController  {
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var newTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    var disposeBag = DisposeBag()
    
    let networking = NetWorking<MinePageApi>()
    
    lazy var saveBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("提交", for: .normal)
        button.setTitleColor(UIColor.color(.system), for: .normal)
        button.titleLabel?.font = UIFont.et.font(.medium, size: 15)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 40)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.color(.defIcon)
        self.title = "修改密码"
        self.setUI()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: saveBtn)
        saveBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let origin = self?.originTextField.text,origin.count > 0 else {
                MBProgressHUD.xy_show("请输入原密码")
                return
            }
            guard let newPswd = self?.newTextField.text,newPswd.count >= 6 else {
                MBProgressHUD.xy_show("请输入六位或六位以上密码密码")
                return
            }
            guard let confirm = self?.confirmTextField.text,newPswd == confirm else {
                MBProgressHUD.xy_show("新密码与确认密码不同")
                return
            }
            self?.changePswdNetworking(origin: origin, newPswd: newPswd, confirm: confirm)
        }).disposed(by: disposeBag)
    }

    func setUI() {
        self.bottomLineView.backgroundColor = UIColor.color(.defIcon)
        self.topLineView.backgroundColor = UIColor.color(.defIcon)
        
        self.originTextField.placeholder = "请输入原密码"
        self.originTextField.font = UIFont.et.fontSize()
        self.originTextField.textColor = UIColor.color(.content)
        self.originTextField.returnKeyType = .done
        self.originTextField.clearButtonMode = .whileEditing
        self.originTextField.delegate = self
        
        self.newTextField.placeholder = "请输入新密码（不少于6位）"
        self.newTextField.font = UIFont.et.fontSize()
        self.newTextField.textColor = UIColor.color(.content)
        self.newTextField.returnKeyType = .done
        self.newTextField.clearButtonMode = .whileEditing
        self.newTextField.delegate = self
        
        self.confirmTextField.placeholder = "请确认新密码"
        self.confirmTextField.font = UIFont.et.fontSize()
        self.confirmTextField.textColor = UIColor.color(.content)
        self.confirmTextField.returnKeyType = .done
        self.confirmTextField.clearButtonMode = .whileEditing
        self.confirmTextField.delegate = self
        
        self.originTextField.isSecureTextEntry = true
        self.newTextField.isSecureTextEntry = true
        self.confirmTextField.isSecureTextEntry = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
}
extension ChangePswdViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
    
    func changePswdNetworking(origin: String,newPswd: String,confirm: String) {
        MBProgressHUD.xy_show(activity: nil)
        _ = self.networking.request(.changePswd(originPswd: origin.et.md5String, newPswd: newPswd.et.md5String, confrimPswd: confirm.et.md5String)).mapData(EmptyModel.self).subscribe(onNext: { (baseModel) in
            if baseModel?.isSuccess ?? false {
                MBProgressHUD.xy_show("密码修改成功")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.navigationController?.popViewController(animated: true)
                }
            }else{
                MBProgressHUD.xy_show("修改失败")
            }
        })
    }
}
