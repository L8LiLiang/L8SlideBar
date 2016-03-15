//
//  TestController.swift
//  L8SlideBar
//
//  Created by Chuanxun on 16/3/15.
//  Copyright © 2016年 Leon. All rights reserved.
//

import UIKit

class TestController: UIViewController {

    lazy var btn:UIButton = {
        let btn = UIButton(frame: CGRect(x: 20, y: 60, width: 120, height: 40))
        btn.addTarget(self, action: "btnClicked:", forControlEvents: .TouchUpInside)
        btn.backgroundColor = UIColor.blackColor()
        
        //btn.setTitle("click me😄\(titleDesc)", forState: .Normal)
        self.view.addSubview(btn)
        return btn
    }()
    var titleDesc:String = "x" {
        willSet {
           self.btn.setTitle("click me😄\(newValue)", forState: .Normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = randomColor()
        

    }
    
    func btnClicked(sender:UIButton){
        NSLog("vc %p clicked", self)
    }
}
