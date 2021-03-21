//
//  CollectionImgCell.swift
//  LoveCat
//
//  Created by jingjun on 2020/10/19.
//

import UIKit

class CollectionImgCell: UICollectionViewCell {
    
    var imgUrl: String? {
        didSet {
            guard let url = imgUrl else {
                return
            }
            self.imgView.et.sd_setImage(url,showType: .thumbnail)
        }
    }
    
    lazy var imgView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var countView : CountView = {
        let backview = CountView()
        backview.isHidden = true
        return backview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(imgView)
        self.contentView.addSubview(countView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        countView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CountView: UIView  {
    lazy var countLab: UILabel = {
        let label = UILabel.init()
        label.textColor = .white
        label.font = UIFont.et.font(.bold, size: 20)
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        self.addSubview(countLab)
        countLab.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
