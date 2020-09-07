//
//  KDV8Button.swift
//  kdweibo
//
//  Created by Darren Zheng on 2016/10/25.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

//enum KDV8ButtonStyle {
//    case short, long
//}
//
//enum KDV8ButtonTheme {
//    case blue, white
//}

@objc class KDV8Button: UIButton {
    
//    init(style: KDV8ButtonStyle, theme: KDV8ButtonTheme) {
//        super.init(frame: CGRectZero)
//        layer.cornerRadius = 6
//        layer.masksToBounds = true
//        titleLabel?.font = FS8
//        switch style {
//        case .short:
//            contentEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6)
//        case .long:
//            contentEdgeInsets = UIEdgeInsetsMake(0, 24, 0, 24)
//        }
//        switch theme {
//        case .blue:
//            backgroundColor = FC5
//            setTitleColor(FC6, forState: .Normal)
//        case .white:
//            backgroundColor = UIColor.whiteColor()
//            setTitleColor(FC2, forState: .Normal)
//        }
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                if self.backgroundColor == FC6 {
                    self.alpha = 1.0
                    self.backgroundColor = UIColor(hexRGB: "0C213F", alpha: 0.05)
                } else {
                    self.alpha = 0.5
                }
            } else {
                if self.backgroundColor == UIColor(hexRGB: "0C213F", alpha: 0.05) {
                    self.backgroundColor = FC6
                }
                self.alpha = 1.0
            }
        }
    }
    
}
