//
//  NXMActionSheetItemCell.swift
//
//  Created by nExmond on 2017. 12. 11..
//  Copyright © 2017년 nExmond. All rights reserved.
//

import UIKit

class NXMActionSheetItemCell : UITableViewCell {
    
    func bind(_ data:NXMActionSheetData) {
        
        contentView.subviews.forEach{$0.removeFromSuperview()}
        
        if let view = data.view {
            view.frame = bounds
            contentView.addSubview(view)
        }
        
        selectionStyle = .none
        contentView.backgroundColor = .white
        
        clipsToBounds = true
    }
}
