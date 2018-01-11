//
//  NXMActionSheet.swift
//
//  Created by nExmond on 2017. 12. 11..
//  Copyright © 2017 nExmond. All rights reserved.
//

import UIKit

typealias NXMActionSheetCompletion = ()->Void

enum NXMActionSheetAnimationType {
    case FADE, SLIDE
}

enum NXMActionSheetItemUpdate {
    case INSERT([Int]), RELOAD([Int]), DELETE([Int])
}

enum NXMActionSheetScrollTo {
    case NONE, TOP, MIDDLE, BOTTOM
}

@objc protocol NXMActionSheetDelegate {
    @objc func didSelectActionItem(_ actionSheet:NXMActionSheet, withData:NXMActionSheetData)
    @objc optional func actionSheetWillShow()
    @objc optional func actionSheetDidShow()
    @objc optional func actionSheetWillHide()
    @objc optional func actionSheetDidHide()
    @objc optional func actionSheetWillUpdate()
    @objc optional func actionSheetDidUpdate()
}

public class NXMActionSheet : UIView, UITableViewDataSource, UITableViewDelegate {
    
    var delegate:NXMActionSheetDelegate?
    let reuseIdentifier = "NXMActionSheetItemCell"
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var actionSheetTableView: UITableView!
    @IBOutlet var actionSheetHeight: NSLayoutConstraint!
    @IBOutlet var actionSheetBottom: NSLayoutConstraint!
    
    var items:Array<NXMActionSheetData> = Array()
    
    var tableviewHeight:CGFloat = 0.0
    var view:UIView!
    
    private var itemList:Array<NXMActionSheetData> = Array() {
        willSet(newData) {
            self.itemList = newData
            
            //높이 계산
            let maxHeight = UIScreen.main.bounds.size.height - UIApplication.shared.statusBarFrame.height
            let contentHeight = newData.map{$0.height}.reduce(0.0,+)
            self.tableviewHeight = min(maxHeight, contentHeight)
            self.actionSheetHeight.constant = self.tableviewHeight
            
            //스크롤 여부
            self.actionSheetTableView.isScrollEnabled = (contentHeight > maxHeight)
            let alpha:CGFloat = newData.count > 0 ? 1.0 : 0.0
            
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
        }
    }
    var animationType:NXMActionSheetAnimationType = .SLIDE
    
    convenience init (delegate:NXMActionSheetDelegate?=nil, withType:NXMActionSheetAnimationType = .SLIDE) {
        self.init(frame:UIScreen.main.bounds)
        self.delegate = delegate
        self.animationType = withType
    }
    
    override init(frame: CGRect) {
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
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("")
    }
    
    
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
        
        if cell != nil {
            
            let cellContentView = cell!.contentView
            let innerView = sheetData.view!
            
            //autoResizing 적용
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
        
        //선택 색상이 지정되어 있으면 애니메이션
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
    
        
    func add(_ data:NXMActionSheetData) -> NXMActionSheet {
        items.append(data); return self
    }
    
    func end(_ data:NXMActionSheetData?){
        if data != nil {
            items.append(data!)
        }
    }

    func show(scrollTo:NXMActionSheetScrollTo = .NONE, inViewController:UIViewController? = nil) {
        
        delegate?.actionSheetWillShow?()
        let topNavigationController = topViewController(controller: inViewController)
        
        topNavigationController?.view.addSubview(self)
        self.layoutIfNeeded()
        
        self.update(nil, scrollTo: scrollTo) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.actionSheetDidShow?()
        }
    }
    
    func update(_ state:NXMActionSheetItemUpdate? = nil, scrollTo:NXMActionSheetScrollTo = .NONE, complete:NXMActionSheetCompletion? = nil) {
        
        delegate?.actionSheetWillUpdate?()
        
        itemList = items
        if state != nil {
            
            CATransaction.begin()
            CATransaction.setCompletionBlock { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.actionSheetDidUpdate?()
            }
            self.actionSheetTableView.beginUpdates()
            
            switch state! {
            case .INSERT(let inserts):
                self.actionSheetTableView.insertRows(at: inserts.map{IndexPath(row: $0, section: 0)}, with: .fade)
            case .RELOAD(let reloads):
                self.actionSheetTableView.reloadRows(at: reloads.map{IndexPath(row: $0, section: 0)}, with: .fade)
            case .DELETE(let deletes):
                self.actionSheetTableView.deleteRows(at: deletes.map{IndexPath(row: $0, section: 0)}, with: .fade)
            }
            
            self.actionSheetTableView.endUpdates()
            CATransaction.commit()
        }else{
            self.actionSheetTableView.reloadData()
        }
        
        if scrollTo != .NONE {
            
            let maxHeight = UIScreen.main.bounds.size.height - UIApplication.shared.statusBarFrame.height
            
            var y:CGFloat = 0.0
            
            if scrollTo == .TOP {
            }else if scrollTo == .MIDDLE {
                y = (getContentHeight() - maxHeight)*0.5
            }else if scrollTo == .BOTTOM {
                y = getContentHeight() - maxHeight
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                self.actionSheetTableView.contentOffset = CGPoint(x: 0, y: max(y,0))
            })
        }
}

    func close() {
        
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
    
    
    
    
    
    //태그로 셀 인덱스 찾기
    func searchByTag(_ tag:String) -> Int? {
        
        if let searchedData = itemList.filter({$0.tag==tag}).first {
            return itemList.index(of: searchedData)
        }
        return nil
    }
    
    //특정 셀 종류의 개수 세기
    func countKind<T:UIView>(of:T) -> Int {
        return itemList.filter{$0.view!.isKind(of: T.classForCoder())}.count
    }
    
    //컨텐츠 높이 계산
    func getContentHeight() -> CGFloat {
        return itemList.map{$0.height}.reduce(0.0,+)
    }
    
    
    
    
    //Utils
    
    //가장 상위 뷰컨트롤러 얻기
    func topViewController(controller: UIViewController?) -> UIViewController? {
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
