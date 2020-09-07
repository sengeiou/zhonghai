//
//  KDSignInAdvancedSettingModel.swift
//  kdweibo
//
//  Created by 张培增 on 2017/1/5.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import UIKit

final class KDSignInAdvancedSettingModel: NSObject {
    var lateTime : Int = 15                      //上班后不算迟到的分钟数
    var earlyLeaveTime : Int = 15                //下班前不算早退的分钟数
    var range : Int = 120                        //最早签到时间
    var isFlexibleAttendance : Bool = false      //是否弹性考勤
    var flexibleWorkHours : Double = 8           //弹性考勤可晚上班的分钟数
    var flexibleLateTime : Int = 30              //弹性考勤的工时
    var settingId : String = ""                  //高级设置id
    
//    static override func keyMapper() -> JSONKeyMapper? {
//        return JSONKeyMapper(modelToJSONDictionary: [
//            "isFlexibleAttendance": "flexibleAtt",
//            "settingId": "id",
//            ])
//    }
    
    convenience init(dict: [String: AnyObject]?) {
        self.init()
        guard let dict = dict
            else { return }
        
        if let lateTime = dict["lateTime"] {
            self.lateTime = Int(lateTime as! NSNumber)
        }
        if let earlyLeaveTime = dict["earlyLeaveTime"] {
            self.earlyLeaveTime = Int(earlyLeaveTime as! NSNumber)
        }
        if let range = dict["range"] {
            self.range = Int(range as! NSNumber)
        }
        if let flexibleAtt = dict["flexibleAtt"] {
            self.isFlexibleAttendance = Bool(flexibleAtt as! NSNumber)
        }
        if let flexibleWorkHours = dict["flexibleWorkHours"] {
            self.flexibleWorkHours = Double(flexibleWorkHours as! NSNumber)
        }
        if let flexibleLateTime = dict["flexibleLateTime"] {
            self.flexibleLateTime = Int(flexibleLateTime as! NSNumber)
        }
        if let id = dict["id"] {
            self.settingId = id as! String
        }
    }
    
    
}
