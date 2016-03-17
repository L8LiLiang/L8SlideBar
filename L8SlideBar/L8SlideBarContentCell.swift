//
//  L8SlideBarContentCell.swift
//  L8SlideBar
//
//  Created by Chuanxun on 16/3/16.
//  Copyright © 2016年 Leon. All rights reserved.
//

import UIKit

class L8SlideBarContentCell: UICollectionViewCell {

    
    var bodyView:UIView? {
        willSet {
           bodyView?.removeFromSuperview()
            if let view = newValue {
                self.addSubview(view)
                view.translatesAutoresizingMaskIntoConstraints = false
                let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subView]-0-|", options: .AlignAllBaseline, metrics: nil, views: ["subView":view])
                let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subView]-0-|", options: .AlignAllBaseline, metrics: nil, views: ["subView":view])
                self.addConstraints(hConstraints)
                self.addConstraints(vConstraints)
            }
        }
    }
}
