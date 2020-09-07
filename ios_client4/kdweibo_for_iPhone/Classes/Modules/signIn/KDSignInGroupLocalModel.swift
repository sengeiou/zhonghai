//
//  KDSignInGroupLocalModel.swift
//  kdweibo
//
//  Created by 张培增 on 2017/3/28.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import UIKit

class KDSignInGroupLocalModel: NSObject {
    
    var serverModel:KDSignInGroupServerModel? {
        didSet {
            updateData()
        }
    }
    
    var groupId: String = ""
    var groupName: String = ""
    var isShift: Bool = false
    var departmentsArray = [KDSignInDepartmentItemModel]()
    var usersArray = [PersonSimpleDataModel]()
    var signInPointsArray = [KDSignInPoint]()
    var deptsOrPersonsName: String = ""
    var locationName: String = ""
    
}

extension KDSignInGroupLocalModel {
    
    func updateData() {
        
        groupId = serverModel?.id ?? ""
        groupName = serverModel?.attendanceSetGroupName ?? ""
        isShift = serverModel?.isShift ?? false
        
        if let depts = serverModel?.depts {
            for dict in depts.filter({ $0 is NSDictionary }) {
                departmentsArray.append(KDSignInDepartmentItemModel(dictionary: [
                    "departmentID": (dict as AnyObject).string(forKey: "id", defaultValue: ""),
                    "departmentName": (dict as AnyObject).string(forKey: "name", defaultValue: "")]))
            }
        }
        
        if let attendanceSets = serverModel?.attendanceSets {
            for dict in attendanceSets.filter({ $0 is NSDictionary }) {
                signInPointsArray.append(KDSignInPoint(dictionary: [
                    "id": (dict as AnyObject).string(forKey: "attendanceSetId", defaultValue: ""),
                    "positionName": (dict as AnyObject).string(forKey: "positionName", defaultValue: ""),
                    "address": (dict as AnyObject).string(forKey: "address", defaultValue: ""),
                    "alias": (dict as AnyObject).string(forKey: "alias", defaultValue: ""),
                    "lng": NSNumber(value: (dict as AnyObject).double(forKey: "lng") as Double),
                    "lat": NSNumber(value: (dict as AnyObject).double(forKey: "lat") as Double),
                    "offset": NSNumber(value: (dict as AnyObject).double(forKey: "offset", defaultValue: 200) as Double)
                    ]))
            }
        }
        
        if let users = serverModel?.users {
            for dict in users.filter({ $0 is NSDictionary }) {
                usersArray.append(PersonSimpleDataModel(dictionary: [
                    "wbUserId": (dict as AnyObject).string(forKey: "userId", defaultValue: ""),
                    "name": (dict as AnyObject).string(forKey: "username", defaultValue: ""),
                    "id": (dict as AnyObject).string(forKey: "personId", defaultValue: "")
                    ]))
            }
        }
        
        if departmentsArray.count > 0 && usersArray.count > 0 {
            deptsOrPersonsName = ""
        }
        else if departmentsArray.count > 0 {
            deptsOrPersonsName = ASLocalizedString("签到部门：")
            for department in departmentsArray {
                deptsOrPersonsName += department.departmentName
                deptsOrPersonsName += ","
            }
        }
        else if usersArray.count > 0 {
            deptsOrPersonsName = ASLocalizedString("签到个人：")
            for user in usersArray {
                deptsOrPersonsName += user.personName
                deptsOrPersonsName += ","
            }
        }
        else {
            deptsOrPersonsName = ASLocalizedString("暂无人员")
        }
        if deptsOrPersonsName.characters.last == "," {
            deptsOrPersonsName = deptsOrPersonsName.substring(to: deptsOrPersonsName.characters.index(before: deptsOrPersonsName.endIndex))
        }

        if signInPointsArray.count > 0 {
            for signInPoint in signInPointsArray {
                if signInPoint.alias == "" {
                    locationName += signInPoint.positionName
                    locationName += ","
                }
                else {
                    locationName += signInPoint.alias
                    locationName += ","
                }
            }
            if locationName.characters.last == "," {
                locationName = locationName.substring(to: locationName.characters.index(before: locationName.endIndex))
            }
        }
        else {
            locationName = ASLocalizedString("暂无签到点")
        }
        
    }
    
}
