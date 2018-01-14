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
    
    private var numberList = [Int]()
    private var labelViewDataList = [NXMActionSheetData]()
    private var twoButton:CustomTwoButtonView!
    
    convenience init (withType:NXMActionSheetAnimationType = .SLIDE) {
        self.init(frame: .zero)
        self.delegate = self
        self.animationType = withType
        
        numberList.append(1)
        
        //ImageView
        let imageView:CustomImageView = CustomImageView.loadUINibView()
        imageView.ImageView.image = #imageLiteral(resourceName: "image")
        let imageViewData = NXMActionSheetData(.CUSTOM(imageView))
        
        //LabelView
        for number in numberList {
            
            let strNumber = number.description
            let labelView:CustomLabelView = CustomLabelView.loadUINibView()
            let className = CustomLabelView.description().components(separatedBy:".").last ?? ""
            labelView.label.text = "\(className) \(strNumber)"
            labelViewDataList.append(NXMActionSheetData(.CUSTOM(labelView), withTag:strNumber))
        }
        
        //TwoButton
        twoButton = CustomTwoButtonView.loadUINibView() as! CustomTwoButtonView
        twoButton.setLeftButton(withTitle: "Add LabelView") { [weak self] button in
            guard let strongSelf = self else { return }
            
            strongSelf.addLabel()
        }
        twoButton.setRightButton(withTitle: "Remove LabelView") { [weak self] button in
            guard let strongSelf = self else { return }
            strongSelf.removeLabel()
        }
        let twoButtonData = NXMActionSheetData(.CUSTOM(twoButton))
        
        //OneButton
        let oneButton:CustomTwoButtonView = CustomTwoButtonView.loadUINibView()
        oneButton.leftButtonBackgroundColor = .darkGray
        oneButton.setLeftButton(withTitle: "Close") { [weak self] button in
            guard let strongSelf = self else { return }
            strongSelf.close()
        }
        let oneButtonData = NXMActionSheetData(.CUSTOM(oneButton))
        
        //add items
        add(imageViewData)
        .add(datas: labelViewDataList)
        .add(twoButtonData)
        .end(oneButtonData)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func addLabel() {
        
        let number = numberList.count
        let strNumber = number.description
        
        numberList.append(number)
        
        let labelView:CustomLabelView = CustomLabelView.loadUINibView()
        let className = CustomLabelView.description().components(separatedBy:".").last ?? ""
        labelView.label.text = "\(className) \(strNumber)"
        let labelViewData = NXMActionSheetData(.CUSTOM(labelView), withTag:strNumber)
        
        let insertIdx = getLastLableIdx() + 1
        
        labelViewDataList.append(labelViewData)
        
        insert(labelViewData, at: insertIdx).end()
        update(.INSERT([insertIdx]), scrollTo: .BOTTOM)
        
        if numberList.count > 1 {
            twoButton.visibleRightButton(visible: true)
        }
    }
    
    func removeLabel() {
        
        if numberList.count > 1 {
            numberList.removeLast()
            
            let idx = remove(data:labelViewDataList.removeLast())
            update(.DELETE([idx]), scrollTo: .BOTTOM)
        }
        
        if numberList.count == 1 {
            twoButton.visibleRightButton(visible: false)
        }
    }
    
    func getLastLableIdx() -> Int {
        guard labelViewDataList.count > 0 else { return -1 }
        return items.index(of: labelViewDataList.last!)!
    }
    
    
    func didSelectActionItem(_ actionSheet:NXMActionSheet, withData:NXMActionSheetData) {
        print("CustomShow didSelectActionItem")
    }
    
    func actionSheetWillShow() {
        print("CustomShow actionSheetWillShow")
    }
    
    func actionSheetDidShow() {
        print("CustomShow actionSheetDidShow")
    }
    
    func actionSheetWillHide() {
        print("CustomShow actionSheetWillHide")
    }
    
    func actionSheetDidHide() {
        print("CustomShow actionSheetDidHide")
    }
    
    func actionSheetWillUpdate() {
        print("CustomShow actionSheetWillUpdate")
    }
    
    func actionSheetDidUpdate() {
        print("CustomShow actionSheetDidUpdate")
    }
}


/*
extension CustomActionSheet : NXMActionSheetDelegate {
    
    func didSelectActionItem(_ actionSheet:NXMActionSheet, withData:NXMActionSheetData) {
        print("CustomShow didSelectActionItem")
    }
    
    func actionSheetWillShow() {
        print("CustomShow actionSheetWillShow")
    }
    
    func actionSheetDidShow() {
        print("CustomShow actionSheetDidShow")
    }
    
    func actionSheetWillHide() {
        print("CustomShow actionSheetWillHide")
    }
    
    func actionSheetDidHide() {
        print("CustomShow actionSheetDidHide")
    }
    
    func actionSheetWillUpdate() {
        print("CustomShow actionSheetWillUpdate")
    }
    
    func actionSheetDidUpdate() {
        print("CustomShow actionSheetDidUpdate")
    }
}
*/
