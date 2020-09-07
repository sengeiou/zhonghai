//
//  KDRoundImageView.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/11.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

// 继承即可，一定要用正方形，正方形，正方形

class KDRoundImageView: UIImageView {

    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.width / 2.0
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
}

class KDRoundCornerImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.width / CGFloat(55/14)
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
}
