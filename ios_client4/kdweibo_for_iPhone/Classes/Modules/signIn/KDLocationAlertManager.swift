//
//  KDLocationAlertManager.swift
//  kdweibo
//
//  Created by 张培增 on 2017/3/20.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import UIKit

class KDLocationAlertManager: NSObject {
    
    class func showLocationAlert() {
        
        let title = ASLocalizedString("定位服务已关闭")
        let message = ASLocalizedString("请开启【\(KD_APPNAME)】定位服务，以便获取你的位置")
        
        if #available(iOS 8.0, *) {
            KDPopup.showAlert(title: title, message: message, buttonTitles: [ASLocalizedString("取消"), ASLocalizedString("去设置")], onTap: { (index) in
                if index == 1 {
                    
                    guard let url = URL(string: UIApplicationOpenSettingsURLString) else {
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.openURL(url)
                    }
                    
                }
            })
        }
        else {
            KDPopup.showAlert(title: title, message: message, buttonTitles: [ASLocalizedString("确定")], onTap: nil)
        }
        
    }

}
