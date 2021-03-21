//
//  ReleaseImgView.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/22.
//

import UIKit

class ReleaseImgView: UIView {
    
//    static let cellW = floor((SCREEN_WIDTH - 30 - 3 * 10) / 4)
    
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.sectionHeadersPinToVisibleBounds = true
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: self.coCellWidth, height: self.coCellWidth)
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .white
        collectionView.keyboardDismissMode = .onDrag
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = true
        collectionView.register(ReleaseImgCell.self, forCellWithReuseIdentifier: "ReleaseImgCell")
        collectionView.register(AddPhotoCell.self, forCellWithReuseIdentifier: "AddPhotoCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    var deleteItmeBlock: ((ReleasePhotoModel) -> Void)?
    var model: [ReleasePhotoModel]? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var addPhotoClick: (() -> Void)?
    fileprivate let coCellWidth: CGFloat
    init(cellW: CGFloat) {
        self.coCellWidth = cellW
        super.init(frame: .zero)
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension ReleaseImgView: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.model?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = self.model?[indexPath.item]
        if model?.isAdd == true {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddPhotoCell", for: indexPath)
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReleaseImgCell", for: indexPath) as! ReleaseImgCell
            cell.model = model
            cell.deleteItmeBlock = { [weak self](item) in
                guard let `self` = self else { return }
                self.deleteItmeBlock?(item)
            }
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = self.model?[indexPath.row] else {
            return
        }
        if item.isAdd == true {
            self.addPhotoClick?()
        }
    }
}


class AddressView: UIView {
    lazy var addressLab: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.color(.content)
        label.font = UIFont.et.fontSize(.regular,.content)
        return label
    }()
    
    var title: String? {
        didSet {
            self.addressLab.text = title
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.color(.defIcon)
        self.addSubview(self.addressLab)
        self.addressLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ContactTextView: UIView {
    lazy var textField: UITextField = {
        let label = UITextField.init()
        label.textColor = UIColor.color(.content)
        label.font = UIFont.et.fontSize(.regular,.content)
        label.placeholder = "请输入联系方式,例如：手机号：xxx 或 微信：xxx"
        label.returnKeyType = .done
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.color(.defIcon)
        self.addSubview(self.textField)
        self.textField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
