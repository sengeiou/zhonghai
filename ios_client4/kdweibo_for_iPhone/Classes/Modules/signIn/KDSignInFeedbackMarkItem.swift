//
//  KDSignInFeedbackMarkItem.swift
//  kdweibo
//
//  Created by 张培增 on 2017/3/22.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import UIKit

class KDSignInFeedbackMarkItem: UICollectionViewCell {
    
    var model: KDSignInFeedbackMarkItemModel? {
        didSet {
            if let model = model {
                self.markLabel.text = model.mark
            }
        }
    }
    
    var markLabel: UILabel = {
        $0.textAlignment = .center
        $0.textColor = FC2
        $0.font = FS5
        $0.isUserInteractionEnabled = false
        return $0
    }(UILabel())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = UIColor.white
        contentView.layer.cornerRadius = 14.0
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor(rgb: 0xD9E5EA).cgColor
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(markLabel)
        kd_setupVFL([
            "markLabel" : markLabel
            ], constraints: [
                "H:|-12-[markLabel]-12-|"
            ])
        markLabel.kd_setCenterY()
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.alpha = 0.5
            } else {
                self.alpha = 1.0
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
