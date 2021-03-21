//
//  ReleaseImgCell.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/22.
//

import UIKit
import RxSwift
import RxCocoa
class ReleaseImgCell: UICollectionViewCell {
    
    fileprivate var disposeBag = DisposeBag()
    
    lazy var imgView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var pgressView: UIView = {
        let backView = UIView.init()
        backView.isHidden = true
        backView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return backView
    }()
    
    lazy var pgLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = .white
        label.font = UIFont.et.fontSize(.regular, .desc)
        label.textAlignment = .center
        return label
    }()
    
    lazy var deleteBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "icon_share_close"), for: .normal)
        return btn
    }()

    var deleteItmeBlock: ((ReleasePhotoModel) -> Void)?
    var model: ReleasePhotoModel? {
        didSet {
            guard let model = model else {
                return
            }
            self.imgView.image = model.image
            if model.complete == false && model.progress > 0 && model.progress < 1 {
                self.pgressView.isHidden = false
                self.pgLabel.text = "\(model.progress.intValue())%"
            }else{
                self.pgressView.isHidden = true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUI()
        deleteBtn.rx.tap.subscribe(onNext: { [weak self](_) in
            guard let `self` = self else { return }
            guard let item = self.model else {
                return
            }
            self.deleteItmeBlock?(item)
        }).disposed(by: disposeBag)
        
    }
    
    func setUI() {
        self.contentView.addSubview(imgView)
        self.contentView.addSubview(pgressView)
        self.pgressView.addSubview(pgLabel)
        self.contentView.addSubview(deleteBtn)
        imgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        pgressView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        pgLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        deleteBtn.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AddPhotoCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "icon_hw_navi_add")
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "上传图片"
        label.textColor = rgb(102,102,102)
        label.font = UIFont.et.fontSize(.regular,.desc)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        self.contentView.addSubview(self.imageView)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        self.imageView.bottomAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: -5.0).isActive = true
        self.imageView.widthAnchor.constraint(equalToConstant: 17.0).isActive = true
        self.imageView.heightAnchor.constraint(equalToConstant: 17.0).isActive = true
        
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        self.titleLabel.topAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 5.0).isActive = true
        
        self.contentView.backgroundColor =  UIColor.color(.defIcon)
        self.contentView.layer.cornerRadius = 5.0
        self.contentView.layer.masksToBounds = true
    }
}
