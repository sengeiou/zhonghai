//
//  KDURL.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/31.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

class KDURLHelper: NSObject {
    
    class func findHost(_ urlString: String?) -> String? {
        guard let urlString = urlString
            else { return nil }
        var host: String? = nil
        host = URL(string: urlString)?.host
        if host == nil {
            host = URL(string: urlString)?.pathComponents.first
        }
        return host
    }
}
