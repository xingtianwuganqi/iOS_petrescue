//
//  MyCollectionCell.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/7.
//

import UIKit
import ReactorKit
import YYKit
class MyCollectionCell: UITableViewCell,View {
    var disposeBag: DisposeBag = DisposeBag()
    typealias Reactor = HomePageItemReactor
    
    lazy var headImg: UIImageView = {
        let imageView = UIImageView.init()
        imageView.layer.cornerRadius = 11
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var nickName : UILabel = {
        let nickName = UILabel.init()
        nickName.textColor = UIColor.color(.desc)
        nickName.font = UIFont.et.fontSize(.regular, .desc)
        return nickName
    }()
    
    lazy var content: YYLabel = {
        let content = YYLabel.init()
        content.textColor = UIColor.color(.content)
        content.font = UIFont.et.fontSize()
        content.preferredMaxLayoutWidth = SCREEN_WIDTH - 30
        content.numberOfLines = 7
        let text = NSMutableAttributedString()
        text.append(NSAttributedString.init(string: "...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.content)!,NSAttributedString.Key.font: UIFont.et.fontSize()]))
        text.append(NSAttributedString.init(string: "全文", attributes: [NSAttributedString.Key.foregroundColor:UIColor.color(.urlColor)!,NSAttributedString.Key.font: UIFont.et.fontSize()]))
        content.truncationToken = text
        return content
    }()
    
    lazy var bottomLine : UIView = {
        let backview = UIView()
        backview.backgroundColor = UIColor.color(.tableBack)
        return backview
    }()
    
    lazy var completeImg : UIImageView = {
        let imageView = UIImageView.init(image: UIImage(named: "icon_complete"))
        return imageView
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.setupContraints()
    }
    
    func setupContraints() {
        self.contentView.addSubview(headImg)
        self.contentView.addSubview(nickName)
        self.contentView.addSubview(content)
        self.contentView.addSubview(bottomLine)
        self.contentView.addSubview(completeImg)
        
        headImg.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(15)
            make.size.equalTo(CGSize(width: 22, height: 22))
        }
        
        nickName.snp.makeConstraints { (make) in
            make.left.equalTo(headImg.snp.right).offset(10)
            make.centerY.equalTo(headImg)
            make.right.equalToSuperview().offset(-15)
        }
        
        content.snp.makeConstraints { (make) in
            make.left.equalTo(headImg.snp.left)
            make.right.equalTo(nickName.snp.right)
            make.top.equalTo(headImg.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        bottomLine.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        completeImg.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.right.top.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}

extension MyCollectionCell {
    func bind(reactor: HomePageItemReactor) {
        reactor.state.map {
            $0.model?.userInfo?.username
        }.bind(to: nickName.rx.text)
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.userInfo?.avator
        }.subscribe(onNext: { [weak self] avator in
            guard let `self` = self else { return }
            self.headImg.et.sd_setImage(avator)
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.attribute
        }.subscribe(onNext: { [weak self] attribute in
            guard let `self` = self else { return }
            self.content.attributedText = attribute
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.is_complete
        }.map { (complete) -> Bool in
            return complete == 1
        }.subscribe(onNext: { [weak self] complete in
            guard let `self` = self else { return }
            if complete {
                self.completeImg.isHidden = false
            }else{
                self.completeImg.isHidden = true
            }
        }).disposed(by: disposeBag)
    }
}
