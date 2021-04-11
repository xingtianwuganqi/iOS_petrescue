//
//  HomePageTableCell.swift
//  LoveCat
//
//  Created by jingjun on 2020/10/19.
//

import UIKit
import SnapKit
import YYKit
import ReactorKit
import ShowBigImg
class HomePageTableCell: UITableViewCell,View {
    
    static let contentWidth = SCREEN_WIDTH - 80
    
    var disposeBag: DisposeBag = DisposeBag()
    
    typealias Reactor = HomePageItemReactor
    
    lazy var headImg : UIImageView = {
        let imageView = UIImageView.init()
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var userName: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.color(.title)
        label.font = UIFont.et.fontSize(.medium, .content)
        label.text = ""
        return label
    }()
    
    lazy var moreBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "icon_more"), for: .normal)
        button.setImage(UIImage(named: "icon_more"), for: .highlighted)
        return button
    }()
    
    lazy var textView: YYLabel = {
        let textView = YYLabel.init()
        textView.numberOfLines = 0
        textView.font = UIFont(name: "TimesNewRomanPSMT", size: 14)
        textView.textColor = UIColor.color(.content)
        textView.preferredMaxLayoutWidth = HomePageTableCell.contentWidth
        textView.numberOfLines = 7
        let text = NSMutableAttributedString()
        text.append(NSAttributedString.init(string: "...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.content)!,NSAttributedString.Key.font: UIFont.et.fontSize()]))
        text.append(NSAttributedString.init(string: "全文", attributes: [NSAttributedString.Key.foregroundColor:UIColor.color(.urlColor)!,NSAttributedString.Key.font: UIFont.et.fontSize()]))
        textView.truncationToken = text
        return textView
    }()
    
    lazy var imgCollection: HomeCollectionImgView = {
        let imgView = HomeCollectionImgView.init()
        return imgView
    }()
    
    lazy var addressView : HomeAddressView = {
        let backview = HomeAddressView()
        backview.backgroundColor = .white
        return backview
    }()
    
    lazy var bottomLine: UIView = {
        let bottomLine = UIView.init()
        bottomLine.backgroundColor = UIColor.color(.defIcon)
        return bottomLine
    }()
    
//    lazy var bottomView: ShowListBottomView = {
//        let btmView = TopicBottomView.init(width: HomePageTableCell.contentWidth)
//        return btmView
//    }()
    
    lazy var bottomView : ShowListBottomView = {
        let backview = ShowListBottomView(width: HomePageTableCell.contentWidth)
        backview.backgroundColor = .white
        return backview
    }()
    
    
    lazy var completeImg : UIImageView = {
        let imageView = UIImageView.init(image: UIImage(named: "icon_complete"))
        return imageView
    }()
    
    var imgHeightConstraint: Constraint?
    
    var moreBtnClick: ((Int,HomePageModel) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.setUI()
        
        imgCollection.didSelectItem = { index in
            guard let images = self.reactor?.currentState.model?.imgs?.compactMap({ (imgUrl) -> String? in
                return IMGURL + imgUrl
            })else {
                return
            }
            if index < images.count {
                let img = images[index]
                let vc = ShowBigImgController.init(urls: images, url: img)
                vc.modalPresentationStyle = .overFullScreen
                AppHelper.currentTabBarController()?.present(vc, animated: false, completion: nil)
            }
        }
    }
    
    func setUI() {
        self.contentView.addSubview(self.headImg)
        self.contentView.addSubview(self.userName)
        self.contentView.addSubview(textView)
        self.contentView.addSubview(imgCollection)
        self.contentView.addSubview(addressView)
        self.contentView.addSubview(bottomLine)
        self.contentView.addSubview(bottomView)
        self.contentView.addSubview(completeImg)
        self.contentView.addSubview(moreBtn)
        
        self.headImg.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(15)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        self.userName.setContentHuggingPriority(.required, for: .vertical)
        self.userName.setContentCompressionResistancePriority(.required, for: .vertical)
        self.userName.snp.makeConstraints { (make) in
            make.left.equalTo(headImg.snp.right).offset(10)
            make.right.equalTo(moreBtn.snp.left).offset(-10)
            make.top.equalTo(headImg)
        }
        
        self.textView.setContentHuggingPriority(.required, for: .vertical)
        self.textView.setContentCompressionResistancePriority(.required, for: .vertical)
        textView.snp.makeConstraints { (make) in
            make.left.equalTo(userName.snp.left)
            make.top.equalTo(userName.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-15)
        }
        
        imgCollection.snp.makeConstraints { (make) in
            make.left.equalTo(userName.snp.left)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(textView.snp.bottom).offset(10)
            self.imgHeightConstraint = make.height.equalTo(HomePageTableCell.contentWidth * 0.5).constraint
        }
        
        addressView.snp.makeConstraints { (make) in
            make.left.equalTo(imgCollection.snp.left)
            make.right.equalTo(imgCollection.snp.right)
            make.top.equalTo(imgCollection.snp.bottom).offset(5)
            make.height.equalTo(30)
        }
                
        bottomView.snp.makeConstraints { (make) in
            make.top.equalTo(addressView.snp.bottom)
            make.left.equalTo(addressView.snp.left)
            make.right.equalTo(addressView.snp.right)
            make.height.equalTo(30)
        }
        
        bottomLine.snp.makeConstraints { (make) in
            make.top.equalTo(bottomView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
        
        completeImg.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.right.top.equalToSuperview()
        }
        
        moreBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.size.equalTo(CGSize(width: 40, height: 30))
            make.centerY.equalTo(userName)
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
extension HomePageTableCell {
    func bind(reactor: HomePageItemReactor) {
    
        reactor.state.map {
            if let name = $0.model?.userInfo?.username,name.count > 0 {
                return name
            }else{
                return "佚名"
            }
        }.bind(to: self.userName.rx.text)
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.imgs
        }.subscribe(onNext: { [weak self] images in
            guard let `self` = self else { return }
            self.imgCollection.images = images ?? []
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.attribute
        }.subscribe(onNext: { [weak self] content in
            guard let `self` = self else { return }
            self.textView.attributedText = content
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.address_info
        }.map { (address) -> String in
            if let time = reactor.currentState.model?.create_time,time.count > 0 {
                return time + " · " + (address ?? "")
            }else{
                return address ?? ""
            }
        }.bind(to: self.addressView.addressBtn.rx.title())
        .disposed(by: disposeBag)
        
        reactor.state.map { (state) -> Bool in
            state.model?.liked == 1
        }.bind(to: self.bottomView.likeBtn.rx.isSelected)
        .disposed(by: disposeBag)
        
        reactor.state.map { (state) -> Bool in
            state.model?.collectioned == 1
        }.bind(to: self.bottomView.collectionBtn.rx.isSelected)
        .disposed(by: disposeBag)

        reactor.state.map {
            $0.model?.userInfo?.avator
        }.subscribe(onNext: { [weak self] avator in
            guard let `self` = self else { return }
            self.headImg.et.sd_setImage(avator,showType: .thumbnail)
        }).disposed(by: disposeBag)
        
        reactor.state.map{
            $0.model?.commNum
        }.map({ (number) -> String in
            if let num = number,num > 0 {
                return "\(num.wFormatted)"
            }else{
                return "评论"
            }
        }).bind(to: self.bottomView.commentBtn.rx.title())
        .disposed(by: disposeBag)
        
        
        reactor.state.map{
            $0.model?.likes_num
        }.map({ (number) -> String in
            if let num = number,num > 0 {
                return "\(num.wFormatted)"
            }else{
                return "点赞"
            }
        }).bind(to: self.bottomView.likeBtn.rx.title())
        .disposed(by: disposeBag)
        
        reactor.state.map{
            $0.model?.collection_num
        }.map({ (number) -> String in
            if let num = number,num > 0 {
                return "\(num.wFormatted)"
            }else{
                return "收藏"
            }
        }).bind(to: self.bottomView.collectionBtn.rx.title())
        .disposed(by: disposeBag)
        
        bottomView.likeBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            UserManager.shared.lazyAuthToDoThings {
                guard let model = self.reactor?.currentState.model else {
                    return
                }
                self.reactor?.currentState.clickBtnBlock?(1,model)
            }
        }).disposed(by: disposeBag)
        
        bottomView.collectionBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            UserManager.shared.lazyAuthToDoThings {
                guard let model = self.reactor?.currentState.model else {
                    return
                }
                self.reactor?.currentState.clickBtnBlock?(2,model)
            }
        }).disposed(by: disposeBag)
        
        bottomView.commentBtn.rx.tap.subscribe(onNext: {
            [weak self] _ in
                guard let `self` = self else { return }
                UserManager.shared.lazyAuthToDoThings {
                    guard let model = self.reactor?.currentState.model else {
                        return
                    }
                    self.moreBtnClick?(2,model)
                }
        }).disposed(by: disposeBag)
        
        moreBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            guard let model = self.reactor?.currentState.model else {
                return
            }
            self.moreBtnClick?(1,model)
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.is_complete
        }.map { (complete) -> Bool in
            return complete == 1
        }.subscribe(onNext: { [weak self] complete in
            guard let `self` = self else { return }
            if complete {
                self.completeImg.isHidden = false
//                self.moreBtn.snp.updateConstraints { (make) in
//                    make.right.equalToSuperview().offset(-10)
//                }
            }else{
                self.completeImg.isHidden = true
//                self.moreBtn.snp.updateConstraints { (make) in
//                    make.right.equalToSuperview().offset(-7)
//                }
            }
        }).disposed(by: disposeBag)
    }
}
