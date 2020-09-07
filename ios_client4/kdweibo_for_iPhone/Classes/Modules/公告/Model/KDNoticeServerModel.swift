//
//  KDNoticeServerModel.swift
//  kdweibo
//
//  Created by Darren Zheng on 2017/2/14.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//


class KDNoticeServerModel: NSObject {
    var noticeId: String?
    var creator: String?
    var title: String?
    var content: String?
    var createTime: Double = 0.0
    
    override init() {
        super.init()
    }
    
    convenience init(dict: [String: AnyObject]?) {
        self.init()
        guard let dict = dict
            else { return }
        dz_bindStringValue(fromDict: dict, toObj: self, withKey: "noticeId")
        dz_bindStringValue(fromDict: dict, toObj: self, withKey: "creator")
        dz_bindStringValue(fromDict: dict, toObj: self, withKey: "title")
        dz_bindStringValue(fromDict: dict, toObj: self, withKey: "content")
        
//        dz_bindStringValue(fromDict: dict, toObj: self, withKey: "createTime")
        
        if let createTimeString = dict["createTime"] {
            
            createTime = Double(createTimeString as! NSNumber)
        }
    }
}
