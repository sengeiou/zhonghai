//
//  KDAgoraModel.swift
//  kdweibo
//
//  Created by lichao_liu on 16/5/24.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

import UIKit
@objc
class KDAgoraModel: NSObject {
    var account: String
    var uid: Int = 0
    var volumeType: Int = 0
    var mute: Int = 0
    var person: PersonSimpleDataModel?
    
    @objc  init(account: String, uid: Int, volumeType: Int, mute: Int) {
        self.account = account
        self.uid = uid
        self.volumeType = volumeType
        self.mute = mute
        self.person = KDCacheHelper.person(forKey: account);
    }
}
