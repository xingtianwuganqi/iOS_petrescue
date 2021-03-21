//
//  ShowListReplyCell.swift
//  rebate
//
//  Created by jingjun on 2021/1/25.
//  Copyright © 2021 寻宝天行. All rights reserved.
//

import UIKit
import ReactorKit
class ShowListReplyCell: UITableViewCell {
    var disposeBag: DisposeBag = DisposeBag()
    typealias Reactor = ReplyListCellReactor
    
    lazy var headImg : UIImageView = {
        let imageView = UIImageView.init()
        imageView.layer.cornerRadius = 10
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
    
//    lazy var voiceBtn: UIButton = {
//        let button = UIButton.init(type: .custom)
//        button.setTitle(" 语音", for: .normal)
//        button.setTitleColor(rgb(102,102,102), for: .normal)
//        button.titleLabel?.font = UIFont.rt.font(size: scaleXSize(12))
//        button.setImage(UIImage(named: "icon_mood_msg"), for: .normal)
//        return button
//    }()
//
//    lazy var imageContent: UIImageView = {
//        let imageView = UIImageView.init()
//        imageView.layer.cornerRadius = 15
//        imageView.layer.masksToBounds = true
//        return imageView
//    }()
    
//    var cellModel: RTMoodReplyCellModel? {
//        didSet {
//            guard let model = cellModel?.model else {
//                return
//            }
//            self.headImg.sd_setImage(with: URL(string: model.userInfoVO?.avatar ?? ""), placeholderImage: GlobalConstants.DefaultIcon346, options: .allowInvalidSSLCertificates, context: nil)
//            self.nickName.text = model.userInfoVO?.nickName
//            self.timeLab.text = model.createTime
//
//            if let audio = model.audioList?.first,audio.count > 0 {
//                self.contentLab.isHidden = true
//                self.voiceBtn.isHidden = false
//                self.imageContent.isHidden = true
//            }else if let img = model.imgList?.first,img.count > 0 {
//                self.contentLab.isHidden = true
//                self.voiceBtn.isHidden = true
//                self.imageContent.isHidden = false
//                self.imageContent.sd_setImage(with: URL(string: model.imgList?.first ?? ""),placeholderImage: GlobalConstants.DefaultIcon346, completed: nil)
//            }else if let content = model.content {
//                self.contentLab.isHidden = false
//                self.voiceBtn.isHidden = true
//                self.imageContent.isHidden = true
//                self.contentLab.text = model.content
//            }else{
//                self.contentLab.isHidden = true
//                self.voiceBtn.isHidden = true
//                self.imageContent.isHidden = true
//            }
//        }
//    }
    var moreBtnClickBlock: ((ReplyListModel?) -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .white
        self.setupUI()
        self.selectionStyle = .none
        self.moreBtn.addTarget(self, action: #selector(moreBtnClick), for: .touchUpInside)
    }
    
    @objc func moreBtnClick() {
        self.moreBtnClickBlock?(self.reactor?.currentState.model)
    }
    
    func setupUI(){
        self.contentView.addSubview(headImg)
        self.contentView.addSubview(nickName)
        self.contentView.addSubview(contentLab)
        self.contentView.addSubview(timeLab)
        self.contentView.addSubview(moreBtn)
        
        headImg.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 20, height: 20))
            make.left.equalToSuperview().offset(55)
            make.top.equalToSuperview().offset(15)
        }
        
        nickName.snp.makeConstraints { (make) in
            make.left.equalTo(headImg.snp.right).offset(10)
            make.top.equalTo(headImg.snp.top)
        }
        
        contentLab.snp.makeConstraints { (make) in
            make.left.equalTo(nickName)
            make.top.equalTo(nickName.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        timeLab.setContentHuggingPriority(.required, for: .horizontal)
        timeLab.setContentCompressionResistancePriority(.required, for: .horizontal)
        timeLab.snp.makeConstraints { (make) in
            make.left.equalTo(nickName.snp.right).offset(15)
            make.right.lessThanOrEqualToSuperview().offset(-50)
            make.centerY.equalTo(nickName)
        }
        
        moreBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-7)
            make.size.equalTo(CGSize(width: 40, height: 30))
            make.centerY.equalTo(nickName)
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

        // Configure the view for the selected state
    }
}
extension ShowListReplyCell: View {
    func bind(reactor: ReplyListCellReactor) {
        reactor.state.map {
            $0.model?.content
        }.bind(to: contentLab.rx.text)
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.fromInfo?.avator
        }.subscribe(onNext: { [weak self] avator in
            guard let `self` = self else { return }
            self.headImg.et.sd_setImage(avator)
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.fromInfo?.username
        }.map({ (userName) -> String in
            return "\(userName ?? "") 回复 \(reactor.currentState.model?.toInfo?.username ?? "")"
        })
        .bind(to: nickName.rx.text)
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.create_time
        }.bind(to: timeLab.rx.text)
        .disposed(by: disposeBag)
    }
}

class ShowListReplyOpenCell: UITableViewCell {
    lazy var openBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("查看更多回复 >", for: .normal)
        button.setTitleColor(rgb(47,116,255), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        return button
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(openBtn)
        self.selectionStyle = .none
        openBtn.isUserInteractionEnabled = false
        openBtn.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(22)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
