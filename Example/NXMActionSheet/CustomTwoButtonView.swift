//
//  CustomTwoButtonView.swift
//  NXMActionSheet_Example
//
//  Created by Twinny on 2018. 1. 12..
//  Copyright © 2018년 CocoaPods. All rights reserved.
//

import UIKit
import NXMActionSheet

class CustomTwoButtonView : UIView {
    
    @IBOutlet private var leftButton: UIButton!
    @IBOutlet private var rightButton: UIButton!
    
    private var leftAction:NXMControlAction?
    private var rightAction:NXMControlAction?
    
    func setLeftButton(withTitle:String, _ action:NXMControlAction? = nil) {
        setButtonCore(button: leftButton, withTitle: withTitle, action)
    }
    
    func setRightButton(withTitle:String, _ action:NXMControlAction? = nil) {
        setButtonCore(isLeft: false, button: rightButton, withTitle: withTitle, action)
    }
    
    private func setButtonCore(isLeft:Bool=true, button:UIButton, withTitle:String, _ action:NXMControlAction? = nil) {
        if isLeft {
            button.tag = 0
            leftAction = action
        }else {
            button.tag = 1
            button.isHidden = false
            rightAction = action
        }
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        button.setTitle(withTitle, for: .normal)
    }
    
    @objc private func buttonAction(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            leftAction?(leftButton)
        case 1:
            rightAction?(rightButton)
        default:
            break
        }
    }
}
