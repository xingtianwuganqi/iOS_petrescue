//
//  SearchNavigationTitleView.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/4.
//
import UIKit

protocol SearchNavigationTitleViewDelegate: class {
    func textDidChange(_ searchView: SearchNavigationTitleView)
    func shouldReturn(_ searchView: SearchNavigationTitleView) -> Bool
    func didBeginEditing(_ searchView: SearchNavigationTitleView)
    func clickCancelAction(_ searchView: SearchNavigationTitleView)
    func clickClearText(_ searchView: SearchNavigationTitleView)
}

class SearchNavigationTitleView: UIView {
    weak var delegate: SearchNavigationTitleViewDelegate?
    var IsSearchShopcar:Bool = false
    private class SearchNavigationTitleViewTextField: UITextField {
        
        var textDidChangeBlock: ((_ text: String?) -> Void)?
        
        override var text: String? {
            didSet {
                if text != oldValue {
                    if let block = self.textDidChangeBlock {
                        block(text)
                    }
                }
            }
        }
        
        override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
            var rect = super.leftViewRect(forBounds: bounds)
            rect.origin.x = 8.0
            return rect
        }
    }
    
    lazy var textField: UITextField = {
        let textField = SearchNavigationTitleViewTextField()
        textField.backgroundColor = RGBA(238, 238, 238, 1.0)
        textField.textColor = UIColor.init(hexString: "#494949")
        textField.font = UIFont.et.font(.regular, size: 14)
        textField.placeholder = "请输入关键字"
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#bfbfbf")!])
        textField.layer.cornerRadius = 15
        textField.clearButtonMode = .always
        textField.returnKeyType = .search
        textField.tintColor = UIColor(hexString: "#63C6F9", alpha: 1)
        return textField
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("取消", for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.et.fontSize(.regular, .title)
        button.setTitleColor(UIColor.init(hexString: "292929"), for: UIControl.State.normal)
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .center
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        isUserInteractionEnabled = true
        textField.addTarget(self, action: #selector(editingChanged), for: UIControl.Event.editingChanged)
        textField.delegate = self
        self.addSubview(textField)
        self.addSubview(cancelButton)
        cancelButton.addTarget(self, action: #selector(cancelAction), for: UIControl.Event.touchUpInside)
        (textField as? SearchNavigationTitleViewTextField)?.textDidChangeBlock = {[weak self] text in
            self?.delegate?.textDidChange(self!)
        }
        
        let searchIcon = UIButton(frame: CGRect(x: 0, y: 0, width: 20.0, height: 15.0))
        searchIcon.setImage(UIImage(named: "icon_wx_search"), for: .normal)
        searchIcon.isUserInteractionEnabled = false
        searchIcon.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5.0)
        searchIcon.contentHorizontalAlignment = .left
        searchIcon.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        searchIcon.clipsToBounds = false
        textField.leftView = searchIcon
        textField.leftViewMode = .always
    
    }
    
    @objc func cancelAction() {
        delegate?.clickCancelAction(self)
    }
    
    @objc func clickSearchKeyBoxBtn() {
        self.textField.text = ""
    }
    
    deinit {
        print("SearchBarView deinit")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let textFieldHeight = self.bounds.size.height - 8.0
        let textFieldY = (self.bounds.size.height - textFieldHeight) * 0.5
        let cancelButtonW = CGFloat(50.0)
        textField.frame = CGRect(x: 0, y: textFieldY, width: self.frame.size.width - cancelButtonW - 5.0, height: textFieldHeight)
        if(self.IsSearchShopcar){
            cancelButton.frame = CGRect(x: textField.frame.maxX + 20.0, y: 0, width: cancelButtonW, height: self.bounds.size.height)
        }else{
            cancelButton.frame = CGRect(x: textField.frame.maxX + 5.0, y: 0, width: cancelButtonW, height: self.bounds.size.height)
        }

    }
    
    override var intrinsicContentSize:CGSize{
        
        return UIView.layoutFittingExpandedSize
        
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool { self.textField.becomeFirstResponder() }
    
    
    override var isFirstResponder: Bool { self.textField.isFirstResponder }
    
    @discardableResult
    override func resignFirstResponder() -> Bool { self.textField.resignFirstResponder() }
}

extension SearchNavigationTitleView : UITextFieldDelegate {
    
    @objc func editingChanged() {
        delegate?.textDidChange(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate?.shouldReturn(self) ?? false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.didBeginEditing(self)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField.text?.count ?? 0 > 0 {
            delegate?.clickClearText(self)
        }
        return true
    }
    
    
}
