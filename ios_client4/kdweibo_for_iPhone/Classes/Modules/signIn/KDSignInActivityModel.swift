//
//  KDSignInActivityModel.swift
//  kdweibo
//
//  Created by 张培增 on 2017/5/16.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import UIKit

protocol KDSignInActivityModelDataSource {
    var activityId: String? { get }
    var picId: String? { get }

    var btnText: String? { get }
    var btnTextColorNormal: UIColor? { get }
    var btnTextColorPress: UIColor? { get }

    var btnBGColorNormal: UIColor? { get }
    var btnBGColorPress: UIColor? { get }
    
    var btnActionUrl: String? { get }
}

class KDSignInActivityModel: NSObject {

    var model = NSDictionary() {
        didSet {
            if let button = model.object(forKey: "buttons") as? NSArray, button.count > 0 {
                btnStyle = (button[0] as? NSDictionary) ?? NSDictionary()
                btnTextStyle = (btnStyle.object(forKey: "text") as? NSDictionary)!
                
                if let appendage: NSDictionary = btnStyle.object(forKey: "appendage") as? NSDictionary {
                    actionUrl = appendage.string(forKey: "url")
                }
            }
        }
    }
    
    fileprivate var btnStyle = NSDictionary()
    fileprivate var btnTextStyle = NSDictionary()
    fileprivate var actionUrl: String?
    
    fileprivate func getColor(_ colorString: String?) -> UIColor? {
        
        guard let colorString = colorString else {
            return nil
        }
        
        let colorArr = colorString.components(separatedBy: ",")
        guard colorArr.count == 4 else {
            return nil
        }
        
        if let r = NumberFormatter().number(from: colorArr[0]), let g = NumberFormatter().number(from: colorArr[1]), let b = NumberFormatter().number(from: colorArr[2]), let a = NumberFormatter().number(from: colorArr[3]) {
            return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(a)/255.0)
        }
        
        return nil
    }
    
}

extension KDSignInActivityModel: KDSignInActivityModelDataSource {
    
    var activityId: String? { return model.string(forKey: "id") }
    
    var picId: String? { return model.string(forKey: "picId") }
    
    var btnText: String? { return btnTextStyle.string(forKey: "content") }
    
    var btnTextColorNormal: UIColor? { return getColor(btnTextStyle.string(forKey: "normalStyle")) }
    
    var btnTextColorPress: UIColor? { return getColor(btnTextStyle.string(forKey: "pressedStyle")) }
    
    var btnBGColorNormal: UIColor? { return getColor(btnStyle.string(forKey: "normalBackgroundStyle")) }

    var btnBGColorPress: UIColor? { return getColor(btnStyle.string(forKey: "pressedBackgroundStyle")) }
    
    var btnActionUrl: String? { return actionUrl }
    
}
