//
//  KDEmotionPreviewView.swift
//  kdweibo
//
//  Created by Darren Zheng on 7/10/16.
//  Copyright © 2016 www.kingdee.com. All rights reserved.
//

class KDEmotionPreviewView: UIView {

    lazy var previewImageView: FLAnimatedImageView = {
        let imageView = FLAnimatedImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(previewImageView)
        previewImageView.mas_makeConstraints { make in
            make?.edges.equalTo()(self.previewImageView.superview!)?.with().insets()(UIEdgeInsetsMake(16, 23, 16, 23))
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
