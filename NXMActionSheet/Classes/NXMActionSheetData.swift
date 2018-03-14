//
//  NXMActionSheetData.swift
//
//  Created by nExmond on 2017. 12. 11..
//  Copyright © 2017년 nExmond. All rights reserved.
//

import UIKit

public typealias NXMControlAction = (_ sener:UIView) -> Void

public enum NXMActionSheetItemType {
    case CUSTOM(UIView?)
    case LABEL(String?)
    case BUTTON(String?,UIColor?,NXMControlAction?)
    case IMAGE(UIImage?)
    case TEXT_FIELD(String?,UITextFieldDelegate?)
    case SLIDER(Float,NXMControlAction?)
    case ACTIVITY_INDICATOR(UIActivityIndicatorViewStyle)
}

open class NXMActionSheetData: NSObject {
    
    private var _view: UIView?
    private var _height: CGFloat = 50.0
    private var _classType: AnyObject.Type = NSObject.self
    private var _usingMargin: Bool = true
    private var _action: NXMControlAction?
    open var tag : String?
    open weak var subData : AnyObject?
    open var touchClose:Bool = false
    open var selectionColor:UIColor = .clear
    open var currentIdx:Int?
    open var horizontalMargin:CGFloat = 16.0
    open var verticalMargin:CGFloat = 8.0
    
    open var usingMargin:Bool {
        set{
            _usingMargin = newValue
            if newValue==false {
                horizontalMargin = 0.0
                verticalMargin = 0.0
            }
        }
        get{
            return _usingMargin
        }
    }
    
    open var usedCustomView:Bool {
        set{
            usingMargin = !newValue
        }
        get{
            return !usingMargin
        }
    }
    
    open var view : UIView? {
        get {
            return self._view
        }
    }
    
    open var height : CGFloat {
        get {
            return self._height
        }
    }

    open var classType: AnyClass {
        get{
            return self._classType
        }
    }
    
    
    public init(_ type:NXMActionSheetItemType, withTag:String? = nil, withTouchClose:Bool = false) {
        
        super.init()
        
        var setView:UIView!
        let defaultRect = CGRect(x: 0, y: 0, width:  UIScreen.main.bounds.width, height: 50)
        
        var rectWithoutMargin = defaultRect
        rectWithoutMargin.origin.x = horizontalMargin
        rectWithoutMargin.size.width -= horizontalMargin*2
        
        switch type {
            
        case .CUSTOM(let view):
            if let v = view {
                setView = v
                usedCustomView = true
            }else{
                setView = UIView(frame: rectWithoutMargin)
                setView.backgroundColor = UIColor.white
            }
            
        case .LABEL(let text):
            let label = UILabel(frame: rectWithoutMargin)
            label.textColor = .black
            label.text = text
            setView = label
            
        case .BUTTON(let title, let color, let action):
            let button = UIButton(frame: defaultRect)
            _action = action
            button.addTarget(self, action: #selector(controlAction(_:)), for: .touchUpInside)
            button.backgroundColor = color ?? .white
            button.setTitleColor(((color == nil||color == .white) ? .black : .white), for: .normal)
            button.setTitle(title, for: .normal)
            setView = button
            usingMargin = false
            
        case .IMAGE(let image):
            let imageView = UIImageView(frame: defaultRect)
            imageView.frame.size.height = imageView.frame.size.width*0.85
            imageView.contentMode = .scaleAspectFill
            imageView.image = image
            setView = imageView
            usingMargin = false
            
        case .TEXT_FIELD(let text, let delegate):
            let textField = UITextField(frame: rectWithoutMargin)
            textField.delegate = delegate
            textField.textColor = .black
            textField.text = text
            setView = textField
            
        case .SLIDER(let value, let action):
            let slider = UISlider(frame: rectWithoutMargin)
            _action = action
            slider.addTarget(self, action: #selector(controlAction(_:)), for: .valueChanged)
            slider.value = value
            setView = slider
            
        case .ACTIVITY_INDICATOR(let style):
            let indicator = UIActivityIndicatorView(frame: rectWithoutMargin)
            indicator.activityIndicatorViewStyle = style
            indicator.startAnimating()
            setView = indicator
            
        }
        setView.isUserInteractionEnabled = true
        if setView.backgroundColor == .white {
            setView.backgroundColor = .clear
        }
        
        _view = setView
        _height = setView.bounds.size.height
        tag = withTag
        
        _classType = setView.classForCoder
        
        touchClose = withTouchClose
        
    }
    
    @objc private func controlAction(_ sender: UIView) {
        _action?(sender)
    }
    
}
