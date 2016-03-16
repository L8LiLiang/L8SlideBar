# L8SlideBar

LSlideBar是用swift语言编写的滚动栏栏工具。


#使用

把
<
L8SlideBarController.swift
L8SlideBarTitleItemView.swift
>
两个文件添加到工程中


      
       let slideBarController = L8SlideBarController(titleViewHeight: 32, statusIndicateLineHeight: 2)
       slideBarController.titles = ["头条","圈子","集锦","中超","深度","足彩","专题","闲情","英超","装备"]
       for i in 0..<slideBarController.titles.count {
            let ctl = TestController(nibName: nil, bundle: nil)
            ctl.view.backgroundColor = randomColor()
            ctl.titleDesc = "\(i)"
            controller.controllers.append(ctl)
        }

        slideBarController.showStatusIndicateLine = true
        slideBarController.titleViewItemWidth = 80
        slideBarController.statusIndicateLineWidth = 60
        slideBarController.titleFont = UIFont.systemFontOfSize(14)
