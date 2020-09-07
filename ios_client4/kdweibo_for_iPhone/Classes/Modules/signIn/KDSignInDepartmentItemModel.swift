//
//  KDSignInDepartmentItemModel.swift
//  kdweibo
//
//  Created by 张培增 on 2016/12/5.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

import UIKit

final class KDSignInDepartmentItemModel: NSObject {
    var departmentID: String
    var departmentName: String
    var itemWidth: CGFloat
    
    init (dictionary: NSDictionary) {
        self.departmentID = dictionary.dz_toStringForKey("departmentID")
        self.departmentName = dictionary.dz_toStringForKey("departmentName")
        self.itemWidth = 0.0
    }
}
