//
//  NXMActionSheetItemCell.swift
//
//  Created by nExmond on 2018. 7. 13..
//  Copyright © 2017년 nExmond. All rights reserved.
//

import Foundation

//MARK: - Extensions -

extension UIDevice {
    
    static var isiPhoneX:Bool {
        
        var identifire:String!
        if isSmulator {
            identifire = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? ""
        }else{
            identifire = {
                var size:Int = 0
                sysctlbyname("hw.machine", nil, &size, nil, 0)
                var machine = [CChar](repeating: 0, count: size)
                sysctlbyname("hw.machine", &machine, &size, nil, 0)
                
                return String(cString: machine, encoding:String.Encoding.utf8)!
            }()
        }
        return (identifire == "iPhone10,3"
            || identifire == "iPhone10,6")
    }
    
    static var isSmulator:Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}

/////////////////////////////////////////////////////////////////

extension UIViewController {
    
    static func topViewController(controller: UIViewController?) -> UIViewController? {
        var viewController = controller
        if viewController == nil {
            viewController = UIApplication.shared.keyWindow?.rootViewController
        }
        if let navigationController = viewController as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = viewController as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(controller: presented)
        }
        return viewController
    }
}

/////////////////////////////////////////////////////////////////

extension UIView {
    
    func setDropShadow(offset:CGSize = CGSize.zero, withColor:UIColor = UIColor.black, withAlpha:Float = 0.125, withRadius:CGFloat = 8.0, toDraw: UIView? = nil) {
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            
            let window = UIApplication.shared.keyWindow!
            
            let backgroundView = toDraw ?? strongSelf.superview!
            var shadowRect = strongSelf.convert(strongSelf.bounds, to: window)
            shadowRect = window.convert(shadowRect, to: backgroundView)
            
            let shadowPath = UIBezierPath(roundedRect: shadowRect, cornerRadius: withRadius)
            
            backgroundView.layer.shadowColor = withColor.cgColor
            backgroundView.layer.shadowOffset = offset
            backgroundView.layer.shadowOpacity = withAlpha
            backgroundView.layer.shadowPath = shadowPath.cgPath
            backgroundView.layoutIfNeeded()
        }
    }
}

/////////////////////////////////////////////////////////////////

protocol NXMUIViewLoadProtocol {
    
    associatedtype View
    
    static var Nib:UINib { get }
    static func loadView() -> View
}

extension NXMUIViewLoadProtocol {
    
    public static func loadView() -> Self {
        return Nib.instantiate(withOwner: Self.self, options: nil)[0] as! Self
    }
}

extension UIView : NXMUIViewLoadProtocol {
    
    public static var Nib: UINib {
        let fileName = description().components(separatedBy: ".").last!
        return UINib(nibName: fileName, bundle: Bundle(for: self))
    }
}

/////////////////////////////////////////////////////////////////

extension UIWindow {
    
    static var bottomPadding : CGFloat {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
        } else {
            return 0.0
        }
    }
}

/////////////////////////////////////////////////////////////////

typealias NXMUIControlTargetClosure = (UIControl) -> ()

class ClosureWrapper: NSObject {
    let closure: NXMUIControlTargetClosure
    init(_ closure: @escaping NXMUIControlTargetClosure) {
        self.closure = closure
    }
}

extension UIControl {
    
    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }
    
    private var targetClosure: NXMUIControlTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? ClosureWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, ClosureWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addTargetClosure(closure: @escaping NXMUIControlTargetClosure) {
        targetClosure = closure
        addTarget(self, action: #selector(closureAction), for: .touchUpInside)
    }
    
    @objc
    func closureAction() {
        targetClosure?(self)
    }
}
