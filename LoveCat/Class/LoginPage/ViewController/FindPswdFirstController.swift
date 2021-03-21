//
//  FindPswdFirstController.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/10.
//

import UIKit
import ReactorKit
import RxSwift
import HandyJSON
import Moya
import MBProgressHUD

class FindPswdFirstController: BaseViewController,View {

    @IBOutlet weak var backScroll: UIScrollView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var titleLab: UILabel!
    
    typealias Reactor = FindPswdConfirmReactor
    
    override init(navi: NavigatorServiceType) {
        super.init(navi: navi)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = "找回密码"
        self.setUI()
        self.reactor = Reactor()
    }

    func setUI() {
        
        self.titleLab.font = UIFont.init(name: "Arial-BoldItalicMT", size: 24)
        self.titleLab.textColor = UIColor.color(.system)
        
        self.loginBtn.setTitle("确定", for: .normal)
        self.loginBtn.backgroundColor = UIColor.color(.system)
        self.loginBtn.setTitleColor(.white, for: .normal)
        
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
        self.phoneTextField.resignFirstResponder()
    }

    @IBAction func confirmBtnClick(_ sender: Any) {
        self.phoneTextField.resignFirstResponder()
        guard let text = self.phoneTextField.text,text.count > 0 else {
            return
        }
        
        reactor?.action.onNext(.confirmPhone(phone: text))
    }
    
}
extension FindPswdFirstController {
    func bind(reactor: Reactor) {
        
        reactor.state.map {
            $0.phoneState
        }.distinctUntilChanged()
        .subscribe(onNext: { [weak self] (state) in
            guard let `self` = self else { return }
            guard state == true else {
                return
            }
            guard let text = self.phoneTextField.text else {
                return
            }
            if state {
                self.naviService.navigatorSubject.onNext(.changePswd(account: text))
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.errorMsg
        }.filter {
            $0 != nil
        }.subscribe(onNext: { msg in
            guard let message = msg else {
                return
            }
            MBProgressHUD.xy_show(message)
        }).disposed(by: disposeBag)
    }
    
    
}
