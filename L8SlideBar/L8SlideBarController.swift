//
//  L8SlideBarController.swift
//  L8SlideBar
//
//  Created by Chuanxun on 16/3/14.
//  Copyright © 2016年 Leon. All rights reserved.
//

import UIKit
import Foundation

let myGreenColor = UIColor(red: 73/255.0, green: 206/255.0, blue: 23/255.0, alpha: 1.0)

let cell_reuse_id = "L8SlideBarContentCell"

class L8SlideBarController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,L8SlideBarTitleItemViewDelegate {
    
    var titles:[String] = []
    var controllers:[UIViewController] = []
    
    var titleViewHeight:CGFloat = 40
    var titleViewItemWidth:CGFloat = 80
    
    var statusIndicateLineHeight:CGFloat = 2 {
        didSet {
            if statusIndicateLineHeight >= titleViewHeight
            {
                statusIndicateLineHeight = titleViewHeight / 4
            }
        }
    }
    var statusIndicateLineWidth:CGFloat = 60 {
        didSet {
            if statusIndicateLineWidth > titleViewItemWidth {
                statusIndicateLineWidth = titleViewItemWidth
            }
        }
    }
    var showStatusIndicateLine:Bool = true
    var selectedTitleColor = myGreenColor
    var deselectedTitleColor = UIColor(red: 60/255.0, green: 60/255.0, blue: 60/255.0, alpha: 1.0)
    var statusIndicateLineColor = myGreenColor
    var titleFont = UIFont.systemFontOfSize(16)
    
    
    private var layoutConstraintsNeedUpdate = [NSLayoutConstraint]()
    
    private var currentSelectIndex:Int = 0
    
    private var currentChildController:UIViewController?
    
    private var currentItemView:L8SlideBarTitleItemView?
    
    private var itemViews:[L8SlideBarTitleItemView] = []

    private var satusIndicateLineXOffset:CGFloat {
        get {
            return (self.titleViewItemWidth - self.statusIndicateLineWidth ) / 2.0
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
    
    
    private lazy var statusIndicateLineView:UIView = {
       let view = UIView()
        view.backgroundColor = self.statusIndicateLineColor
        return view
    }()
    
    
    private lazy var collectionView:UICollectionView = {
        
        let layout = L8SlideBarCollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        //layout.itemSize = CGSize(width: 10, height: 10)  //在viewDidLayoutSubviews方法中设置
        layout.scrollDirection = .Horizontal
        var colleView = UICollectionView(frame: CGRect(x: 0, y: self.titleViewHeight, width: UIScreen.mainScreen().bounds.size.width, height: self.view.bounds.size.height - self.titleViewHeight), collectionViewLayout: layout)
        colleView.showsVerticalScrollIndicator = false
        colleView.showsHorizontalScrollIndicator = false
        colleView.dataSource = self
        colleView.delegate = self
        self.view.addSubview(colleView)
        colleView.pagingEnabled = true
        colleView.bounces = false
        colleView.registerClass(L8SlideBarContentCell.self, forCellWithReuseIdentifier: cell_reuse_id)
        return colleView
    }()
    
    init(titleViewHeight:CGFloat,statusIndicateLineHeight:CGFloat){
        self.titleViewHeight = titleViewHeight
        self.statusIndicateLineHeight = statusIndicateLineHeight
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .None
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.redColor()

        self.configTitleView()
        
        self.configCollectionView()
        
        if let child = self.controllers.first {
            self.changeCurrentChildController(child)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //print("viewWillAppear,\(self.collectionView.frame)")
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        //print("viewWillLayoutSubviews,\(self.collectionView.frame)")
    }
    
    
    //viewDidLayoutSubviews在viewDidAppear之前进行调用，此时view的frame已经确定，此时是进行frame调整的良机
    override func viewDidLayoutSubviews() {
        
//        self.collectionView.contentSize = CGSize(width: CGFloat(self.controllers.count) * self.view.frame.size.width, height: self.collectionView.frame.size.height)
        /*
        let layout = self.collectionView.collectionViewLayout as! L8SlideBarCollectionViewFlowLayout
        layout.itemSize = CGSize(width: self.collectionView.frame.size.width, height: self.collectionView.frame.size.height)
        
        print("viewDidLayoutSubviews \(self.collectionView.frame)")
        
        layout.invalidateLayout()
        */
//        self.view.layoutSubviews()
        
        
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //print("viewDidAppear")
        
        
    }
 
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        //print("viewWillTransitionToSize")
        if #available(iOS 8.0, *) {
            super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        } else {
            // Fallback on earlier versions
        }
        
        self.collectionView.collectionViewLayout.invalidateLayout()
        
        coordinator.animateAlongsideTransition(nil) { (transitionCoordinatorContext) -> Void in
            self.collectionView.collectionViewLayout.invalidateLayout()
            if let itemView = self.currentItemView {
                self.taped(itemView)
            }
        }
        
    }

//    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
//        self.collectionView.collectionViewLayout.invalidateLayout()
//
//    }
    
 /*
    override func didMoveToParentViewController(parent: UIViewController?) {
        
        super.didMoveToParentViewController(parent)
        
        if let newParentVc = parent {
            //self.view.removeConstraints(self.layoutConstraintsNeedUpdate)
            self.view.translatesAutoresizingMaskIntoConstraints = false
            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[parentVcViewTopLayout]-0-[view]-0-|", options: .AlignAllLeft, metrics: nil, views: ["view":self.view,"parentVcViewTopLayout":newParentVc.topLayoutGuide])
            let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: .AlignAllTop, metrics: nil, views: ["view":self.view,"parentVcView":newParentVc.view])
            newParentVc.view.addConstraints(vConstraints)
            newParentVc.view.addConstraints(hConstraints)
            //self.layoutConstraintsNeedUpdate = vConstraints
            
            newParentVc.view.setNeedsLayout()
            newParentVc.view.layoutIfNeeded()
        }else {
            self.view.translatesAutoresizingMaskIntoConstraints = true
        }
//        else {
//            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[tapLayoutGuide]-0-[titleView(==titleViewHeight)]", options: .AlignAllLeft, metrics: ["titleViewHeight":self.titleViewHeight], views: ["titleView":self.titleView,"tapLayoutGuide":self.topLayoutGuide])
//            self.view.addConstraints(vConstraints)
//            self.layoutConstraintsNeedUpdate = vConstraints
//            
//            self.view.setNeedsLayout()
//            self.view.layoutIfNeeded()
//        }
        
    }
  */
    func configTitleView()->Void{
        
        if self.showStatusIndicateLine {
            self.statusIndicateLineView.frame = CGRect(x: satusIndicateLineXOffset, y: titleViewHeight - statusIndicateLineHeight, width: statusIndicateLineWidth, height: statusIndicateLineHeight)
            self.titleView.addSubview(self.statusIndicateLineView)
            //self.statusIndicateLineView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        self.view.addSubview(self.titleView)
        self.titleView.translatesAutoresizingMaskIntoConstraints = false
        
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[titleView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["titleView":self.titleView])
        self.view.addConstraints(hConstraints)
        
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[tapLayoutGuide]-0-[titleView(==titleViewHeight)]", options: .AlignAllLeft, metrics: ["titleViewHeight":self.titleViewHeight], views: ["titleView":self.titleView,"tapLayoutGuide":self.topLayoutGuide])
        self.view.addConstraints(vConstraints)
        
        
        
        self.titleView.contentSize = CGSize(width: CGFloat(self.titles.count) * self.titleViewItemWidth, height: self.titleViewHeight)
        
        var itemViewHeight:CGFloat = self.titleViewHeight
        if self.showStatusIndicateLine {
            itemViewHeight = self.titleViewHeight - self.statusIndicateLineHeight
        }
        
        for i in 0..<self.titles.count {
            let x = CGFloat(i) * self.titleViewItemWidth
            let itemView = L8SlideBarTitleItemView(frame: CGRect(x: x, y: 0, width: self.titleViewItemWidth, height: itemViewHeight))
            self.titleView.addSubview(itemView)
            itemView.delegate = self
            itemView.tag = i
            itemView.title = self.titles[i]
            itemView.titleColor = self.deselectedTitleColor
            itemView.titleFont = self.titleFont
            self.itemViews.append(itemView)

        }
        
        if let itemView = self.itemViews.first {
            self.changeCurrentItemView(itemView)
        }
    }
    
    
    func configCollectionView()->Void{
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[collectionView]-0-|", options: .AlignAllLeft, metrics: nil, views: ["collectionView":self.collectionView])
        self.view.addConstraints(hConstraints)
        
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[titleView]-0-[collectionView]-0-|", options: .AlignAllLeft, metrics: ["titleViewHeight":self.titleViewHeight], views: ["titleView":self.titleView,"collectionView":self.collectionView])
        self.view.addConstraints(vConstraints)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.controllers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cell_reuse_id, forIndexPath: indexPath) as! L8SlideBarContentCell
        
        let vc = self.controllers[indexPath.row]
        cell.bodyView = vc.view
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return self.collectionView.bounds.size
    }
    
    
    func taped(itemView:L8SlideBarTitleItemView) {
        //print("taped")
        var oldFrame = self.statusIndicateLineView.frame
        oldFrame.origin.x = itemView.frame.origin.x + satusIndicateLineXOffset
        
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .TransitionNone, animations: { () -> Void in
            self.statusIndicateLineView.frame = oldFrame
            
            let ariveTail = CGFloat(self.titles.count - itemView.tag + 1) * self.titleViewItemWidth < self.titleView.frame.size.width
            if itemView.tag == 1 {
                self.titleView.contentOffset = CGPoint(x: 0, y: 0)
            }else if itemView.tag > 1 && !ariveTail{
                self.titleView.contentOffset = CGPoint(x: itemView.frame.origin.x - self.titleViewItemWidth, y: 0)
            }else if itemView.tag > 1 && ariveTail {
                self.titleView.contentOffset = CGPoint(x: self.titleView.contentSize.width - self.titleView.frame.size.width, y: 0)
            }
            }, completion: nil)

        //self.disableCollectionViewDelegateFunc = true
        let indexPathScrollTo = NSIndexPath(forRow: itemView.tag, inSection: 0)
        self.collectionView.scrollToItemAtIndexPath(indexPathScrollTo, atScrollPosition: .Left, animated: false)
        if self.controllers.count > itemView.tag {
            self.changeCurrentChildController(self.controllers[itemView.tag])
        }
        currentSelectIndex = itemView.tag
        
        self.changeCurrentItemView(itemView)
    }
    
    func changeCurrentItemView(itemView:L8SlideBarTitleItemView){
        if let view = self.currentItemView {
            view.titleColor = self.deselectedTitleColor
        }
        
        itemView.titleColor = self.selectedTitleColor
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
            var oldFrame = self.statusIndicateLineView.frame
            oldFrame.origin.x =  self.statusIndicateLineViewXUnderCurrentSelectIndex() + titleViewItemWidth * movePercent
            self.statusIndicateLineView.frame = oldFrame
            
        }else if self.collectionView.contentOffset.x < preOffsetX {
            let movePercent = (self.collectionView.contentOffset.x - preOffsetX) / self.collectionView.frame.size.width
            var oldFrame = self.statusIndicateLineView.frame
            oldFrame.origin.x =  self.statusIndicateLineViewXUnderCurrentSelectIndex() + titleViewItemWidth * movePercent
            self.statusIndicateLineView.frame = oldFrame
            
        }
        
        let offsetX = self.titleViewItemWidth / self.collectionView.frame.size.width * self.collectionView.contentOffset.x - titleViewItemWidth
        
        if offsetX <= self.titleView.contentSize.width - self.titleView.frame.size.width && offsetX >= 0{
            self.titleView.contentOffset = CGPoint(x: offsetX, y: 0)
        }else if offsetX <= self.titleView.contentSize.width - self.titleView.frame.size.width {
            self.titleView.contentOffset = CGPoint(x: 0, y: 0)
        }else if offsetX >= 0 {
            self.titleView.contentOffset = CGPoint(x: self.titleView.contentSize.width - self.titleView.frame.size.width, y: 0)
        }
        //print("contentOffset \(self.titleView.contentOffset)")
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        //print("scrollViewDidEndDecelerating")
        
        if self.disableCollectionViewDelegateFunc {
            self.disableCollectionViewDelegateFunc = false
            return
        }
        let currentIndex = self.collectionView.contentOffset.x / self.collectionView.frame.size.width
        self.currentSelectIndex = Int(currentIndex)
        
        let itemView = self.itemViews[self.currentSelectIndex]
        self.changeCurrentItemView(itemView)
        
    }

    
    func statusIndicateLineViewXUnderCurrentSelectIndex()->CGFloat {
        
        return CGFloat(self.currentSelectIndex) * titleViewItemWidth + satusIndicateLineXOffset
        
    }
    
    deinit {
        
        print("L8SlideBarController deinit")
    }
    
}
