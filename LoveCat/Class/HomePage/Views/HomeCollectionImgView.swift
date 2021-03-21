//
//  HomeCollectionImgView.swift
//  LoveCat
//
//  Created by jingjun on 2020/10/19.
//

import UIKit

class HomeCollectionImgView: UIView {
    
    var images : [String] = [] {
        didSet {
            let minCount = min(images.count,4)
            self.datas = Array(images[0..<minCount])
            self.collectionView.reloadData()
        }
    }
    
    fileprivate var datas: [String] = []
    
    
    lazy var collectionView : UICollectionView = {
        let layout = CustomLayout.init()

        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .onDrag
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = true
        collectionView.register(CollectionImgCell.self, forCellWithReuseIdentifier: "CollectionImgCell")
        
        return collectionView
    }()
    
    var didSelectItem: ((Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setUI() {
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension HomeCollectionImgView: UICollectionViewDelegate,UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.datas.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionImgCell", for: indexPath) as! CollectionImgCell
        cell.imgUrl = self.datas[indexPath.item]
        if (self.images.count > self.datas.count) && (indexPath.item == 3) {
            cell.countView.isHidden = false
            cell.countView.countLab.text = "+\(self.images.count - self.datas.count)"
        }else{
            cell.countView.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.didSelectItem?(indexPath.item)
    }
}
