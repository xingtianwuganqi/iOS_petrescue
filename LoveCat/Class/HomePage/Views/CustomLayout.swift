//
//  CustomLayout.swift
//  LoveCat
//
//  Created by jingjun on 2020/10/19.
//

import Foundation

let margin: CGFloat = 5

class CustomLayout: UICollectionViewFlowLayout {
    // 内容区域总大小，不是可见区域
    override var collectionViewContentSize: CGSize {
        let width = collectionView!.bounds.size.width - collectionView!.contentInset.left
            - collectionView!.contentInset.right
        let height = collectionView!.bounds.size.height
        return CGSize(width: width, height: height)
    }
    
    // 所有单元格位置属性
    override func layoutAttributesForElements(in rect: CGRect)
    -> [UICollectionViewLayoutAttributes]? {
        var attributesArray = [UICollectionViewLayoutAttributes]()
        let cellCount = self.collectionView!.numberOfItems(inSection: 0)
        for i in 0..<cellCount {
            let indexPath =  IndexPath(item:i, section:0)
            let attributes =  self.layoutAttributesForItem(at: indexPath)
            attributesArray.append(attributes!)
        }
        return attributesArray
    }
    
    // 这个方法返回每个单元格的位置和大小
    override func layoutAttributesForItem(at indexPath: IndexPath)
    -> UICollectionViewLayoutAttributes? {
        //当前单元格布局属性
        let attribute =  UICollectionViewLayoutAttributes(forCellWith:indexPath)
        
        // 根据数据不同展示不同的样式
        let cellCount = self.collectionView!.numberOfItems(inSection: 0)
        
        // 只显示一张图片
        if cellCount == 1 {
            // 单元格边长
            let largeCellSide = collectionViewContentSize.width
            let largeCellHeight = collectionViewContentSize.height
            attribute.frame = CGRect(x:0, y:0, width:largeCellSide,
                                     height:largeCellHeight)
            
        }else if cellCount == 2 {
            // 单元格边长
            let largeCellSide = (collectionViewContentSize.width - margin) / 2
            let largeCellHeight = collectionViewContentSize.height
            if indexPath.item % 4 == 0 {
                attribute.frame = CGRect(x:0, y:0, width:largeCellSide,
                                         height:largeCellHeight)
            }else if indexPath.item % 4 == 1 {
                attribute.frame = CGRect(x:largeCellSide + margin, y:0, width:largeCellSide,
                                         height:largeCellHeight)
            }
            
        }else if cellCount == 3 {
            // 单元格边长
            let largeCellSide = (collectionViewContentSize.width - margin) / 2
            let largeCellHeight = collectionViewContentSize.height
            
            let smallCellHeight = (collectionViewContentSize.height - margin) / 2
            let smallCellTopX = largeCellSide + margin
            let smallCellBottomY = smallCellHeight + margin
            if indexPath.item % 4 == 0 {
                attribute.frame = CGRect(x:0, y:0, width:largeCellSide,
                                         height:largeCellHeight)
            }else if indexPath.item % 4 == 1 {
                attribute.frame = CGRect(x:smallCellTopX, y:0, width:largeCellSide,
                                         height:smallCellHeight)
            }else if indexPath.item % 4 == 2 {
                attribute.frame = CGRect(x:smallCellTopX, y:smallCellBottomY, width:largeCellSide,
                                         height:smallCellHeight)
            }
        }else if cellCount == 4 {
            // 单元格边长
            let largeCellSide = (collectionViewContentSize.width - margin) / 2
            let largeCellHeight = (collectionViewContentSize.height - margin) / 2
            
            let smallCellTopX = largeCellSide + margin
            let smallCellBottomY = largeCellHeight + margin
            if indexPath.item % 4 == 0 {
                attribute.frame = CGRect(x:0, y:0, width:largeCellSide,
                                         height:largeCellHeight)
            }else if indexPath.item % 4 == 1 {
                attribute.frame = CGRect(x:smallCellTopX, y:0, width:largeCellSide,
                                         height:largeCellHeight)
            }else if indexPath.item % 4 == 2 {
                attribute.frame = CGRect(x:0, y:smallCellBottomY, width:largeCellSide,
                                         height:largeCellHeight)
            }else if indexPath.item % 4 == 3 {
                attribute.frame = CGRect(x:smallCellTopX, y:smallCellBottomY, width:largeCellSide,
                                         height:largeCellHeight)
            }
        }
        return attribute
    }
}


