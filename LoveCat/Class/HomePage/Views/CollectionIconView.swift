//
//  CollectionIconView.swift
//  CollectionIconDemo
//
//  Created by jingjun on 2020/10/14.
//  Copyright © 2020 jingjun. All rights reserved.
//

import UIKit

class CollectionIconView: UIView {
    
    var models: [TagInfoModel]  = [] {
        didSet {
            if models.count > 0 {
                self.collectionView.reloadData()
            }
        }
    }
    
    var selectIndexBlock: ((Int) -> Void)?
    var reloadHeight:((CGFloat) -> Void)?
    
    lazy var collectionView : UICollectionView = {
        let layout = XTWaterFlowLayout.init(spacing: self.spacing, margin: self.margin)
        layout.rowHeight = self.rowHeight
        layout.delegate = self
        
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .onDrag
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = true
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        
        return collectionView
    }()
    
    fileprivate var spacing: CGFloat
    fileprivate var margin: CGFloat
    fileprivate var rowHeight: CGFloat
    fileprivate var titleFont: UIFont?
    init(spacing: CGFloat,margin: CGFloat,rowHeight: CGFloat,titleFont: UIFont? = UIFont.et.font(size: 13)) {
        self.spacing = spacing
        self.margin = margin
        self.rowHeight = rowHeight
        self.titleFont = titleFont
        super.init(frame: .zero)
        self.backgroundColor = .white
        self.addSubview(self.collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension CollectionIconView: UICollectionViewDelegate,UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.models.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.iconBtn.setTitle(models[indexPath.item].tag_name, for: .normal)
        cell.iconBtn.layer.cornerRadius = self.rowHeight / 2
        cell.iconBtn.titleLabel?.font = self.titleFont
        if models[indexPath.item].select {
            cell.iconBtn.layer.borderColor = UIColor.color(.system)?.cgColor
            cell.iconBtn.isSelected = true
        }else{
            cell.iconBtn.layer.borderColor = UIColor(hexString: "#E6E6E6")?.cgColor
            cell.iconBtn.isSelected = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectIndexBlock?(indexPath.row)
    }
    
    
}

extension CollectionIconView: XTWaterFlowLayoutDelegate {
    func waterFlowLayout(layout: XTWaterFlowLayout, withAt indexPath: IndexPath) -> CGFloat {
        let str = (models[indexPath.row].tag_name ?? "") as NSString
        let w = str.boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width, height: CGFloat.infinity), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: UIFont.et.font(size: 13)], context: nil).width
        return w + 20
    }
    
    func waterContentSizeHeight(height: CGFloat) {
        self.reloadHeight?(height)
    }
}

class CollectionViewCell: UICollectionViewCell {
    lazy var iconBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitleColor(UIColor.color(.desc), for: .normal)
        button.setTitleColor(UIColor.color(.system), for: .selected)
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(hexString: "#E6E6E6")?.cgColor
        button.titleLabel?.font = UIFont.et.font(size: 13)
        button.isUserInteractionEnabled = false
        return button
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(iconBtn)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.iconBtn.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.size.width, height: self.contentView.frame.size.height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
