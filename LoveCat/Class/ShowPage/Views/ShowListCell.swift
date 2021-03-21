//
//  ShowListCell.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/18.
//

import UIKit
import YYKit
import ReactorKit
import SnapKit

class ShowListCell: UITableViewCell,View {
    
    typealias Reactor = ShowListCellReactor
    var disposeBag: DisposeBag = DisposeBag()
    
    lazy var headImg : UIImageView = {
        let imageView = UIImageView.init()
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var nickName: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.color(.content)
        label.font = UIFont.et.fontSize()
        return label
    }()
    
    lazy var timeLab: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.color(.desc)
        label.font = UIFont.et.fontSize(.regular, .desc)
        return label
    }()
    
    lazy var gambitView : GambitView = {
        let gambit = UINib(nibName: "GambitView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! GambitView
        gambit.layer.cornerRadius = 12
        gambit.layer.masksToBounds = true
        gambit.backgroundColor = UIColor.color(.defIcon)
        return gambit
    }()

    lazy var showImgView : ShowImgCollectionView = {
        let backview = ShowImgCollectionView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_WIDTH))
        backview.backgroundColor = .white
        return backview
    }()
    
    lazy var bottomView : ShowListBottomView = {
        let backview = ShowListBottomView(width: SCREEN_WIDTH - 20)
        backview.backgroundColor = .white
        return backview
    }()
    
    lazy var bottomLine : UIView = {
        let line = UIView.init()
        line.backgroundColor = UIColor.color(.defIcon)
        return line
    }()
    
    lazy var like_num: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.color(.content)
        label.font = UIFont.et.font(size: 13)
        return label
    }()
    
    lazy var instruction : YYLabel = {
        let instruction = YYLabel.init()
        instruction.numberOfLines = 2
        instruction.font = UIFont.et.fontSize()
        instruction.textColor = UIColor.color(.content)
        instruction.preferredMaxLayoutWidth = SCREEN_WIDTH - 30
        return instruction
    }()
    
    lazy var commentLab: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.color(.desc)
        label.font = UIFont.et.fontSize(.regular, .desc)
        label.numberOfLines = 2
        label.text = "添加评论..."
        return label
    }()
    
    lazy var moreBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "icon_more"), for: .normal)
        button.setImage(UIImage(named: "icon_more"), for: .highlighted)
        return button
    }()
    
    var imgs: [String] = []
    
    fileprivate var showImgToNickConstraint: Constraint?
    /// 点击话题或评论调用 1：话题 2：评论 3.更多
    var commentBtnClickBlock: ((ShowPageModel?,Int) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setUI()
        
                
//        showImgView.didScrollCurrent = { [weak self] index in
//            guard let `self` = self else { return }
//            guard let model = self.reactor?.currentState.model else {
//                return
//            }
//            self.reactor?.currentState.turnPageBlock?(model,index)
//        }
        
    }
    
    func setUI() {
        self.contentView.addSubview(headImg)
        self.contentView.addSubview(nickName)
        self.contentView.addSubview(timeLab)
        self.contentView.addSubview(gambitView)
        self.contentView.addSubview(showImgView)
        self.contentView.addSubview(bottomView)
        self.contentView.addSubview(like_num)
        self.contentView.addSubview(instruction)
        self.contentView.addSubview(commentLab)
        self.contentView.addSubview(bottomLine)
        self.contentView.addSubview(moreBtn)
        
        headImg.snp.makeConstraints { (make) in
            make.size.lessThanOrEqualTo(CGSize(width: 40, height: 40))
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(15)
        }
        
        nickName.snp.makeConstraints { (make) in
            make.left.equalTo(headImg.snp.right).offset(10)
            make.top.equalTo(headImg)
            make.right.equalTo(moreBtn.snp.left).offset(-10)
        }
        
        timeLab.snp.makeConstraints { (make) in
            make.left.equalTo(headImg.snp.right).offset(10)
            make.bottom.equalTo(headImg)
        }
        
        gambitView.snp.makeConstraints { (make) in
            make.left.equalTo(headImg.snp.left)
            make.right.lessThanOrEqualToSuperview().offset(-15)
            make.top.equalTo(headImg.snp.bottom).offset(10)
            make.height.equalTo(24)
        }
        
        showImgView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.size.equalTo(CGSize(width: SCREEN_WIDTH, height: SCREEN_WIDTH))
            self.showImgToNickConstraint = make.top.equalTo(headImg.snp.bottom).offset(10).constraint
        }
        
        instruction.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(showImgView.snp.bottom).offset(10)
        }
        
        commentLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(instruction.snp.bottom).offset(10)
        }

        bottomView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(commentLab.snp.bottom)
            make.height.equalTo(40)
//            make.bottom.equalToSuperview().offset(-10)
        }
    
        bottomLine.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(bottomView.snp.bottom)
            make.height.equalTo(10)
            make.bottom.equalToSuperview()
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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func appendOpenAttr(keyStr: String,completion:(() -> Void)?) {
        
        let text = NSMutableAttributedString()
        text.append(NSAttributedString.init(string: "...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.content)!,NSAttributedString.Key.font: UIFont.et.fontSize()]))
        text.append(NSAttributedString.init(string: keyStr, attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.urlColor)!,NSAttributedString.Key.font: UIFont.et.fontSize()]))
        let hi = YYTextHighlight.init()
        hi.tapAction = { (_,_,_,_) in
            // 点击展开
            completion?()
        }
        let range = text.string.range(of: keyStr)
        text.setTextHighlight(hi, range: NSRange(range!, in: text.string))
        text.font = UIFont.et.fontSize()
        
        if keyStr == "展开" {
            let seeMore = YYLabel.init()
            seeMore.attributedText = text
            seeMore.sizeToFit()
            let truncation = NSAttributedString.attachmentString(withContent: seeMore, contentMode: .center, attachmentSize: seeMore.frame.size, alignTo: text.font ?? UIFont.et.fontSize(), alignment: .center)
            self.instruction.truncationToken = truncation
            self.instruction.attributedText = self.reactor?.currentState.model?.instructAttribute
        }else{
            self.instruction.truncationToken = nil
            let instruct = self.reactor?.currentState.model?.instructAttribute?.mutableCopy() as! NSMutableAttributedString
            instruct.append(text)
            self.instruction.attributedText = instruct
        }
    }
}

extension ShowListCell {
    func bind(reactor: ShowListCellReactor) {
        
        bottomView.commentBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.commentBtnClickBlock?(self.reactor?.currentState.model,1)
        }).disposed(by: disposeBag)
        
        commentLab.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.commentBtnClickBlock?(self.reactor?.currentState.model,1)
        }).disposed(by: disposeBag)
        
        gambitView.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.commentBtnClickBlock?(self.reactor?.currentState.model,2)
        }).disposed(by: disposeBag)
        
        moreBtn.rx.tap.subscribe(onNext: { _ in
            self.commentBtnClickBlock?(self.reactor?.currentState.model,3)
        }).disposed(by: disposeBag)
        
        bottomView.likeBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            UserManager.shared.lazyAuthToDoThings {
                guard let model = self.reactor?.currentState.model else {
                    return
                }
                self.reactor?.currentState.likeOrCollectionBlock?(model,1)
            }
        }).disposed(by: disposeBag)
        
        bottomView.collectionBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            UserManager.shared.lazyAuthToDoThings {
                guard let model = self.reactor?.currentState.model else {
                    return
                }
                self.reactor?.currentState.likeOrCollectionBlock?(model,2)
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.user?.avator
        }.subscribe(onNext: { [weak self] avator in
            guard let `self` = self else { return }
            self.headImg.et.sd_setImage(avator)
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.user?.username
        }.bind(to: self.nickName.rx.text)
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.create_time
        }.bind(to: self.timeLab.rx.text)
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.gambit_type?.descript
        }.subscribe(onNext: { [weak self] descript in
            guard let `self` = self else { return }
            if let desc = descript,desc.count > 0 {
                self.gambitView.isHidden = false
                self.gambitView.descLab.text = desc
                self.showImgToNickConstraint?.update(offset: 44)
            }else{
                self.gambitView.isHidden = true
                self.gambitView.descLab.text = ""
                self.showImgToNickConstraint?.update(offset: 10)
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.open
        }.subscribe(onNext: { [weak self] open in
            guard let `self` = self else { return }
            guard let open = open else {
                return
            }
            if open {
                self.instruction.numberOfLines = 0
                self.appendOpenAttr(keyStr: "收起", completion: {
                    self.reactor?.currentState.openBlock?(self.reactor?.currentState.model)
                })
                
            }else{
                self.instruction.numberOfLines = 2
                self.appendOpenAttr(keyStr: "展开", completion: {
                    self.reactor?.currentState.openBlock?(self.reactor?.currentState.model)
                })
            }
            
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.imgs
        }.subscribe(onNext: { [weak self] images in
            guard let `self` = self else { return }
            guard let imgs = images else {
                return
            }
            self.showImgView.imgs = imgs
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.collectioned
        }.map({ (collect) -> Bool in
            collect == 1
        }).bind(to: bottomView.collectionBtn.rx.isSelected)
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.liked
        }.map({ (like) -> Bool in
            like == 1
        }).bind(to: bottomView.likeBtn.rx.isSelected)
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.likes_num
        }.subscribe(onNext: { [weak self] likes_num in
            guard let `self` = self else { return }
            if let num = likes_num,num > 0 {
                self.bottomView.likeBtn.setTitle("\(num.wFormatted)", for: .normal)
            }else{
                self.bottomView.likeBtn.setTitle("点赞", for: .normal)
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.collection_num
        }.subscribe(onNext: { [weak self] collection_num in
            guard let `self` = self else { return }
            if let num = collection_num,num > 0 {
                self.bottomView.collectionBtn.setTitle("\(num.wFormatted)", for: .normal)
            }else{
                self.bottomView.collectionBtn.setTitle("收藏", for: .normal)
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.commNum
        }.subscribe(onNext: { [weak self] comment_num in
            guard let `self` = self else { return }
            if let num = comment_num,num > 0 {
                self.bottomView.commentBtn.setTitle("\(num.wFormatted)", for: .normal)
            }else{
                self.bottomView.commentBtn.setTitle("评论", for: .normal)
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.commentAttr
        }.subscribe(onNext: { [weak self] commAttr in
            guard let `self` = self else { return }
            self.commentLab.attributedText = commAttr
        }).disposed(by: disposeBag)
    }
}
