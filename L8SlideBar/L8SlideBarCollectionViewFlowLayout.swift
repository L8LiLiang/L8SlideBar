//
//  L8SlideBarCollectionViewFlowLayout.swift
//  L8SlideBar
//
//  Created by Chuanxun on 16/3/18.
//  Copyright © 2016年 Leon. All rights reserved.
//

import UIKit

class L8SlideBarCollectionViewFlowLayout: UICollectionViewFlowLayout {

    
    override func prepareLayout() {
        //self.itemSize = CGSize(width: (self.collectionView?.frame.width)!, height: (self.collectionView?.frame.height)!)
        self.sectionInset = UIEdgeInsetsZero
        self.footerReferenceSize = CGSizeZero
        self.headerReferenceSize = CGSizeZero
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = 0
        
        super.prepareLayout()
        
        print("prepareLayout \(self.itemSize)")
    }
    
    override func collectionViewContentSize() -> CGSize {
        let size = CGSize(width: (self.collectionView?.bounds.width)! * (CGFloat)((self.collectionView?.dataSource?.collectionView(self.collectionView!, numberOfItemsInSection: 0))!), height: (self.collectionView?.bounds.height)!)
        print("collectionViewContentSize \(size)")
        return size
    }
    
}
