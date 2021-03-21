//
//  SettingEditCell.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/11.
//

import UIKit
import RxSwift
import MBProgressHUD

class SettingEditCell: UITableViewCell {
    var disposeBag = DisposeBag()
    lazy var descLab: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.color(.desc)
        label.font = UIFont.et.fontSize()
        return label
    }()
    
    lazy var editText: UITextField = {
        let label = UITextField.init()
        label.textColor = UIColor.color(.content)
        label.font = UIFont.et.fontSize()
        label.returnKeyType = .done
        return label
    }()
    
    lazy var rightIcon : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage(named: "icon_center_allin")
        imageView.isHidden = true
        return imageView
    }()
    
    lazy var bottomLine : UIView = {
        let backview = UIView()
        backview.backgroundColor = UIColor.color(.tableBack)
        return backview
    }()
    
    var model: UserEditModel? {
        didSet {
            guard let model = model else {
                return
            }
            self.descLab.text = model.title
            self.editText.placeholder = model.placeholder
            self.editText.text = model.textValue
            
        }
    }
    
    var textChanged: ((String?) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.setupConstraints()
        
//        self.editText.rx.text.share().asObservable().subscribe(onNext: { text in
//            self.textChanged?(text)
//        }).disposed(by: disposeBag)
        
        self.editText.delegate = self
        
        NotificationCenter.default.addObserver(self, selector:
                    #selector(textFieldChanged), name:
                    NSNotification.Name(rawValue:
                        "UITextFieldTextDidChangeNotification"),
                                                              object:self.editText)
    }
    
    @objc func textFieldChanged(obj:Notification) {
          let limit : Int = 8
          let textField : UITextField = obj.object as! UITextField
          //非markedText才继续往下处理
          guard let _: UITextRange = textField.markedTextRange else{
              textField.text = filtercharactor(searchText: (textField.text ?? ""), regexStr: "[^\u{4e00}-\u{9fa5}]")
              if(textField.text! as NSString).length > limit{
                  MBProgressHUD.xy_hide()
                  MBProgressHUD.xy_show("最多支持8个字哦")
                  textField.text = (textField.text! as NSString).substring(to:limit)
              }
                self.textChanged?(textField.text)
              return
          }
      }
    func filtercharactor(searchText: String,regexStr: String) -> String? {
           if let regex = try? NSRegularExpression.init(pattern: regexStr, options: .caseInsensitive) {
               let resultStr = regex.stringByReplacingMatches(in: searchText, options: .reportCompletion, range: NSRange(location: 0, length: searchText.count), withTemplate: "")
               return resultStr
           }else{
               return nil
           }
       }
    
    func setupConstraints() {
        self.contentView.addSubview(descLab)
        self.contentView.addSubview(editText)
        self.contentView.addSubview(bottomLine)
        self.contentView.addSubview(rightIcon)
        
        self.descLab.setContentHuggingPriority(.required, for: .horizontal)
        self.descLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        self.editText.snp.makeConstraints { (make) in
            make.left.equalTo(descLab.snp.right).offset(15)
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        
        bottomLine.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        rightIcon.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 7, height: 12))
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
extension SettingEditCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.editText.resignFirstResponder()
        return true
    }
    
    
}
