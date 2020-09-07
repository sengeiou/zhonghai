//
//  KDKingdeeConfig.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/18.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

final class KDKingdeeConfig: NSObject {
    
    static let sharedInstance = KDKingdeeConfig()
    
    let kingdeeEid = "10109"

    func isKingdeeCompany() -> Bool {
        return BOSConfig.shared().user.eid == kingdeeEid
    }
}
