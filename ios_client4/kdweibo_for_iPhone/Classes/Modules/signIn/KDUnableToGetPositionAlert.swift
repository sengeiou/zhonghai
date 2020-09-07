//
//  KDUnableToGetPositionAlert.swift
//  kdweibo
//
//  Created by 张培增 on 2017/3/21.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import UIKit

class KDUnableToGetPositionAlert: NSObject {
    
    var failedCount: NSInteger = 0
    
    func show(_ finished: (() -> ())?) {
        
        if failedCount < 3 {
            failedCount += 1
            
            KDPopup.showAlert(title: ASLocalizedString("签到失败"), message: ASLocalizedString("由于网络不稳定,暂时无法准确定位,建议重新签到或拍照说明你的位置"), buttonTitles: [ASLocalizedString("取消"), ASLocalizedString("拍照签到")], onTap: { (index) in
                if index == 1 {
                    if let finished = finished {
                        finished()
                    }
                }
            })
        }
        else {
            if let finished = finished {
                finished()
            }
        }
        
    }
    
}
