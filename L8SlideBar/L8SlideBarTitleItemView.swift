//
//  L8TitleView.swift
//  L8SlideBar
//
//  Created by Chuanxun on 16/3/14.
//  Copyright © 2016年 Leon. All rights reserved.
//

import UIKit

protocol L8SlideBarTitleItemViewDelegate:class {
    func taped(itemView:L8SlideBarTitleItemView)->Void
}


class L8SlideBarTitleItemView: UIView {

    weak var delegate:L8SlideBarTitleItemViewDelegate?
    
    lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(14)
        label.textColor = UIColor.blackColor()
        label.text = "swift"
        label.textAlignment = .Left
        return label
    }()
    
    
    var title:String? {
        get {
            return self.titleLabel.text
        }
        
        set {
            self.titleLabel.text = newValue
        }
    }
    
    var titleColor:UIColor {
        get {
            return self.titleLabel.textColor
        }
        
        set {
            self.titleLabel.textColor = newValue
        }
    }
    
    var titleFont:UIFont {
        get {
            return self.titleLabel.font
        }
        
        set {
            self.titleLabel.font = newValue
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let hConstraints = NSLayoutConstraint(item: titleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        let vConstraints = NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        self.addConstraint(hConstraints)
        self.addConstraint(vConstraints)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "taped:")
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tapGesture)
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func taped(sender:UITapGestureRecognizer)->Void{
        self.delegate?.taped(self)
    }
    
    deinit{
        print("L8SlideBar deinit")
    }
    
}
