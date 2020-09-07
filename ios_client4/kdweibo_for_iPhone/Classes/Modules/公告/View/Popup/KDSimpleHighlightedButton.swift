//
//  KDSimpleHighlightedButton.swift
//  kdweibo
//
//  Created by Darren Zheng on 2017/2/12.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import UIKit

class KDSimpleHighlightedButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.alpha = 0.5
            } else {
                self.alpha = 1.0
            }
        }
    }
}
