//
//  KDFrameHelper.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/5.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

class KDFrame: NSObject {

    class func screenWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    class func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    class func screenBounds() -> CGRect {
        return UIScreen.main.bounds
    }
    
    class func setHeight(_ view: UIView?, height: CGFloat) {
        guard let view = view
            else { return }
        view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: height)
    }
    
    class func setWidth(_ view: UIView?, width: CGFloat) {
        guard let view = view
            else { return }
        view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: width, height: view.frame.size.height)
    }
    
    class func setX(_ view: UIView?, x: CGFloat) {
        guard let view = view
            else { return }
        view.frame = CGRect(x: x, y: view.frame.origin.y, width: view.frame.size.width, height: view.frame.size.height)
    }
    
    class func setY(_ view: UIView?, y: CGFloat) {
        guard let view = view
            else { return }
        view.frame = CGRect(x: view.frame.origin.x, y: y, width: view.frame.size.width, height: view.frame.size.height)
    }
    
    class func X(_ view: UIView?) -> CGFloat {
        guard let view = view
            else { return 0 }
        return view.frame.origin.x
    }
    
    class func Y(_ view: UIView?) -> CGFloat {
        guard let view = view
            else { return 0 }
        return view.frame.origin.y
    }
    
    class func maxY(_ view: UIView?) -> CGFloat {
        guard let view = view
            else { return 0 }
        return view.frame.origin.y + view.frame.size.height
    }
    
    class func maxX(_ view: UIView?) -> CGFloat {
        guard let view = view
            else { return 0 }
        return view.frame.origin.x + view.frame.size.width
    }
    
    class func width(_ view: UIView?) -> CGFloat {
        guard let view = view
            else { return 0 }
        return view.frame.size.width
    }
    
    class func height(_ view: UIView?) -> CGFloat {
        guard let view = view
            else { return 0 }
        return view.frame.size.height
    }

    class func setBorder(_ view: UIView) {
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
    }

}
