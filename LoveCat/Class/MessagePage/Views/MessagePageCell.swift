//
//  MessagePageCell.swift
//  LoveCat
//
//  Created by jingjun on 2021/3/31.
//

import UIKit
import ReactorKit
import ESTabBarController_swift
class MessagePageCell: UITableViewCell,View {
    
    typealias Reactor = MinePageCellReactor
    var disposeBag: DisposeBag = DisposeBag()
    lazy var iconImg : UIImageView = {
        let imageView = UIImageView.init()
        return imageView
    }()
    
    lazy var titleLab: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.color(.content)
        label.font = UIFont.et.fontSize()
        label.text = ""
        return label
    }()
    
    lazy var badgeView: ESTabBarItemBadgeView = {
        let badge = ESTabBarItemBadgeView.init()
        badge.isHidden = true
        return badge
    }()
    
    lazy var rightIcon : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage(named: "icon_center_allin")
        return imageView
    }()
    
    lazy var bottomLine: UIView = {
        let line = UIView.init()
        line.backgroundColor = UIColor.color(.tableBack)
        return line
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupConstraints() {
        self.contentView.addSubview(iconImg)
        self.contentView.addSubview(titleLab)
        self.contentView.addSubview(rightIcon)
        self.contentView.addSubview(bottomLine)
        self.contentView.addSubview(badgeView)
        
        iconImg.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 40, height: 40))
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        
        titleLab.snp.makeConstraints { (make) in
            make.left.equalTo(iconImg.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        
        badgeView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(rightIcon.snp.left).offset(-10)
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
        
        rightIcon.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 7, height: 12))
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
        }
        
        bottomLine.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab.snp.left)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
extension MessagePageCell {
    func bind(reactor: MinePageCellReactor) {
        
        reactor.state.map {
            $0.model.title
        }
        .bind(to: self.titleLab.rx.text)
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model.iconImg
        }.subscribe(onNext: { [weak self] iconImg in
            guard let `self` = self else { return }
            if let icon = iconImg {
                self.iconImg.image = UIImage(named: icon)
            }else{
                self.iconImg.image = UIImage()
            }
        })
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model.num
        }.subscribe(onNext: { [weak self] num in
            guard let `self` = self else { return }
            if num > 0 {
                self.badgeView.badgeValue = num.et_unread
                self.badgeView.isHidden = false
                let size = self.badgeView.sizeThatFits(self.contentView.frame.size)
                self.badgeView.snp.updateConstraints { (make) in
                    make.size.equalTo(size)
                }

            }else{
                self.badgeView.isHidden = true
            }
        }).disposed(by: disposeBag)
    }
}
