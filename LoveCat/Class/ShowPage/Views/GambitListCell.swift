//
//  GambitListCell.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/18.
//

import UIKit
import ReactorKit
class GambitListCell: UITableViewCell {
    
    
    lazy var iconImg : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage(named: "icon_show_gb")
        return imageView
    }()
    
    lazy var descLab: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.color(.content)
        label.font = UIFont.et.fontSize()
        return label
    }()
    
    lazy var bottomLine : UIView = {
        let backview = UIView()
        backview.backgroundColor = UIColor.color(.defIcon)
        return backview
    }()
    
    
    lazy var rightIcon : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage(named: "icon_center_allin")
        imageView.isHidden = true
        return imageView
    }()
    
    lazy var selectIcon: UIButton = {
        let button = UIButton.init(type: .custom)
        button.isUserInteractionEnabled = false
        button.setImage(UIImage(named: "icon_tag_un"), for: .normal)
        button.setImage(UIImage(named: "icon_tag_se"), for: .selected)
        return button
    }()
    
    var model: GambitListModel? {
        didSet {
            self.descLab.text = model?.descript
            if model?.selected ?? false {
                self.selectIcon.isSelected = true
            }else{
                self.selectIcon.isSelected = false
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.setupConstraints()
        
    }
    
    func setupConstraints() {
        self.contentView.addSubview(iconImg)
        self.contentView.addSubview(descLab)
        self.contentView.addSubview(bottomLine)
        self.contentView.addSubview(rightIcon)
        self.contentView.addSubview(selectIcon)
        
        iconImg.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 18, height: 18))
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        
        descLab.snp.makeConstraints { (make) in
            make.left.equalTo(iconImg.snp.right).offset(10)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        
        bottomLine.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        rightIcon.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 7, height: 12))
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(iconImg)
        }
        
        selectIcon.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(iconImg)
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
