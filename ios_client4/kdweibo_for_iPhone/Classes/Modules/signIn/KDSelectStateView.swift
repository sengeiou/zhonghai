//
//  KDSelectStateView.swift
//  kdweibo
//
//  Created by 张培增 on 2017/4/11.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import UIKit

final class KDSelectStateView: UIView {
    
    var selected: Bool = false {
        didSet {
            if selected {
                selectStateImageView.image = UIImage(named: "task_editor_finish")
            }
            else {
                selectStateImageView.image = UIImage(named: "task_editor_select")
            }
        }
    }
    
    fileprivate lazy var selectStateImageView: UIImageView = {
        $0.isUserInteractionEnabled = true
        return $0
    }(UIImageView())

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(selectStateImageView)
        kd_setupVFL([
            "selectStateImageView" : selectStateImageView
            ], constraints: [
                "H:[selectStateImageView(18)]",
                "V:[selectStateImageView(18)]"
            ])
        selectStateImageView.kd_setCenterX()
        selectStateImageView.kd_setCenterY()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        selectStateImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func tap(_ sender: UITapGestureRecognizer) {
        if let didTapped = didTapped {
            didTapped()
        }
    }
    
    var didTapped: (() -> ())? = nil

}
