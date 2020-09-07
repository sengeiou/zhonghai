//
//  KDChatNotraceMaskView.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/4/1.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

final class KDChatNotraceMaskView: UIView {
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"message_bg_traceless_popup")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = KDCOLOR_POPUP
        addSubview(imageView)
        imageView.mas_makeConstraints { make in
            make?.centerX.equalTo()(self.imageView.superview!.centerX)
            make?.centerY.equalTo()(self.imageView.superview!.centerY)
            return()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
