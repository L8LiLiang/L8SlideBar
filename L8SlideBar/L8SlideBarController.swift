//
//  L8SlideBarController.swift
//  L8SlideBar
//
//  Created by Chuanxun on 16/3/14.
//  Copyright © 2016年 Leon. All rights reserved.
//

import UIKit
import Foundation

class L8SlideBarController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,L8ItemViewDelegate {
    
    var titles:[String] = []
    var controllers:[UIViewController] = []
    
    var titleViewHeight:CGFloat = 40
    var itemWidth:CGFloat = 120
    
    var slideLineHeight:CGFloat = 2
    var slideLineWidth:CGFloat = 80
    var showSlideLine:Bool = true
    
    
    private var currentSelectIndex:Int = 0
    
    private var currentChildController:UIViewController?
    
    private var currentItemView:L8ItemView?
    
    private var itemViews:[L8ItemView] = []

    private var slideLineXOffset:CGFloat {
        get {
            return (self.itemWidth - self.slideLineWidth ) / 2.0
        }
    }
    
    private var disableCollectionViewDelegateFunc = false
    
    private lazy var titleView:UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = UIColor.whiteColor()
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.bounces = false
        return view
    }()
    
    private lazy var contentView:UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = UIColor.whiteColor()
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.bounces = false
        return view
    }()
    
    private lazy var slideLineView:UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.greenColor()
        return view
    }()
    
    
    private lazy var collectionView:UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height - self.titleViewHeight)
        layout.scrollDirection = .Horizontal
        var colleView = UICollectionView(frame: CGRect(x: 0, y: self.titleViewHeight, width: UIScreen.mainScreen().bounds.size.width, height: self.view.bounds.size.height - self.titleViewHeight), collectionViewLayout: layout)
        colleView.showsVerticalScrollIndicator = false
        colleView.showsHorizontalScrollIndicator = false
        colleView.dataSource = self
        colleView.delegate = self
        self.view.addSubview(colleView)
        
        return colleView
    }()
    
    init(titleViewHeight:CGFloat,slideLineHeight:CGFloat){
        self.titleViewHeight = titleViewHeight
        self.slideLineHeight = slideLineHeight
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "L8SlideCell")
        self.collectionView.pagingEnabled = true
        self.collectionView.bounces = false
        
        self.view.backgroundColor = UIColor.redColor()
        
        if self.showSlideLine {
            self.slideLineView.frame = CGRect(x: slideLineXOffset, y: titleViewHeight - slideLineHeight, width: slideLineWidth, height: slideLineHeight)
            self.titleView.addSubview(self.slideLineView)
        }
        self.view.addSubview(self.titleView)
        self.configTitleView()
        
        self.configCollectionView()
        
//        self.contentView.backgroundColor = UIColor.lightGrayColor()
//        self.view.addSubview(self.contentView)
//        self.configContentView()
        
        if let child = self.controllers.first {
            self.changeCurrentChildController(child)
        }
        
        
    }
    
    func configTitleView()->Void{
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.titleView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[titleView]-0-|", options: .AlignAllLeft, metrics: nil, views: ["titleView":self.titleView])
        self.view.addConstraints(hConstraints)
        
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[titleView(==titleViewHeight)]", options: .AlignAllTop, metrics: ["titleViewHeight":self.titleViewHeight], views: ["titleView":self.titleView])
        self.view.addConstraints(vConstraints)
        
        self.titleView.contentSize = CGSize(width: CGFloat(self.titles.count) * self.itemWidth, height: self.titleViewHeight)
        
        var itemViewHeight:CGFloat = self.slideLineHeight
        if self.showSlideLine {
            itemViewHeight = self.titleViewHeight - self.slideLineHeight
        }
        
        for i in 0..<self.titles.count {
            let x = CGFloat(i) * self.itemWidth
            let itemView = L8ItemView(frame: CGRect(x: x, y: 0, width: self.itemWidth, height: itemViewHeight))
            self.titleView.addSubview(itemView)
            itemView.delegate = self
            itemView.tag = i
            self.itemViews.append(itemView)
        }
        
        if let itemView = self.itemViews.first {
            self.changeCurrentItemView(itemView)
        }
    }
    
    
    func configContentView()->Void{
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[contentView]-0-|", options: .AlignAllLeft, metrics: nil, views: ["contentView":self.contentView])
        self.view.addConstraints(hConstraints)
        
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[titleView]-0-[contentView]-0-|", options: .AlignAllLeft, metrics: ["titleViewHeight":self.titleViewHeight], views: ["titleView":self.titleView,"contentView":self.contentView])
        self.view.addConstraints(vConstraints)
        
        self.contentView.contentSize = CGSize(width: CGFloat(self.controllers.count) * self.view.frame.size.width, height: self.view.frame.size.height - self.titleViewHeight)
        
        let viewHeight = self.view.frame.size.height - self.titleViewHeight
        let viewWidth = self.view.frame.size.width
        
        for i in 0..<self.controllers.count {
            let x = CGFloat(i) * viewWidth
            let view = self.controllers[i].view
            view.frame = CGRect(x: x, y: 0, width: viewWidth, height: viewHeight)
            self.contentView.addSubview(view)
        }

    }
    
    func configCollectionView()->Void{
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[collectionView]-0-|", options: .AlignAllLeft, metrics: nil, views: ["collectionView":self.collectionView])
        self.view.addConstraints(hConstraints)
        
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[titleView]-0-[collectionView]-0-|", options: .AlignAllLeft, metrics: ["titleViewHeight":self.titleViewHeight], views: ["titleView":self.titleView,"collectionView":self.collectionView])
        self.view.addConstraints(vConstraints)
        
        self.contentView.contentSize = CGSize(width: CGFloat(self.controllers.count) * self.view.frame.size.width, height: self.view.frame.size.height - self.titleViewHeight)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.controllers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("L8SlideCell", forIndexPath: indexPath)
        
        let vc = self.controllers[indexPath.row]
        cell.addSubview(vc.view)
        
        return cell
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .Horizontal
        layout.itemSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height - self.titleViewHeight)
        self.collectionView.collectionViewLayout = layout
    }
    
    func taped(itemView:L8ItemView) {
        print("L8SlidebarItem taped")
        
        var oldFrame = self.slideLineView.frame
        oldFrame.origin.x = itemView.frame.origin.x + slideLineXOffset
        
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .TransitionNone, animations: { () -> Void in
            self.slideLineView.frame = oldFrame
            
            let ariveTail = CGFloat(self.titles.count - itemView.tag + 1) * self.itemWidth < self.titleView.frame.size.width
            if itemView.tag == 1 {
                self.titleView.contentOffset = CGPoint(x: 0, y: 0)
            }else if itemView.tag > 1 && !ariveTail{
                self.titleView.contentOffset = CGPoint(x: itemView.frame.origin.x - self.itemWidth, y: 0)
            }else if itemView.tag > 1 && ariveTail {
                self.titleView.contentOffset = CGPoint(x: self.titleView.contentSize.width - self.titleView.frame.size.width, y: 0)
            }
            }, completion: nil)

        self.disableCollectionViewDelegateFunc = true
        let indexPathScrollTo = NSIndexPath(forRow: itemView.tag, inSection: 0)
        self.collectionView.scrollToItemAtIndexPath(indexPathScrollTo, atScrollPosition: .Left, animated: false)
        
        if self.controllers.count > itemView.tag {
            self.changeCurrentChildController(self.controllers[itemView.tag])
        }
        currentSelectIndex = itemView.tag
        
        self.changeCurrentItemView(itemView)
    }
    
    func changeCurrentItemView(itemView:L8ItemView){
        if let view = self.currentItemView {
            view.titleColor = UIColor.blackColor()
        }
        
        itemView.titleColor = UIColor.brownColor()
        self.currentItemView = itemView
    }
    
    func changeCurrentChildController(child:UIViewController){
        if let vc = self.currentChildController {
            vc.removeFromParentViewController()
        }
        
        self.addChildViewController(child)
        self.currentChildController = child
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.disableCollectionViewDelegateFunc {
            return
        }
        let preOffsetX = CGFloat(self.currentSelectIndex) * self.collectionView.frame.size.width
        if self.collectionView.contentOffset.x > preOffsetX {
            let movePercent = (self.collectionView.contentOffset.x - preOffsetX) / self.collectionView.frame.size.width
            var oldFrame = self.slideLineView.frame
            oldFrame.origin.x =  self.slideLineViewXUnderCurrentSelectIndex() + itemWidth * movePercent
            self.slideLineView.frame = oldFrame
            
            print("\(movePercent)")
        }else if self.collectionView.contentOffset.x < preOffsetX {
            let movePercent = (self.collectionView.contentOffset.x - preOffsetX) / self.collectionView.frame.size.width
            var oldFrame = self.slideLineView.frame
            oldFrame.origin.x =  self.slideLineViewXUnderCurrentSelectIndex() + itemWidth * movePercent
            self.slideLineView.frame = oldFrame
            
            print("\(movePercent)")
        }
        
        let offsetX = self.itemWidth / self.collectionView.frame.size.width * self.collectionView.contentOffset.x - itemWidth
        
        if offsetX <= self.titleView.contentSize.width - self.titleView.frame.size.width && offsetX >= 0{
            
            self.titleView.contentOffset = CGPoint(x: offsetX, y: 0)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        if self.disableCollectionViewDelegateFunc {
            self.disableCollectionViewDelegateFunc = false
            return
        }
        
        let currentIndex = self.collectionView.contentOffset.x / self.collectionView.frame.size.width
        self.currentSelectIndex = Int(currentIndex)
        print("currentSelectedIndex \(self.currentSelectIndex)")
        
        let itemView = self.itemViews[self.currentSelectIndex]
        self.changeCurrentItemView(itemView)
        
        /*
        let preOffsetX = CGFloat(self.currentSelectIndex) * self.collectionView.frame.size.width
        if self.collectionView.contentOffset.x > preOffsetX {
            
            var oldFrame = self.slideLineView.frame
            oldFrame.origin.x =  self.slideLineViewXUnderCurrentSelectIndex() + itemWidth
            self.slideLineView.frame = oldFrame

            let newSelectedIndex = self.currentSelectIndex + 1
            let adjustX = CGFloat(self.currentSelectIndex) * self.itemWidth
            
            print("\(currentSelectIndex,newSelectedIndex)")
            
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .TransitionNone, animations: { () -> Void in
                
                let ariveTail = CGFloat(self.titles.count - newSelectedIndex + 1) * self.itemWidth < self.titleView.frame.size.width
                if newSelectedIndex == 1 {
                    self.titleView.contentOffset = CGPoint(x: 0, y: 0)
                }else if newSelectedIndex > 1 && !ariveTail{
                    self.titleView.contentOffset = CGPoint(x: adjustX, y: 0)
                }else if newSelectedIndex > 1 && ariveTail {
                    self.titleView.contentOffset = CGPoint(x: self.titleView.contentSize.width - self.titleView.frame.size.width, y: 0)
                }
                }, completion: nil)
            
            if self.controllers.count > newSelectedIndex {
                self.changeCurrentChildController(self.controllers[newSelectedIndex])
            }
            currentSelectIndex = newSelectedIndex
            
        }else if self.collectionView.contentOffset.x < preOffsetX {
            
            var oldFrame = self.slideLineView.frame
            oldFrame.origin.x =  self.slideLineViewXUnderCurrentSelectIndex() - itemWidth
            self.slideLineView.frame = oldFrame
           
            let newSelectedIndex = self.currentSelectIndex - 1
            print("\(currentSelectIndex,newSelectedIndex)")
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .TransitionNone, animations: { () -> Void in
                
                let ariveTail = CGFloat(self.titles.count - newSelectedIndex + 1) * self.itemWidth < self.titleView.frame.size.width
                if newSelectedIndex == 1 {
                    self.titleView.contentOffset = CGPoint(x: 0, y: 0)
                }else if newSelectedIndex > 1 && !ariveTail{
                    self.titleView.contentOffset = CGPoint(x: CGFloat(newSelectedIndex - 1) * self.itemWidth, y: 0)
                }else if newSelectedIndex > 1 && ariveTail {
                    self.titleView.contentOffset = CGPoint(x: self.titleView.contentSize.width - self.titleView.frame.size.width, y: 0)
                }
                }, completion: nil)
            
            if self.controllers.count > newSelectedIndex {
                self.changeCurrentChildController(self.controllers[newSelectedIndex])
            }
            currentSelectIndex = newSelectedIndex
        }
        */
        
        
    }

    func slideLineViewXUnderCurrentSelectIndex()->CGFloat {
        
        return CGFloat(self.currentSelectIndex) * itemWidth + slideLineXOffset
        
    }
    
    deinit {
        
        print("L8SlideBarController deinit")
    }
    
}
