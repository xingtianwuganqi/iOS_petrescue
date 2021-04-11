//
//  SystemMsgCell.swift
//  LoveCat
//
//  Created by jingjun on 2021/4/7.
//

import UIKit
import ReactorKit
import SnapKit
import SafariServices
class SystemMsgCell: UITableViewCell,View, UITextViewDelegate {
    
    typealias Reactor = SystemMsgCellReactor
    var disposeBag: DisposeBag = DisposeBag()
    
    lazy var titleLab: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.color(.title)
        label.font = UIFont.et.fontSize(.bold, .title)
        label.text = "公告"
        return label
    }()
    
    lazy var timeLab: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.color(.desc)
        label.font = UIFont.et.fontSize(.regular, .desc)
        return label
    }()
    
    lazy var detailText : UITextView = {
        let textview = UITextView.init()
        textview.font = UIFont.et.fontSize()
        textview.textColor = UIColor.color(.content)
        textview.isEditable = false;        //必须禁止输入，否则点击将弹出输入键盘
        textview.isScrollEnabled = false;
        textview.delegate = self
        textview.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textview.textAlignment = .justified
        return textview
    }()
    
    lazy var bottomLine : UIView = {
        let backview = UIView()
        backview.backgroundColor = UIColor.color(.defIcon)
        return backview
    }()
    
    var detailHeight: Constraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        layoutViews()
    }
    
    func layoutViews() {
        self.contentView.addSubview(titleLab)
        self.contentView.addSubview(detailText)
        self.contentView.addSubview(timeLab)
        self.contentView.addSubview(bottomLine)
        
        titleLab.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(20)
        }
        
        timeLab.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLab)
            make.right.equalToSuperview().offset(-15)
        }
        
        detailText.snp.makeConstraints { (make) in
            make.top.equalTo(titleLab.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            detailHeight = make.height.equalTo(40).constraint
        }
        
        bottomLine.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(0.5)
            make.top.equalTo(detailText.snp.bottom).offset(10)
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
    
    //用这个方法获取url,获取url的数组
    
    private func getUrls(str:String) -> [String] {
        var urls = [String]()
        // 创建一个正则表达式对象
        do{
            let dataDetector = try NSDataDetector(types:
                                                    NSTextCheckingTypes(NSTextCheckingResult.CheckingType.link.rawValue))
            // 匹配字符串，返回结果集
            let res = dataDetector.matches(in: str,
                                           options:NSRegularExpression.MatchingOptions(rawValue:0),
                                           range:NSMakeRange(0, str.count))
            // 取出结果
            for checkingRes in res {
                urls.append((str as NSString).substring(with: checkingRes.range))
            }
        }
        catch{
            print(error)
        }
        return urls
    }
    
    //最后实现textView的代理方法，点击url触发事件
    private func textView(_textView:UITextView, shouldInteractWith URL:URL, in characterRange:NSRange, interaction:UITextItemInteraction) ->Bool{
        if UIApplication.shared.canOpenURL(URL) {
            UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        }
        return false
    
    }

}
extension SystemMsgCell {
    func bind(reactor: SystemMsgCellReactor) {
        
        reactor.state.map {
            $0.model?.timeStr
        }.bind(to: self.timeLab.rx.text)
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.content
        }.subscribe(onNext: { [weak self] content in
            guard let `self` = self else { return }
            guard let content = content else {
                return
            }
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 3    //设置行间距
            paragraphStyle.alignment = .justified
            
            let arr = self.getUrls(str: content)
            let attrubuteStr = NSMutableAttributedString(string: content)
            if arr.count > 0{
                for i in arr {
                    let nsString = NSString(string: content)
                    let bigRange = nsString.range(of: content)
                    let range = nsString.range(of: i)
                    attrubuteStr.addAttribute(NSAttributedString.Key.font, value:  UIFont.et.fontSize(), range: bigRange)
                    attrubuteStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.color(.urlColor)!, range: range)
                    attrubuteStr.addAttribute(NSAttributedString.Key.link, value: i, range: range)
                    attrubuteStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: bigRange)

                }
            }else{
                let nsString = NSString(string: content)
                let bigRange = nsString.range(of: content)
                attrubuteStr.addAttribute(NSAttributedString.Key.font, value:  UIFont.et.fontSize(), range: bigRange)
                attrubuteStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: bigRange)
            }
            let constriant = attrubuteStr.boundingRect(with: CGSize(width: SCREEN_WIDTH - 30, height: CGFloat.infinity), options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).height
            self.detailHeight?.update(offset: constriant + 10)
            self.detailText.attributedText = attrubuteStr
            
        }).disposed(by: disposeBag)
    }
}
