//
//  MessageCommonListCell.swift
//  LoveCat
//
//  Created by jingjun on 2021/3/29.
//

import UIKit
import YYKit
import ReactorKit
class MessageCommonListCell: UITableViewCell {
    
    typealias Reactor = MessageCommonCellReactor
    var disposeBag: DisposeBag = DisposeBag()
    
    lazy var userInfo : MessageHeadView = {
        let backview = MessageHeadView()
        backview.backgroundColor = .white
        return backview
    }()
    
    lazy var descLab: YYLabel = {
        let textView = YYLabel.init()
        textView.numberOfLines = 0
        textView.font = UIFont.et.fontSize()
        textView.textColor = UIColor.color(.content)
        textView.preferredMaxLayoutWidth = HomePageTableCell.contentWidth
        return textView
    }()
    
    lazy var topicInfo : MessageTopicView = {
        let backview = MessageTopicView()
        return backview
    }()
    
    lazy var bottomLine : UIView = {
        let backview = UIView()
        backview.backgroundColor = UIColor.color(.defIcon)
        return backview
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.layoutViews()
    }
    
    func layoutViews() {
        self.contentView.addSubview(userInfo)
        self.contentView.addSubview(descLab)
        self.contentView.addSubview(topicInfo)
        self.contentView.addSubview(bottomLine)
        self.userInfo.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(65)
        }
        self.descLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(userInfo.snp.bottom)
        }
        
        self.topicInfo.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(descLab.snp.bottom).offset(10)
            make.bottom.equalTo(bottomLine.snp.top).offset(-10)
        }
        
        self.bottomLine.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview()
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
extension MessageCommonListCell: View {
    func bind(reactor: MessageCommonCellReactor) {
        reactor.state.map {
            $0.model?.from_info
        }.subscribe(onNext: { [weak self] info in
            guard let `self` = self else { return }
            self.userInfo.headImg.et.sd_setImage(info?.avator, showType: .thumbnail, completed: nil)
            self.userInfo.username.text = info?.username
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.msg_type
        }.subscribe(onNext: { [weak self] msg_type in
            guard let `self` = self else { return }
            if msg_type == 1 || msg_type == 5 {
                self.descLab.text = "赞了这条帖子"
            }else if msg_type == 2 || msg_type == 6 {
                self.descLab.text = "收藏了这条帖子"
            }else if msg_type == 3 || msg_type == 4 || msg_type == 7 || msg_type == 8 {
                guard let model = reactor.currentState.model else {
                    return
                }
                if model.reply_type == 1 {
                    self.descLab.attributedText = Tool.shared.getContentAttribute(text: "评论说：" + (model.commentInfo?.content ?? ""), fontSize: 14, textColor: UIColor.color(.content)!)
                    
                }else{
                    self.descLab.text = "回复说：" + (model.replyInfo?.content ?? "")
                }
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.topicInfo
        }.subscribe(onNext: { info in
            guard let topic = info else {
                return
            }
            self.topicInfo.imgView.et.sd_setImage(topic.imgs?.first,showType: .thumbnail,placeholder: "icon_white")
            self.topicInfo.descLab.attributedText = topic.getContentAttribute(fontSize: 12, textColor: UIColor.color(.desc)!)
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.showInfo
        }.subscribe(onNext: { info in
            guard let show = info else {
                return
            }
            self.topicInfo.imgView.et.sd_setImage(show.imgs?.first,showType: .thumbnail,placeholder: "icon_white")
            self.topicInfo.descLab.attributedText = show.getContentAttribute(fontSize: 12, textColor: UIColor.color(.desc)!)
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.create_time
        }.subscribe(onNext: { [weak self] timeStr in
            guard let `self` = self else { return }
            let time = Tool.shared.timeTDate(time: timeStr ?? "")
            self.userInfo.timeLab.text = time
        }).disposed(by: disposeBag)
    }
}
