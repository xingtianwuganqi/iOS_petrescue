//
//  ViolationCollectionViewCell.swift
//  LoveCat
//
//  Created by jingjun on 2021/3/15.
//

import UIKit
import RxSwift
import ReactorKit

class ViolationCollectionViewCell: UICollectionViewCell {
    var disposeBag = DisposeBag()
    typealias Reactor = ViolationCellReactor
    
    lazy var selectIcon: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "icon_tag_un"), for: .normal)
        button.setImage(UIImage(named: "icon_tag_se"), for: .selected)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    lazy var desc: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.color(.content)
        label.font = UIFont.et.font(size: 15)
        return label
    }()
    
    lazy var bottomLine: UIView = {
        let backview = UIView()
        backview.backgroundColor = UIColor.color(.defIcon)
        return backview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(selectIcon)
        self.contentView.addSubview(desc)
        self.contentView.addSubview(bottomLine)
        self.setupConstraints()
    }
    
    func setupConstraints() {
        self.selectIcon.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        self.desc.snp.makeConstraints { (make) in
            make.left.equalTo(self.selectIcon.snp.right).offset(10)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        }
        self.bottomLine.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
extension ViolationCollectionViewCell: View {
    func bind(reactor: ViolationCellReactor) {
        reactor.state.map {
            ($0.model?.selected ?? false)
        }.bind(to: selectIcon.rx.isSelected)
        .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.model?.vio_name
        }.bind(to: desc.rx.text)
        .disposed(by: disposeBag)
    }
}
