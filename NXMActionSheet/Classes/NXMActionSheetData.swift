//
//  NXMActionSheetData.swift
//
//  Created by nExmond on 2017. 12. 11..
//  Copyright © 2017년 nExmond. All rights reserved.
//

import UIKit

enum NXMActionSheetItemType {
    case CUSTOM(UIView?)
    case LABEL(String?)
    case BUTTON(String?)
    case IMAGE(UIImage?)
    case TEXT_FIELD(String?)
    case SLIDER(Float)
    case ACTIVITY_INDICATOR(UIActivityIndicatorViewStyle)
    case PROGRESS(Float)
}

public class NXMActionSheetData: NSObject {
    
    private var _view: UIView?
    private var _height: CGFloat
    private var _classType: AnyObject.Type
    private var _usedCustomView: Bool = false
    var tag : String?
    var subData : Any?
    var touchClose:Bool = false
    var selectionColor:UIColor = .clear
    var currentIdx:Int?
    var horizontalMargin:CGFloat = 16.0
    var verticalMargin:CGFloat = 8.0
    
    var usedCustomView:Bool {
        get{
            return _usedCustomView
        }
    }
    
    var view : UIView? {
        get {
            return self._view
        }
    }
    
    var height : CGFloat {
        get {
            return self._height
        }
    }

    var classType: AnyClass {
        get{
            return self._classType
        }
    }
    
    
    init(_ type:NXMActionSheetItemType, withTag:String? = nil, withTouchClose:Bool = false) {
        
        var setView:UIView!
        let defaultRect = CGRect(x: 0, y: 0, width:  UIScreen.main.bounds.width, height: 50)
        
        var rectWithoutMargin = defaultRect
        rectWithoutMargin.origin.x = horizontalMargin
        rectWithoutMargin.size.width -= horizontalMargin*2
        
        switch type {
            
        case .CUSTOM(let view):
            if let v = view {
                setView = v
                horizontalMargin = 0.0
                verticalMargin = 0.0
                _usedCustomView = true
            }else{
                setView = UIView(frame: rectWithoutMargin)
                setView.backgroundColor = UIColor.white
            }
            
        case .LABEL(let text):
            let label = UILabel(frame: rectWithoutMargin)
            label.textColor = .black
            label.text = text
            setView = label
            
        case .BUTTON(let title):
            let button = UIButton(frame: rectWithoutMargin)
            button.setTitleColor(.black, for: .normal)
            button.setTitle(title, for: .normal)
            setView = button
            
        case .IMAGE(let image):
            let imageView = UIImageView(frame: rectWithoutMargin)
            imageView.frame.size.height = imageView.frame.size.width*0.85
            imageView.contentMode = .scaleAspectFill
            imageView.image = image
            setView = imageView
            
        case .TEXT_FIELD(let text):
            let textField = UITextView(frame: rectWithoutMargin)
            textField.textColor = .black
            textField.text = text
            setView = textField
            
        case .SLIDER(let value):
            let slider = UISlider(frame: rectWithoutMargin)
            slider.value = value
            setView = slider
            
        case .ACTIVITY_INDICATOR(let style):
            let indicator = UIActivityIndicatorView(frame: rectWithoutMargin)
            indicator.activityIndicatorViewStyle = style
            indicator.startAnimating()
            setView = indicator
            
        case .PROGRESS(let progress):
            let progressContainer = UIView(frame: rectWithoutMargin)
            let progressView = UIProgressView(frame: CGRect(x: 0.0, y: (rectWithoutMargin.height-2.0)/2, width: rectWithoutMargin.width, height: 2.0))
            progressView.progress = progress
            progressContainer.addSubview(progressView)
            setView = progressContainer
            
        }
        setView.isUserInteractionEnabled = true
        setView.backgroundColor = .clear
        
        _view = setView
        _height = setView.bounds.size.height
        tag = withTag
        
        _classType = setView.classForCoder
        
        touchClose = withTouchClose
        
        super.init()
    }

}
