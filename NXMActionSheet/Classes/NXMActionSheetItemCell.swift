//
//  NXMActionSheetItemCell.swift
//
//  Created by nExmond on 2017. 12. 11..
//  Copyright © 2017년 nExmond. All rights reserved.
//

import UIKit

class NXMActionSheetItemCell : UITableViewCell {
    
    func bindingSheetData(_ data:NXMActionSheetData) {
        
        //컨텐트 뷰에 추가되었던 뷰를 제거
        let _ = contentView.subviews.map{$0.removeFromSuperview()}
        
        //설정된 뷰를 찾고 크기 조절하여 추가
        if let view = data.view {
            view.frame = bounds
            contentView.addSubview(view)
        }
        
        //셀 선택 색상
        selectionStyle = .none
        contentView.backgroundColor = .white
        
        //셀 크기에 맞춰서 자름
        clipsToBounds = true
    }
}
