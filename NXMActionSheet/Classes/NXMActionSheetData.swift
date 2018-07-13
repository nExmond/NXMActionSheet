//
//  NXMActionSheetData.swift
//
//  Created by nExmond on 2017. 12. 11..
//  Copyright © 2017년 nExmond. All rights reserved.
//

import UIKit

public typealias NXMControlAction = (_ sener:UIView) -> Void

public enum NXMActionSheetItemType {
    
    case custom(UIView?)
    case label(String?)
    case button(String?,UIColor?,NXMControlAction?)
    case image(UIImage?)
    case textField(String?,UITextFieldDelegate?)
    case slider(Float,NXMControlAction?)
    case activityIndicator(UIActivityIndicatorViewStyle)
    
    var description: String {
        switch self {
        case .custom(let view): return "custom: \(view?.description ?? "nil")"
        case .label(let text): return "label: \(text ?? "nil")"
        case .button(let title, _, _): return "button: \(title ?? "nil")"
        case .image(let image): return "image: \(image?.description ?? "nil")"
        case .textField(let text, _): return "textField: \(text ?? "nil")"
        case .slider(let value, _): return "slider: \(value)"
        case .activityIndicator(let style): return "activityIndicator: \(style)"
        }
    }
}

open class NXMActionSheetData: NSObject {
    
    private(set) var type: NXMActionSheetItemType!
    
    private(set) var view: UIView!
    private(set) var height: CGFloat = 50.0
    
    private(set) var close: (()->Void)?
    
    open var tag : String?
    open var subData : Any?
    open var currentIdx: Int?
    
    open var touchClose: Bool = false
    open var selectionColor: UIColor = .clear
    
    open var horizontalMargin: CGFloat = 16.0
    open var verticalMargin: CGFloat = 8.0
    
    open var usingMargin: Bool = true {
        didSet{
            if !usingMargin {
                horizontalMargin = 0.0
                verticalMargin = 0.0
            }
        }
    }
    
    open var usedCustomView: Bool {
        set{
            usingMargin = !newValue
        }
        get{
            return !usingMargin
        }
    }
    
    open var typeDescription: String {
        return type.description
    }
    
    public init(_ type:NXMActionSheetItemType, withTag:String? = nil, withTouchClose:Bool = false) {
        super.init()
        
        self.type = type
        
        view = loadView(type)
        height = view.bounds.size.height
        
        view.isUserInteractionEnabled = true
        if view.backgroundColor == .white {
            view.backgroundColor = .clear
        }
        
        tag = withTag
        touchClose = withTouchClose
    }
    
    public func setClose(closure:@escaping ()->Void) {
        guard touchClose else { return }
        close = closure
    }
    
    func loadView(_ type:NXMActionSheetItemType) -> UIView {
        
        let defaultRect = CGRect(x: 0, y: 0, width:  UIScreen.main.bounds.width, height: 50)
        
        var rectWithoutMargin = defaultRect
        rectWithoutMargin.origin.x = horizontalMargin
        rectWithoutMargin.size.width -= horizontalMargin*2
        
        switch type {
        case .custom(let view):
            if let view = view {
                usedCustomView = true
                return view
            }else{
                let view = UIView(frame: rectWithoutMargin)
                view.backgroundColor = UIColor.white
                return view
            }
        case .label(let text):
            let label = UILabel(frame: rectWithoutMargin)
            label.textColor = .black
            label.text = text
            return label
            
        case .button(let title, let color, let action):
            let button = UIButton(frame: defaultRect)
            button.addTargetClosure(closure: { [weak self] control in
                action?(control)
                self?.close?()
            })
            button.backgroundColor = color ?? .white
            button.setTitleColor(((color == nil||color == .white) ? .black : .white), for: .normal)
            button.setTitle(title, for: .normal)
            usingMargin = false
            
            return button
            
        case .image(let image):
            let imageView = UIImageView(frame: defaultRect)
            imageView.frame.size.height = imageView.frame.size.width*0.85
            imageView.contentMode = .scaleAspectFill
            imageView.image = image
            usingMargin = false
            
            return imageView
            
        case .textField(let text, let delegate):
            let textField = UITextField(frame: rectWithoutMargin)
            textField.delegate = delegate
            textField.textColor = .black
            textField.text = text
            
            return textField
            
        case .slider(let value, let action):
            let slider = UISlider(frame: rectWithoutMargin)
            slider.addTargetClosure(closure: { [weak self] control in
                action?(control)
                self?.close?()
            })
            slider.value = value
            
            return slider
            
        case .activityIndicator(let style):
            let indicator = UIActivityIndicatorView(frame: rectWithoutMargin)
            indicator.activityIndicatorViewStyle = style
            indicator.startAnimating()
            
            return indicator
        }
    }
}
