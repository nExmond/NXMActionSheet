//
//  ViewController.swift
//  NXMActionSheet
//
//  Created by nexmond on 01/11/2018.
//  Copyright (c) 2018 nexmond. All rights reserved.
//

import UIKit
import NXMActionSheet

class ViewController: UIViewController {
    
    @IBOutlet var presetsSegment: UISegmentedControl!
    @IBOutlet var animationTypeSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func show(_ sender: UIButton) {
        
        let typeIndxe = animationTypeSegment.selectedSegmentIndex
        let type:NXMActionSheetAnimationType = (typeIndxe == 0 ? .slide : .fade)
        
        switch presetsSegment.selectedSegmentIndex {
        case 0: defaultShow(type: type)
        case 1: customShow(type: type)
        case 2: mixedShow(type: type)
        default: break
        }
    }
    
    func defaultShow(type:NXMActionSheetAnimationType) {
        
        NXMActionSheet(delegate: self, type: type)
            .add(.init(.image(#imageLiteral(resourceName: "image"))))
            .add(.init(.activityIndicator(.gray)))
            .add(.init(.slider(0.5, nil)))
            .add(.init(.label("Label")))
            .add(.init(.button("Button", UIColor.brown, nil), withTouchClose: true))
            .show()
    }
    
    func customShow(type:NXMActionSheetAnimationType) {
        
        CustomActionSheet(withType: type).show()
    }
    
    func mixedShow(type:NXMActionSheetAnimationType) {
        
        //whthout delegate
        NXMActionSheet(type: type)
            .add(.init(.button("Select", UIColor.darkGray, { sender in
                print((sender as? UIButton)!.titleLabel!.text!)
            }), withTouchClose: true))
            .add(.init(.custom(CustomDatePickerView.loadView())))
            .show()
    }
}

extension ViewController : NXMActionSheetDelegate {
    
    func didSelectActionItem(_ actionSheet:NXMActionSheet, withData:NXMActionSheetData) {
        trace("default", withData.typeDescription)
    }
    
    func actionSheetWillShow() {
        trace("default")
    }
    
    func actionSheetDidShow() {
        trace("default")
    }
    
    func actionSheetWillHide() {
        trace("default")
    }
    
    func actionSheetDidHide() {
        trace("default")
    }
    
    func actionSheetWillUpdate() {
        trace("default")
    }
    
    func actionSheetDidUpdate() {
        trace("default")
    }
}

extension NXMActionSheetDelegate {
    
    func trace(_ header:String, function:String = #function, _ message:String = "") {
        print(header, function, message)
    }
}
