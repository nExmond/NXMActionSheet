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
    
    convenience init (withType:NXMActionSheetAnimationType = .slide) {
        self.init(frame: .zero)
        
        delegate = self
        animationType = withType
        
        numberList.append(0)
        
        //ImageView
        let imageView = CustomImageView.loadView()
        imageView.imageView.image = #imageLiteral(resourceName: "image")
        let imageViewData = NXMActionSheetData(.custom(imageView))
        
        //LabelView
        for number in numberList {
            
            let strNumber = number.description
            let labelView = CustomLabelView.loadView()
            let className = CustomLabelView.description().components(separatedBy:".").last ?? ""
            labelView.label.text = "\(className) \(strNumber)"
            labelViewDataList.append(NXMActionSheetData(.custom(labelView), withTag:strNumber))
        }
        
        //TwoButton
        twoButton = CustomTwoButtonView.loadView()
        twoButton.setLeftButton(withTitle: "Add LabelView") { [weak self] button in
            self?.addLabel()
        }
        twoButton.setRightButton(withTitle: "Remove LabelView") { [weak self] button in
            self?.removeLabel()
        }
        let twoButtonData = NXMActionSheetData(.custom(twoButton))
        twoButton.visibleButton(left: true)
        
        //OneButton
        let oneButton = CustomTwoButtonView.loadView()
        oneButton.leftButtonBackgroundColor = .darkGray
        oneButton.setLeftButton(withTitle: "Close") { [weak self] button in
            self?.close()
        }
        let oneButtonData = NXMActionSheetData(.custom(oneButton))
        
        //add items
        add(imageViewData)
            .add(datas: labelViewDataList)
            .add(datas: twoButtonData, oneButtonData)
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
        
        let labelView:CustomLabelView = CustomLabelView.loadView()
        let className = CustomLabelView.description().components(separatedBy:".").last ?? ""
        labelView.label.text = "\(className) \(strNumber)"
        let labelViewData = NXMActionSheetData(.custom(labelView), withTag:strNumber)
        
        let insertIdx = getLastLableIdx() + 1
        
        labelViewDataList.append(labelViewData)
        
        insert(labelViewData, at: insertIdx)
        update(.insert([insertIdx]), scrollTo: .bottom)
        
        if numberList.count > 2 {
            twoButton.visibleButton(right: true)
        }else if numberList.count > 1 {
            twoButton.visibleButton(left: true, right: true)
        }
    }
    
    func removeLabel() {
        
        if numberList.count > 1 {
            numberList.removeLast()
            
            let idx = remove(data:labelViewDataList.removeLast())
            update(.delete([idx]), scrollTo: .bottom)
        }
        
        if numberList.count == 1 {
            twoButton.visibleButton(left: true)
        }else{
            twoButton.visibleButton(left: true, right: true)
        }
    }
    
    func getLastLableIdx() -> Int {
        guard labelViewDataList.count > 0 else { return -1 }
        return index(of: labelViewDataList.last!)!
    }
    
    
    func didSelectActionItem(_ actionSheet:NXMActionSheet, withData:NXMActionSheetData) {
        trace("custom", withData.typeDescription)
    }
    
    func actionSheetWillShow() {
        trace("custom")
    }
    
    func actionSheetDidShow() {
        trace("custom")
    }
    
    func actionSheetWillHide() {
        trace("custom")
    }
    
    func actionSheetDidHide() {
        trace("custom")
    }
    
    func actionSheetWillUpdate() {
        trace("custom")
    }
    
    func actionSheetDidUpdate() {
        trace("custom")
    }
}
