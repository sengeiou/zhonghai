//
//  KDSignInGroupServerModel.swift
//  kdweibo
//
//  Created by 张培增 on 2017/3/28.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import UIKit

class KDSignInGroupServerModel: NSObject {
    var id: String?                          //签到组ID
    var attendanceSetGroupName: String?      //签到组名称
    var depts: NSArray?                      //所有部门信息的Array
    var users: NSArray?                      //所有签到个人的Array
    var attendanceSets: NSArray?             //所有签到点信息的Array
    var isShift: Bool = false                //是否排班制
    
    override init() {
        super.init()
    }
    
    convenience init(dict: [String: AnyObject]?) {
        self.init()
        guard let dict = dict
            else { return }
        
        dz_bindStringValue(fromDict: dict, toObj: self, withKey: "id")
        dz_bindStringValue(fromDict: dict, toObj: self, withKey: "attendanceSetGroupName")
        
        if let depts = dict["depts"] {
            self.depts = depts as? NSArray
        }
        if let users = dict["users"] {
            self.users = users as? NSArray
        }
        if let attendanceSets = dict["attendanceSets"] {
            self.attendanceSets = attendanceSets as? NSArray
        }
        if let  isShift = dict["isShift"]{
            self.isShift = Bool(isShift as! NSNumber)
        }
//        dz_bindStringValue(fromDict: dict, toObj: self, withKey: "isShift")
        
    }
}

