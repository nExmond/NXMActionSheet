//
//  CustomActionSheet.swift
//  NXMActionSheet_Example
//
//  Created by nExmond on 2018. 1. 12..
//  Copyright © 2018년 nExmond. All rights reserved.
//

import UIKit
import NXMActionSheet

class CustomActionSheet : NXMActionSheet, NXMActionSheetDelegate {
    
    convenience init (withType:NXMActionSheetAnimationType = .SLIDE) {
        self.init(frame: .zero)
        self.delegate = self
        self.animationType = withType
        
        //ImageView
        let imageView:CustomImageView = CustomImageView.loadUINibView()
        imageView.ImageView.image = #imageLiteral(resourceName: "image")
        let imageViewData = NXMActionSheetData(.CUSTOM(imageView))
        
        //TwoButton
        let twoButton:CustomTwoButtonView = CustomTwoButtonView.loadUINibView()
        twoButton.setLeftButton(withTitle: "Add") { /*[weak self]*/ button in
            //guard let strongSelf = self else { return }
            
        }
        twoButton.setRightButton(withTitle: "Remove") { /*[weak self]*/ button in
            //guard let strongSelf = self else { return }
            
        }
        let twoButtonData = NXMActionSheetData(.CUSTOM(twoButton))
        
        //OneButton
        let oneButton:CustomTwoButtonView = CustomTwoButtonView.loadUINibView()
        oneButton.setLeftButton(withTitle: "Close") { [weak self] button in
            guard let strongSelf = self else { return }
            strongSelf.close()
        }
        let oneButtonData = NXMActionSheetData(.CUSTOM(oneButton), withTouchClose:true)
        
        
        add(imageViewData)
        .add(twoButtonData)
        .end(oneButtonData)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func didSelectActionItem(_ actionSheet:NXMActionSheet, withData:NXMActionSheetData) {
        print("didSelectActionItem")
    }
    
    func actionSheetWillShow() {
        print("actionSheetWillShow")
    }
    
    func actionSheetDidShow() {
        print("actionSheetDidShow")
    }
    
    func actionSheetWillHide() {
        print("actionSheetWillHide")
    }
    
    func actionSheetDidHide() {
        print("actionSheetDidHide")
    }
    
    func actionSheetWillUpdate() {
        print("actionSheetWillUpdate")
    }
    
    func actionSheetDidUpdate() {
        print("actionSheetDidUpdate")
    }
}

/*
extension CustomActionSheet : NXMActionSheetDelegate {
    
    func didSelectActionItem(_ actionSheet:NXMActionSheet, withData:NXMActionSheetData) {
        print("didSelectActionItem")
    }
    
    func actionSheetWillShow() {
        print("actionSheetWillShow")
    }
    
    func actionSheetDidShow() {
        print("actionSheetDidShow")
    }
    
    func actionSheetWillHide() {
        print("actionSheetWillHide")
    }
    
    func actionSheetDidHide() {
        print("actionSheetDidHide")
    }
    
    func actionSheetWillUpdate() {
        print("actionSheetWillUpdate")
    }
    
    func actionSheetDidUpdate() {
        print("actionSheetDidUpdate")
    }

}
*/
