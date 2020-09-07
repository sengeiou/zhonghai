//
//  KDSignInGroupCornerView.swift
//  kdweibo
//
//  Created by 张培增 on 2017/3/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import UIKit

final class KDSignInGroupCornerView: UIView {
    
    // MARK: 是否排班制
    var isShift: Bool = false {
        didSet {
            if isShift == true {
                self.textLabel.text = "排班制"
                self.backgroundColor = UIColor(rgb: 0x31D2EA)
            }
            else {
                self.textLabel.text = "固定班制"
                self.backgroundColor = FC5
            }
        }
    }
    
    lazy var textLabel: UILabel = {
        $0.textColor = FC6
        $0.font = FS8
        $0.textAlignment = .center
        return $0
    }(UILabel())

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textLabel)
        kd_setupVFL([
            "textLabel" : textLabel
            ], constraints: [
                "H:|[textLabel]|"
            ])
        textLabel.kd_setCenterY()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .bottomLeft, cornerRadii: CGSize(width: 9, height: 9))
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = rect
        shapeLayer.path = path.cgPath
        layer.mask = shapeLayer
        
    }

}
