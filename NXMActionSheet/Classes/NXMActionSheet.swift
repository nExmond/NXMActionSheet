//
//  NXMActionSheet.swift
//
//  Created by nExmond on 2017. 12. 11..
//  Copyright © 2017 nExmond. All rights reserved.
//

import UIKit

public typealias NXMActionSheetCompletion = ()->Void

public enum NXMActionSheetAnimationType {
    case fade, slide
}

public enum NXMActionSheetItemUpdate {
    case insert([Int]), update([Int]), delete([Int])
}

public enum NXMActionSheetScrollTo {
    case none, top, middle, bottom
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
    public var animationType:NXMActionSheetAnimationType = .slide
    
    private let reuseIdentifier = "NXMActionSheetItemCell"
    
    @IBOutlet private var backgroundView: UIView!
    @IBOutlet private var actionSheetTableView: UITableView!
    @IBOutlet private var actionSheetHeight: NSLayoutConstraint!
    @IBOutlet private var actionSheetBottom: NSLayoutConstraint!
    
    private var tableviewHeight:CGFloat = 0.0
    private var view:UIView!
    
    private var items = [NXMActionSheetData]()

    private var itemList = [NXMActionSheetData]() {
        willSet {
            
            let maxHeight = UIScreen.main.bounds.size.height - UIApplication.shared.statusBarFrame.height
            let contentHeight = newValue.map{$0.height}.reduce(0.0,+)
            
            tableviewHeight = min(maxHeight, contentHeight)
            actionSheetHeight.constant = tableviewHeight
            
            actionSheetTableView.isScrollEnabled = (contentHeight > maxHeight)
            
            let initial = (itemList.count == 0)
            let alpha:CGFloat = (newValue.count > 0 ? 1.0 : 0.0)
            
            if initial {
                if animationType == .slide {
                    self.alpha = 1.0
                    UIView.animate(withDuration: 0.3, animations: {
                        self.backgroundView.alpha = alpha
                        self.layoutIfNeeded()
                    }, completion: { [weak self] success in
                        self?.delegate?.actionSheetDidShow?()
                    })
                }else{
                    backgroundView.alpha = alpha
                    layoutIfNeeded()
                    UIView.animate(withDuration: 0.3, animations: {
                        self.alpha = alpha
                    }, completion: { [weak self] success in
                        self?.delegate?.actionSheetDidShow?()
                    })
                }
            }else{
                UIView.animate(withDuration: 0.3, animations: {
                    self.layoutIfNeeded()
                }, completion: { [weak self] success in
                    self?.delegate?.actionSheetDidUpdate?()
                })
            }
        }
    }
    
    //MARK: - Initialize -
    
    public override init(frame: CGRect) {
        super.init(frame: (frame == .zero ? UIScreen.main.bounds : frame))
        loadXib()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
    }
    
    public required convenience init(delegate:NXMActionSheetDelegate?=nil,
                                     type:NXMActionSheetAnimationType = .slide) {
        self.init(frame: .zero)
        
        self.delegate = delegate
        self.animationType = type
    }
    
    private func loadXib() {
        
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
        
        alpha = 0.0
    }
    
    private func registTapGesture() {
        backgroundView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        backgroundView.addGestureRecognizer(tap)
    }
    
    @objc
    private func tapAction(_ sender: UITapGestureRecognizer? = nil) {
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
        
        let sheetData = itemList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! NXMActionSheetItemCell
        cell.bind(sheetData)
        
        let cellContentView = cell.contentView
        let innerView = sheetData.view!
        
        if #available(iOS 9.0, *) {
            innerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate(
                [innerView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: sheetData.horizontalMargin),
                innerView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -sheetData.horizontalMargin),
                innerView.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: sheetData.verticalMargin),
                innerView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -sheetData.verticalMargin)]
            )
        } else {
            // Fallback on earlier versions
        }
        
        return cell
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
        
        if data.touchClose {
            close()
        }
    }
    
    
    //MARK: - Items Add or AddingEnd -
    
    @discardableResult
    public func add(_ data:NXMActionSheetData) -> NXMActionSheet {
        setClose(data)
        items.append(data)
        return self
    }
    
    @discardableResult
    public func add(datas:[NXMActionSheetData]) -> NXMActionSheet {
        datas.forEach{setClose($0)}
        items.append(contentsOf: datas)
        return self
    }
    
    @discardableResult
    public func add(datas:NXMActionSheetData...) -> NXMActionSheet {
        return add(datas: datas)
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    
    @discardableResult
    public func insert(_ data:NXMActionSheetData, at:Int) -> NXMActionSheet {
        setClose(data)
        items.insert(data, at: at)
        return self
    }
    
    @discardableResult
    public func insert(datas:[NXMActionSheetData], at:Int) -> NXMActionSheet {
        datas.forEach{setClose($0)}
        items.insert(contentsOf: datas, at: at)
        return self
    }
    
    @discardableResult
    public func insert(datas:NXMActionSheetData..., at:Int) -> NXMActionSheet {
        return insert(datas: datas, at: at)
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    
    @discardableResult
    public func remove(data:NXMActionSheetData) -> Int {
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

    open func show(scrollTo:NXMActionSheetScrollTo = .none, inViewController:UIViewController? = nil) {
        
        delegate?.actionSheetWillShow?()
        let topNavigationController = UIViewController.topViewController(controller: inViewController)
        
        topNavigationController?.view.addSubview(self)
        layoutIfNeeded()
        
        update(show:true, scrollTo: scrollTo)
    }
    
    open func update(show:Bool = false, _ state:NXMActionSheetItemUpdate? = nil, scrollTo:NXMActionSheetScrollTo = .none, complete:NXMActionSheetCompletion? = nil) {
        
        if !show { delegate?.actionSheetWillUpdate?() }
        
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
            let bottomGapData = NXMActionSheetData(.custom(bottomGapView))
            items.append(bottomGapData)
        }
        
        itemList = items
        
        var updateIdx:Int?
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(complete)
        
        if state != nil {
            
            actionSheetTableView.beginUpdates()
            
            switch state! {
            case .insert(let inserts):
                updateIdx = inserts.first
                self.actionSheetTableView.insertRows(at: inserts.map{IndexPath(row: $0, section: 0)}, with: .fade)
            case .update(let reloads):
                updateIdx = reloads.first
                self.actionSheetTableView.reloadRows(at: reloads.map{IndexPath(row: $0, section: 0)}, with: .fade)
            case .delete(let deletes):
                updateIdx = deletes.first
                self.actionSheetTableView.deleteRows(at: deletes.map{IndexPath(row: $0, section: 0)}, with: .fade)
            }
            
            self.actionSheetTableView.endUpdates()
        }else{
            self.actionSheetTableView.reloadData()
        }
        
        if scrollTo != .none {
            
            if let idx = updateIdx {
                
                var indexPath = IndexPath(row: 0, section: 0)
                var position:UITableViewScrollPosition = .top
                
                if scrollTo == .top {
                }else if scrollTo == .middle {
                    position = .middle
                    indexPath.row = idx
                }else if scrollTo == .bottom {
                    position = .bottom
                    indexPath.row = itemList.count-1
                }
                
                actionSheetTableView.scrollToRow(at: indexPath, at: position, animated: true)
            }
        }
        
        CATransaction.commit()
    }
    
    open func close() {
        
        delegate?.actionSheetWillHide?()
        
        if animationType == .slide {
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
            if self.animationType == .slide {
                self.layoutIfNeeded()
                self.backgroundView.alpha = 0.0
            }else{
                self.alpha = 0.0
            }
        }, completion: { [weak self] _ in
            self?.delegate?.actionSheetDidHide?()
            self?.removeFromSuperview()
        })
    }
    
    private func setClose(_ data:NXMActionSheetData) {
        data.setClose { [weak self] in
            self?.close()
        }
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
    
    public func index(of data:NXMActionSheetData) -> Int? {
        return items.index(of: data)
    }
}
