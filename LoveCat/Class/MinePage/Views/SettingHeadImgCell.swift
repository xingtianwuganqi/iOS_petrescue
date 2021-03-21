//
//  SettingHeadImgCell.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/11.
//

import UIKit
import RxSwift
class SettingHeadImgCell: UITableViewCell {
    var disposeBag = DisposeBag()
    lazy var headImg : UIImageView = {
        let imageView = UIImageView.init()
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.color(.defIcon)?.cgColor
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var descLab: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.color(.desc)
        label.font = UIFont.et.font(size: 12)
        label.text = "点击修改头像"
        return label
    }()
    
    lazy var cameraBtn: UIImageView = {
        let imageView = UIImageView.init()
        return imageView
    }()
    
    lazy var bottomLine : UIView = {
        let backview = UIView()
        backview.backgroundColor = UIColor.color(.tableBack)
        return backview
    }()
    
    var model: UserEditModel? {
        didSet {
            guard let model = model else {
                return
            }
            if let image = model.avator {
                headImg.image = image
            }else{
            
                headImg.et.sd_setImage(model.textValue)
            }
        }
    }
    
    var headImgClick: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupConstraints()
        
        headImg.rx.tapGesture().when(.recognized).subscribe(onNext: { _ in
            self.headImgClick?()
        }).disposed(by: disposeBag)
    }
    
    func setupConstraints() {
        self.contentView.addSubview(headImg)
//        headImg.addSubview(cameraBtn)
        self.contentView.addSubview(bottomLine)
        self.contentView.addSubview(descLab)

        self.headImg.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 80, height: 80))
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
        }
        
//        self.cameraBtn.snp.makeConstraints { (make) in
//            make.size.equalTo(CGSize(width: 20, height: 70))
//            make.bottom.left.right.equalToSuperview()
//            make.height.equalTo(20)
//        }
        self.descLab.snp.makeConstraints { (make) in
            make.centerX.equalTo(headImg)
            make.top.equalTo(headImg.snp.bottom).offset(10)
        }
        
        bottomLine.snp.makeConstraints { (make) in
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

