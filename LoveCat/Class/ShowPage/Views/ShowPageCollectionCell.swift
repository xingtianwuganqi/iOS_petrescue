//
//  CollectionViewCell.swift
//  swiftText
//
//  Created by jingjun on 2020/11/9.
//  Copyright © 2020 景军. All rights reserved.
//

import UIKit

class ShowPageCollectionCell: UICollectionViewCell {
    
    lazy var imgView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    lazy var loading : UILabel = {
        let label = UILabel()
        label.text = "图片加载中"
        label.textColor = UIColor.white
        label.font = UIFont.et.fontSize()
        label.isHidden = false
        return label
    }()
    
    var backRemoveCallBack: (() -> Void)?
    var tapMoveCallBack:((_ view: UIImageView) -> Void)?
    var changeAlphaCallBack: ((_ value: CGFloat) -> Void)?
    
    var text: String? {
        didSet {
            
            self.imgView.et.sd_setImage(text) { (image, error, type, url) in
                if image != nil {
                    self.loading.isHidden = true
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        self.contentView.addSubview(imgView)
        self.contentView.addSubview(loading)
        imgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        loading.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

