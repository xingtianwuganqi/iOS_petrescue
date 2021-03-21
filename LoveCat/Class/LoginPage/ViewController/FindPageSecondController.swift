//
//  FindPageSecondController.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/10.
//

import UIKit
import ReactorKit
import RxSwift

class FindPageSecondController: BaseViewController,View {


    @IBOutlet weak var backScroll: UIScrollView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var pswdTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    var pswdS1: String?
    var confrimS2: String?
    
    typealias Reactor = FindPswdChangeReactor
    fileprivate var account: String
    init(account: String,
         naviService: NavigatorServiceType) {
        self.account = account
        super.init(navi: naviService)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = "找回密码"
        self.setUI()
        self.reactor = FindPswdChangeReactor.init(account: self.account)
    }

    func setUI() {
        
        self.titleLab.font = UIFont.init(name: "Arial-BoldItalicMT", size: 24)
        self.titleLab.textColor = UIColor.color(.system)
        
        self.loginBtn.setTitle("确定", for: .normal)
        self.loginBtn.backgroundColor = UIColor.color(.system)
        self.loginBtn.setTitleColor(.white, for: .normal)
        
        self.pswdTextField.isSecureTextEntry = true
        self.confirmTextField.isSecureTextEntry = true
        
        self.pswdTextField.delegate = self
        self.confirmTextField.delegate = self

        
        backScroll.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(scrollClick))
        tap.numberOfTouchesRequired = 1
        tap.numberOfTapsRequired = 1
        backScroll.addGestureRecognizer(tap)
    }
    
    @objc func scrollClick() {
        self.resignFirst()
    }
    
    func resignFirst() {
        self.confirmTextField.resignFirstResponder()
        self.pswdTextField.resignFirstResponder()
    }
    @IBAction func pswdShowNum(_ sender: Any) {
        pswdTextField.resignFirstResponder()
        let button = sender as! UIButton
        guard let pswd = self.pswdS1,pswd.count > 0 else {
            return
        }
        button.isSelected = !button.isSelected
        if button.isSelected {
            pswdTextField.text = pswd
        }else {
            let len = pswd.count
            let n = ""
            let symbol1 = n.padding(toLength: len, withPad: "●", startingAt: 0)
            pswdTextField.text = symbol1
        }
    }
    
    @IBAction func confirmShowNum(_ sender: Any) {
        confirmTextField.resignFirstResponder()
        let button = sender as! UIButton
        guard let confrimPswd = self.confrimS2,confrimPswd.count > 0 else {
            return
        }
        button.isSelected = !button.isSelected
        if button.isSelected {
            confirmTextField.text = confrimPswd
        }else {
            let len = confrimPswd.count
            let n = ""
            let symbol1 = n.padding(toLength: len, withPad: "●", startingAt: 0)
            confirmTextField.text = symbol1
        }
    }
    
    
}

extension FindPageSecondController: UITextFieldDelegate {

    func bind(reactor: FindPswdChangeReactor) {
        
    }
    
    
    //每次開始輸入就將TextField初始化，並設定isSecureTextEntry = true啟用隱碼功能。
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if (textField == pswdTextField) {
            pswdTextField.text = ""
            pswdTextField.becomeFirstResponder()
            pswdTextField.isSecureTextEntry = true
        }
        
        if (textField == confirmTextField) {
            confirmTextField.text = ""
            confirmTextField.becomeFirstResponder()
            confirmTextField.isSecureTextEntry = true
        }
    }
    
    //每次結束輸入就將輸入值存到變數中以供送電文用，TextField欄位則設定isSecureTextEntry = false關閉隱碼功能，但是以"●"取代輸入值。
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        var len = 0;
        let n = ""
        
        if (textField == pswdTextField){
            pswdTextField.isSecureTextEntry = false
            len = pswdTextField.text!.count
            
            if (len == 0){
                pswdTextField.text = ""
            }else{
                pswdS1 = pswdTextField.text!
                let symbol1 = n.padding(toLength: len, withPad: "●", startingAt: 0)
                pswdTextField.text = symbol1
            }
        }
        
        if (textField == confirmTextField){
            confirmTextField.isSecureTextEntry = false
            len = confirmTextField.text!.count
            
            if (len == 0){
                confirmTextField.text = ""
            }else{
                confrimS2 = confirmTextField.text!
                let symbol2 = n.padding(toLength: len, withPad: "●", startingAt: 0)
                confirmTextField.text = symbol2
            }
        }
    }
    
}
