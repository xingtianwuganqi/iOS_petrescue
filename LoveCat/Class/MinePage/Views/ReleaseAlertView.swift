//
//  ReleaseAlertView.swift
//  LoveCat
//
//  Created by jingjun on 2021/3/15.
//

import UIKit
import YYKit
class ReleaseAlertView: UIView {
    
    let AlertWidth: CGFloat = 375
    
    lazy var contentLab: YYLabel = {
        let label = YYLabel.init()
        label.textColor = UIColor.color(.content)
        label.font = UIFont.et.fontSize(.regular, .content)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView.init()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        return stackView
    }()
    
    lazy var remindStr: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.color(.content)
        label.font = UIFont.et.fontSize(.regular, .content)
        label.text = "不再提示"
        return label
    }()
    
    lazy var selectBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "icon_lo_unse"), for: .normal)
        button.setImage(UIImage(named: "icon_lo_sele"), for: .selected)
        return button
    }()
    var isSelected:Bool = false
    var clickProtocalUrl: (() -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(contentLab)
        self.addSubview(stackView)
        stackView.addArrangedSubview(selectBtn)
        stackView.addArrangedSubview(remindStr)
        
        
        let attrbute = NSMutableAttributedString()
        //设置段落属性
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = scaleXSize(1.0)     //设置行间距
        paragraphStyle.alignment = .justified      //文本对齐方向
        
        attrbute.append(NSAttributedString(string: "      请详细阅读", attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.content)!, NSAttributedString.Key.font: UIFont.et.fontSize(), NSAttributedString.Key.paragraphStyle: paragraphStyle]))
        
        attrbute.append(NSAttributedString(string: "用户协议", attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.urlColor)!, NSAttributedString.Key.font: UIFont.et.fontSize(), NSAttributedString.Key.paragraphStyle: paragraphStyle]))
        attrbute.append(NSAttributedString(string: "，特别是用户权利和义务部分，发布内容时请严格遵守用户协议。\n", attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.content)!, NSAttributedString.Key.font: UIFont.et.fontSize(), NSAttributedString.Key.paragraphStyle: paragraphStyle]))
        attrbute.append(NSAttributedString(string: "    禁止出现商业广告、低俗、色情、暴力、具有侮辱性语音或与宠物无关等内容，违规者帖子会被删除！", attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.content)!, NSAttributedString.Key.font: UIFont.et.fontSize(), NSAttributedString.Key.paragraphStyle: paragraphStyle]))
        
        attrbute.setTextHighlight(NSRange.init(location: 10, length: 4), color: nil, backgroundColor: nil) { [weak self](_, _, _, _) in
            printLog("点击事件")
            self?.clickProtocalUrl?()
        }
        let att = attrbute.boundingRect(with: CGSize(width: AlertWidth - 80, height: CGFloat.infinity), options: [.usesLineFragmentOrigin,.usesFontLeading], context: nil)
        self.contentLab.attributedText = attrbute
        self.setupConstraints(attHeight: att.height)
        self.selectBtn.addTarget(self, action: #selector(selectBtnClick(btn:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints(attHeight: CGFloat) {
        self.frame = CGRect(x: 0, y: 0, width: AlertWidth - 40, height: attHeight + 70)
        self.contentLab.frame = CGRect(x: 20, y: 10, width: AlertWidth - 80, height: attHeight + 20 )
        self.stackView.frame = CGRect(x: (AlertWidth / 2) - 70, y: attHeight + 25, width: 100, height: 25 )
    }
    
    @objc func selectBtnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        self.isSelected = btn.isSelected
    }
}
