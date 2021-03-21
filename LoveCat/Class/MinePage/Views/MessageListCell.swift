//
//  MessageListCell.swift
//  LoveCat
//
//  Created by jingjun on 2021/2/3.
//

import UIKit
import ReactorKit
import YYKit
class MessageListCell: UITableViewCell,View {
    var disposeBag = DisposeBag()
    typealias Reactor = AuthMsgCellReactor
    
    lazy var textView: YYLabel = {
        let textView = YYLabel.init()
        textView.numberOfLines = 0
        textView.font = UIFont(name: "TimesNewRomanPSMT", size: 14)
        textView.textColor = UIColor.color(.content)
        textView.preferredMaxLayoutWidth = SCREEN_WIDTH - 30
        return textView
    }()
    
    lazy var timeLab: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.color(.mark)
        label.font = UIFont.et.fontSize(.regular, .small)
        return label
    }()
    
    lazy var line : UIView = {
        let backview = UIView()
        backview.backgroundColor = UIColor.color(.tableBack)
        return backview
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.setupUI()
    }
    
    func setupUI() {
        self.contentView.addSubview(textView)
        self.contentView.addSubview(timeLab)
        self.contentView.addSubview(line)
        textView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        timeLab.snp.makeConstraints { (make) in
            make.top.equalTo(textView.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalTo(line.snp.top).offset(-10)
        }
        
        line.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
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
extension MessageListCell {
    func bind(reactor: AuthMsgCellReactor) {
        reactor.state.map {
            $0.model?.msgAttr
        }.subscribe(onNext: { [weak self] attribute in
            guard let `self` = self else { return }
            self.textView.attributedText = attribute
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.create_time
        }.bind(to: timeLab.rx.text)
        .disposed(by: disposeBag)
    }
}
