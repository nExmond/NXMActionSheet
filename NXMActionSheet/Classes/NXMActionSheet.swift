//
//  NXMActionSheet.swift
//
//  Created by nExmond on 2017. 12. 11..
//  Copyright © 2017 nExmond. All rights reserved.
//

import UIKit

public typealias NXMActionSheetCompletion = ()->Void

public enum NXMActionSheetAnimationType {
    case FADE, SLIDE
}

public enum NXMActionSheetItemUpdate {
    case INSERT([Int]), RELOAD([Int]), DELETE([Int])
}

public enum NXMActionSheetScrollTo {
    case NONE, TOP, MIDDLE, BOTTOM
}

@objc public protocol NXMActionSheetDelegate {
    @objc func didSelectActionItem(_ actionSheet:NXMActionSheet, withData:NXMActionSheetData)
    @objc optional func actionSheetWillShow()
    @objc optional func actionSheetDidShow()
    @objc optional func actionSheetWillHide()
    @objc optional func actionSheetDidHide()
    @objc optional func actionSheetWillUpdate()
    @objc optional func actionSheetDidUpdate()
}

open class NXMActionSheet : UIView, UITableViewDataSource, UITableViewDelegate {
    
    public weak var delegate:NXMActionSheetDelegate?
    let reuseIdentifier = "NXMActionSheetItemCell"
    
    @IBOutlet public var backgroundView: UIView!
    @IBOutlet public var actionSheetTableView: UITableView!
    @IBOutlet public var actionSheetHeight: NSLayoutConstraint!
    @IBOutlet public var actionSheetBottom: NSLayoutConstraint!
    
    open var items = [NXMActionSheetData]()
    
    var tableviewHeight:CGFloat = 0.0
    var view:UIView!
    
    private var itemList = [NXMActionSheetData]() {
        willSet(newData) {
            let initial = (self.itemList.count == 0)
            
            self.itemList = newData
            
            let maxHeight = UIScreen.main.bounds.size.height - UIApplication.shared.statusBarFrame.height
            let contentHeight = newData.map{$0.height}.reduce(0.0,+)
            self.tableviewHeight = min(maxHeight, contentHeight)
            self.actionSheetHeight.constant = self.tableviewHeight
            
            
            self.actionSheetTableView.isScrollEnabled = (contentHeight > maxHeight)
            let alpha:CGFloat = newData.count > 0 ? 1.0 : 0.0
            
            if initial {
                if animationType == .SLIDE {
                    self.alpha = 1.0
                    UIView.animate(withDuration: 0.3, animations: {
                        self.backgroundView.alpha = alpha
                        self.layoutIfNeeded()
                    })
                }else{
                    self.backgroundView.alpha = alpha
                    self.layoutIfNeeded()
                    UIView.animate(withDuration: 0.3, animations: {
                        self.alpha = alpha
                    })
                }
            }else{
                UIView.animate(withDuration: 0.3, animations: {
                    self.layoutIfNeeded()
                })
            }
        }
    }
    public var animationType:NXMActionSheetAnimationType = .SLIDE
    
    //MARK: - Initialize -
    
    public convenience init (delegate:NXMActionSheetDelegate?=nil, withType:NXMActionSheetAnimationType = .SLIDE) {
        self.init(frame:UIScreen.main.bounds)
        self.delegate = delegate
        self.animationType = withType
    }
    
    public override init(frame: CGRect) {
        super.init(frame: (frame == .zero ? UIScreen.main.bounds : frame))
        loadXib()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
    }
    
    func loadXib() {
        
        view = UINib(
            nibName: "NXMActionSheet",
            bundle: Bundle(for: NXMActionSheet.self))
            .instantiate(
                withOwner: self,
                options: nil)[0] as! UIView
        
        view.frame = UIScreen.main.bounds
        view.backgroundColor = .clear
        
        actionSheetTableView.backgroundColor = .white
        actionSheetTableView.register(NXMActionSheetItemCell.self, forCellReuseIdentifier: reuseIdentifier)
        actionSheetTableView.setDropShadow()
        
        addSubview(view)
        
        registTapGesture()
        
        self.alpha = 0.0
    }
    
    private func registTapGesture() {
        backgroundView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        backgroundView.addGestureRecognizer(tap)
    }
    @objc private func tapAction(_ sender: UITapGestureRecognizer? = nil) {
        close()
    }
    
    //MARK: - TableView functions -
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return itemList[indexPath.row].height
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? NXMActionSheetItemCell
        
        let sheetData = itemList[indexPath.row]
        cell?.bindingSheetData(sheetData)
        
        if sheetData.touchClose {
            if let button = sheetData.view as? UIButton {
                if button.allTargets.count < 2 {
                    button.addTarget(self, action: #selector(tapAction(_:)), for: .touchUpInside)
                }
            }
        }
        
        if cell != nil {
            
            let cellContentView = cell!.contentView
            let innerView = sheetData.view!
            
            
            innerView.translatesAutoresizingMaskIntoConstraints = false
            if #available(iOS 9.0, *) {
                NSLayoutConstraint.activate([innerView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: sheetData.horizontalMargin),
                                             innerView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -sheetData.horizontalMargin),
                                             innerView.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: sheetData.verticalMargin),
                                             innerView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -sheetData.verticalMargin)])
            } else {
                // Fallback on earlier versions
            }
        }
        
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = itemList[indexPath.row]
        data.currentIdx = indexPath.row
        
        
        if data.selectionColor != .clear {
            if let cell = tableView.cellForRow(at: indexPath) as? NXMActionSheetItemCell {
                
                cell.contentView.backgroundColor = data.selectionColor
                
                UIView.transition(
                    with: cell,
                    duration: 0.25,
                    options: .transitionCrossDissolve,
                    animations: {
                        cell.contentView.backgroundColor = .clear
                })
            }
        }
        
        delegate?.didSelectActionItem(self, withData: data)
        
        if data.touchClose==true {
            close()
        }
    }
    
    
    //MARK: - Items Add or AddingEnd -
        
    @discardableResult public func add(_ data:NXMActionSheetData) -> NXMActionSheet {
        items.append(data)
        return self
    }
    @discardableResult public func add(datas:[NXMActionSheetData]) -> NXMActionSheet {
        items.append(contentsOf: datas)
        return self
    }
    @discardableResult public func add(datas:NXMActionSheetData...) -> NXMActionSheet {
        return add(datas: datas)
    }
    
    @discardableResult public func insert(_ data:NXMActionSheetData, at:Int) -> NXMActionSheet {
        items.insert(data, at: at)
        return self
    }
    @discardableResult public func insert(datas:[NXMActionSheetData], at:Int) -> NXMActionSheet {
        items.insert(contentsOf: datas, at: at)
        return self
    }
    @discardableResult public func insert(datas:NXMActionSheetData..., at:Int) -> NXMActionSheet {
        return insert(datas: datas, at: at)
    }
    
    @discardableResult public func remove(data:NXMActionSheetData) -> Int {
        if let idx = items.index(of: data) {
            remove(at: idx)
            return idx
        }
        return -1
    }
    
    public func remove(at:Int) {
        items.remove(at: at)
    }
    
    
    //MARK: - Show / Update / Close -

    open func show(scrollTo:NXMActionSheetScrollTo = .NONE, inViewController:UIViewController? = nil) {
        
        delegate?.actionSheetWillShow?()
        let topNavigationController = UIViewController.topViewController(controller: inViewController)
        
        topNavigationController?.view.addSubview(self)
        self.layoutIfNeeded()
        
        self.update(nil, scrollTo: scrollTo) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.actionSheetDidShow?()
        }
    }
    
    open func update(_ state:NXMActionSheetItemUpdate? = nil, scrollTo:NXMActionSheetScrollTo = .NONE, complete:NXMActionSheetCompletion? = nil) {
        
        delegate?.actionSheetWillUpdate?()
        
        var items = [NXMActionSheetData]()
        items.append(contentsOf: self.items)
        
        // iPhoneX correct bottom
        if UIDevice.isiPhoneX {
            let bottomGapView:UIView = {
                let view = UIView()
                view.bounds.size.height = UIWindow.bottomPadding
                view.backgroundColor = .clear
                return view
            }()
            let bottomGapData = NXMActionSheetData(.CUSTOM(bottomGapView))
            items.append(bottomGapData)
        }
        
        itemList = items
        
        var updateIdx:Int?
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.actionSheetDidUpdate?()
            complete?()
        }
        if state != nil {
            
            self.actionSheetTableView.beginUpdates()
            
            switch state! {
            case .INSERT(let inserts):
                updateIdx = inserts.first
                self.actionSheetTableView.insertRows(at: inserts.map{IndexPath(row: $0, section: 0)}, with: .fade)
            case .RELOAD(let reloads):
                updateIdx = reloads.first
                self.actionSheetTableView.reloadRows(at: reloads.map{IndexPath(row: $0, section: 0)}, with: .fade)
            case .DELETE(let deletes):
                updateIdx = deletes.first
                self.actionSheetTableView.deleteRows(at: deletes.map{IndexPath(row: $0, section: 0)}, with: .fade)
            }
            
            self.actionSheetTableView.endUpdates()
        }else{
            self.actionSheetTableView.reloadData()
        }
        CATransaction.commit()
        
        if scrollTo != .NONE {
            
            if let idx = updateIdx {
                
                var indexPath = IndexPath(row: 0, section: 0)
                var position:UITableViewScrollPosition = .top
                
                if scrollTo == .TOP {
                }else if scrollTo == .MIDDLE {
                    position = .middle
                    indexPath.row = idx
                }else if scrollTo == .BOTTOM {
                    position = .bottom
                    indexPath.row = itemList.count-1
                }
                
                self.actionSheetTableView.scrollToRow(at: indexPath, at: position, animated: true)
            }
        }
    }
    
    open func close() {
        
        delegate?.actionSheetWillHide?()
        
        if animationType == .SLIDE {
            let maxHeight = UIScreen.main.bounds.size.height - UIApplication.shared.statusBarFrame.height
            let contentHeight = getContentHeight()
            if maxHeight < contentHeight {
                actionSheetBottom.constant = maxHeight - contentHeight
            }else{
                actionSheetBottom.constant = 0.0
            }
            actionSheetHeight.constant = 0.0
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            if self.animationType == .SLIDE {
                self.layoutIfNeeded()
                self.backgroundView.alpha = 0.0
            }else{
                self.alpha = 0.0
            }
        }, completion: { [weak self] (complection) -> Void in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.actionSheetDidHide?()
            strongSelf.removeFromSuperview()
        })
    }
    
    
    //MARK: - Utils -
    
    public func searchByTag(_ tag:String) -> Int? {
        
        if let searchedData = itemList.filter({$0.tag==tag}).first {
            return itemList.index(of: searchedData)
        }
        return nil
    }
    
    public func countKind<T:UIView>(of:T) -> Int {
        return itemList.filter{$0.view!.isKind(of: T.classForCoder())}.count
    }
    
    public func getContentHeight() -> CGFloat {
        return itemList.map{$0.height}.reduce(0.0,+)
    }
    
}

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

extension UIViewController {
    
    fileprivate class func topViewController(controller: UIViewController?) -> UIViewController? {
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

extension UIView {
    
    public class var nibName: String {
        let name = "\(self)".components(separatedBy: ".").first ?? ""
        return name
    }
    
    public class func loadUINibView<T:UIView>() -> T {
        return UINib(nibName: nibName, bundle: Bundle(for: self)).instantiate(withOwner: self, options: nil)[0] as! T
    }
    
    public class func loadUINib() -> UINib {
        return UINib(nibName: nibName, bundle: Bundle(for: self))
    }
    
    public func setDropShadow(offset:CGSize = CGSize.zero, withColor:UIColor = UIColor.black, withAlpha:Float = 0.125, withRadius:CGFloat = 8.0, toDraw: UIView? = nil) {
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

extension UIWindow {
    
    public class var bottomPadding : CGFloat {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
        } else {
            return 0.0
        }
    }
}

postfix operator |
extension Array {
    static postfix func | (end: Array) { }
}

