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
        
        let preset = presetsSegment.selectedSegmentIndex
        var aniType:NXMActionSheetAnimationType = .SLIDE
        if animationTypeSegment.selectedSegmentIndex == 1 {
            aniType = .FADE
        }
        
        switch preset {
        case 0:
            defaultShow(type: aniType)
        case 1:
            customShow(type: aniType)
        case 2:
            mixedShow(type: aniType)
        default:
            break
        }
        
    }
    
    func defaultShow(type:NXMActionSheetAnimationType) {
        
        NXMActionSheet(withType: type)
            .add(NXMActionSheetData(.IMAGE(#imageLiteral(resourceName: "image"))))
            .add(NXMActionSheetData(.ACTIVITY_INDICATOR(.gray)))
            .add(NXMActionSheetData(.SLIDER(0.5, nil)))
            .add(NXMActionSheetData(.LABEL("Label")))
            .add(NXMActionSheetData(.BUTTON("Button", UIColor.brown, nil), withTouchClose: true))
            .show()
    }

    func customShow(type:NXMActionSheetAnimationType) {
        
        CustomActionSheet(withType: type).show()
    }
    
    func mixedShow(type:NXMActionSheetAnimationType) {
        
        let datePicker:CustomDatePickerView = CustomDatePickerView.loadUINibView()
        
        NXMActionSheet(withType: type)
            .add(NXMActionSheetData(.BUTTON("Select", UIColor.darkGray, { sender in
                if let button = sender as? UIButton {
                    print(button.titleLabel!.text!)
                }
            }), withTouchClose: true))
        .add(NXMActionSheetData(.CUSTOM(datePicker)))
        .show()
    }
}

