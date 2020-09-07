//
//  KDItem.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/9.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

@objc protocol KDItemDisplayable {
    
    // 标题
    var title: String? { get set }
    // 副标题
    @objc optional var subtitle: String? { get set }
    // 图片
    @objc optional var image: UIImage? { get set }
    // 按下的图片
    @objc optional var highlightedImage: UIImage? { get set }
    // 点击事件
    @objc optional var onPress: ((_ sender: NSObject?) -> Void)? { get set }
    
}

@objc class KDItem: NSObject, KDItemDisplayable {
    
    var title: String?
    var subtitle: String?
    var image: UIImage?
    var highlightedImage: UIImage?
    var onPress: ((_ sender: NSObject?) -> Void)?
    
    init(title: String?, subtitle: String?, image: UIImage?, highlightedImage: UIImage?, onPress: ((_ sender: NSObject?) -> Void)?) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.highlightedImage = highlightedImage
        self.onPress = onPress
    }
    
    class func findModel<T: KDItemDisplayable>(_ name: String?, set: Set<T>?) -> T? {
        return set?.filter { $0.title == name }.first
    }
}

