//
//  ShowListCommentView.swift
//  rebate
//
//  Created by jingjun on 2021/1/25.
//  Copyright © 2021 寻宝天行. All rights reserved.
//

import UIKit
import ReactorKit
class ShowListCommentView: UITableViewCell,View {
    var disposeBag: DisposeBag = DisposeBag()
    typealias Reactor = CommentListCellReactor
    
    lazy var headImg : UIImageView = {
        let imageView = UIImageView.init()
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var nickName: UILabel = {
        let label = UILabel.init()
        label.textColor = rgb(136,136,136)
        label.font = UIFont.et.font(size: 13)
        return label
    }()
    
    lazy var contentLab: UILabel = {
        let label = UILabel.init()
        label.textColor = rgb(52,52,52)
        label.font = UIFont.et.fontSize()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var timeLab: UILabel = {
        let label = UILabel.init()
        label.textColor = rgb(153,153,153)
        label.font = UIFont.et.font(size: 12)
        return label
    }()
    
    lazy var moreBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "icon_more"), for: .normal)
        button.setImage(UIImage(named: "icon_more"), for: .highlighted)
        return button
    }()
    
//    lazy var likeBtn: UIButton = {
//        let button = UIButton.init(type: .custom)
//        button.setImage(UIImage(named: "undianzan"), for: .normal)
//        button.setImage(UIImage(named: "dianzan"), for: .selected)
//        button.setTitle(" 0", for: .normal)
//        button.setTitleColor(rgb(102,102,102), for: .normal)
//        button.titleLabel?.font = UIFont.et.font(size: 12)
//        return button
//    }()
//
//    lazy var chatBtn: UIButton = {
//        let button = UIButton.init(type: .custom)
//        button.setTitle(" 聊一聊", for: .normal)
//        button.setTitleColor(rgb(102,102,102), for: .normal)
//        button.titleLabel?.font = UIFont.et.font(size: 12)
//        button.setImage(UIImage(named: "icon_mood_msg"), for: .normal)
//        return button
//    }()
    
    var moreBtnClickBlock: ((CommentListModel?) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.setupUI()
        self.moreBtn.addTarget(self, action: #selector(moreBtnCLick), for: .touchUpInside)
    }

    @objc func moreBtnCLick() {
        self.moreBtnClickBlock?(self.reactor?.currentState.model)
    }
    
//    override init(reuseIdentifier: String?) {
//        super.init(reuseIdentifier: reuseIdentifier)
//        setupUI()
//        self.contentView.isUserInteractionEnabled = true
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
//        tap.numberOfTouchesRequired = 1
//        tap.numberOfTapsRequired = 1
//        self.contentView.addGestureRecognizer(tap)
//        likeBtn.addTarget(self, action: #selector(likeBtnClick), for: .touchUpInside)
//    }

    @objc func tapAction() {
//        guard let model = self.headModel?.headModel else {
//            return
//        }
//        self.headModel?.didSelect?(model,1)
    }

    @objc func likeBtnClick() {
//        guard let model = self.headModel?.headModel else {
//            return
//        }
//        self.headModel?.didSelect?(model,2)
    }
    
    func setupUI(){
        self.contentView.addSubview(headImg)
        self.contentView.addSubview(nickName)
        self.contentView.addSubview(contentLab)
        self.contentView.addSubview(timeLab)
        self.contentView.addSubview(moreBtn)
//        self.contentView.addSubview(likeBtn)
//        self.contentView.addSubview(chatBtn)
        
        headImg.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(15)
        }
        
        nickName.snp.makeConstraints { (make) in
            make.left.equalTo(headImg.snp.right).offset(10)
            make.right.equalToSuperview().offset(-50)
            make.top.equalTo(headImg.snp.top)
        }
        
        contentLab.snp.makeConstraints { (make) in
            make.left.equalTo(nickName)
            make.top.equalTo(nickName.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-15)
        }
        
        timeLab.snp.makeConstraints { (make) in
            make.left.equalTo(nickName)
            make.top.equalTo(contentLab.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        moreBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-7)
            make.size.equalTo(CGSize(width: 40, height: 30))
            make.centerY.equalTo(nickName)
        }
        
//        likeBtn.snp.makeConstraints { (make) in
//            make.right.equalToSuperview().offset(-15)
//            make.centerY.equalTo(timeLab)
//        }
//        
//        chatBtn.snp.makeConstraints { (make) in
//            make.right.equalTo(likeBtn.snp.left).offset(-15)
//            make.centerY.equalTo(likeBtn)
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
extension ShowListCommentView {
    func bind(reactor: CommentListCellReactor) {
        reactor.state.map {
            $0.model?.content
        }.bind(to: contentLab.rx.text)
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.userInfo?.avator
        }.subscribe(onNext: { [weak self] avator in
            guard let `self` = self else { return }
            self.headImg.et.sd_setImage(avator)
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.userInfo?.username
        }.bind(to: nickName.rx.text)
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.create_time
        }.bind(to: timeLab.rx.text)
        .disposed(by: disposeBag)
    }
}
