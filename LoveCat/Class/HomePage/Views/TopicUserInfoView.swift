//
//  TopicUserInfoView.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/28.
//

import UIKit
import YYKit
import ReactorKit

class TopicUserInfoView: UIView,View {
    
    var disposeBag: DisposeBag = DisposeBag()

    typealias Reactor = TopicInfoCellReactor
    
    lazy var userImg : UIImageView = {
        let imageView = UIImageView.init()
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var userName: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.color(.content)
        label.font = UIFont.et.fontSize(.medium,.content)
        return label
    }()
    
    lazy var addressView : HomeAddressView = {
        let backview = HomeAddressView()
        backview.backgroundColor = .white
        return backview
    }()
    
    lazy var completeImg : UIImageView = {
        let imageView = UIImageView.init(image: UIImage(named: "icon_complete"))
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUI()
    }
    
    func setUI() {
        self.addSubview(userImg)
        self.addSubview(userName)
        self.addSubview(addressView)
        self.addSubview(completeImg)
        
        self.userImg.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().offset(-15)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        self.userName.snp.makeConstraints { (make) in
            make.left.equalTo(userImg.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(userImg.snp.top)
        }
        
        self.addressView.snp.makeConstraints { (make) in
            make.left.equalTo(userImg.snp.right).offset(10)
            make.top.equalTo(userName.snp.bottom).offset(5)
            make.height.equalTo(20)
        }
        
        self.completeImg.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func bind(reactor: TopicInfoCellReactor) {
        reactor.state.map {
            $0.detail.userInfo?.username ?? ""
        }.bind(to: self.userName.rx.text)
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.detail.userInfo?.avator
        }.subscribe(onNext: { [weak self] avator in
            guard let `self` = self else { return }
            self.userImg.et.sd_setImage(avator)
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.detail.address_info
        }.map { (address) -> String in
            if let time = reactor.currentState.detail.create_time,time.count > 0 {
                return time + " · " + (address ?? "")
            }else{
                return address ?? ""
            }
        }.bind(to: self.addressView.addressBtn.rx.title())
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.detail.is_complete
        }.map { (com) -> Bool in
            return com == 0
        }.bind(to: completeImg.rx.isHidden)
        .disposed(by: disposeBag)
    }
    
}


final class TopicContentView: UIView, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    typealias Reactor = TopicContentCellReactor
    
    lazy var contentLab: YYLabel = {
        let label = YYLabel.init()
        label.numberOfLines = 0
        label.textColor = UIColor.color(.content)
        label.font = UIFont.et.fontSize()
        label.preferredMaxLayoutWidth = SCREEN_WIDTH - 30
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    func setUI() {
        self.addSubview(contentLab)
        contentLab.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: Reactor) {
        reactor.state.map {
            $0.topicDetial.attribute
        }.subscribe(onNext: { [weak self] attribute in
            guard let `self` = self else { return }
            self.contentLab.attributedText = attribute
        }).disposed(by: disposeBag)
    }
}
