//
//  CitySelectCell.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/24.
//

import UIKit

class CitySelectCell: UITableViewCell {
    
    lazy var titleLab: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.color(.content)
        label.font = UIFont.et.fontSize(.regular, .content)
        return label
    }()
    
    lazy var bottomLine : UIView = {
        let backview = UIView()
        backview.backgroundColor = UIColor.color(.tableBack)
        return backview
    }()
    
    
    var proReactor: ProvinceReactor? {
        didSet {
            guard let model = proReactor?.currentState.provinceModel else {
                return
            }
            self.titleLab.text = model.value
            if model.isSelect {
                self.accessoryType = .checkmark
            }else{
                self.accessoryType = .none
            }
        }
    }
    
    var cityReactor: CityCellReactor? {
        didSet {
            guard let model = cityReactor?.currentState.cityModel else {
                return
            }
            self.titleLab.text = model.value
            if model.isSelect {
                self.accessoryType = .checkmark
            }else{
                self.accessoryType = .none
            }
        }
    }
    
    var areaReactor: AreaReactor? {
        didSet {
            guard let model = areaReactor?.currentState.areaModel else {
                return
            }
            self.titleLab.text = model.value
            if model.isSelect {
                self.accessoryType = .checkmark
            }else{
                self.accessoryType = .none
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        self.contentView.addSubview(bottomLine)
        self.bottomLine.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
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
