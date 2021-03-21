//
//  ShowImgCollectionView.swift
//  LoveCat
//
//  Created by jingjun on 2021/1/18.
//

import UIKit

class ShowImgCollectionView: UIView {
    
    lazy var collectionView : UICollectionView = {
        let layout = CollectionPageFlowLayout.init() // 给分页添加间距
        layout.sectionHeadersPinToVisibleBounds = true
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: floor(ScreenW), height: floor(ScreenW))
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.alwaysBounceVertical = false // 不允许上下弹跳
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ShowPageCollectionCell.self, forCellWithReuseIdentifier: "ShowPageCollectionCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    lazy var pageControl : UIPageControl = {
        let pageControl = UIPageControl.init()
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.hidesForSinglePage = true
        pageControl.numberOfPages = self.imgs.count
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    
    var imgs : [String] = [] {
        didSet {
            self.collectionView.reloadData()
            self.pageControl.numberOfPages = self.imgs.count
            self.collectionView.scrollToLeft(animated: false)
            if let index = collectionView.indexPathForItem(at: collectionView.contentOffset)?.item{
                
                self.pageControl.currentPage = Int(index)
            }else{
                self.pageControl.currentPage = 0
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(collectionView)
        self.addSubview(pageControl)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        pageControl.frame = CGRect(x: 0, y: self.frame.size.height - 40, width: self.frame.size.width, height: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.collectionView ,let index = collectionView.indexPathForItem(at: collectionView.contentOffset)?.item{
            
            self.pageControl.currentPage = Int(index)
        }
    }
}
extension ShowImgCollectionView: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imgs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowPageCollectionCell", for: indexPath) as! ShowPageCollectionCell
        cell.text = imgs[indexPath.item]
        return cell
    }
}
