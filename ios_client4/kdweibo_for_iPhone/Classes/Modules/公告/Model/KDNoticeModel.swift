//
//  KDNoticeModel.swift
//  kdweibo
//
//  Created by Darren Zheng on 2017/2/10.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import Foundation

class KDNoticeModel: NSObject {
    var serverModel = KDNoticeServerModel()
    
}

extension KDNoticeModel {
    var readableTime: String {
        if serverModel.createTime != 0 {
            return "\(serverModel.creator ?? "")  \(KDDate.humanReadableDateFrom1970(Double(serverModel.createTime)))"
        } else {
            return "\(serverModel.creator ?? "")"
        }
    }
}

extension KDNoticeModel: KDNoticePopupViewDataSource {
    // 总标题
    var popupViewTitle: String? { return ASLocalizedString("Notice_Group") }
    
    // 更多按钮
    var popupViewMoreButtonTitle: String? { return ASLocalizedString("Notice_More") }
    
    // 文章标题
    var popupViewContentTitle: String? { return serverModel.title ?? "" }
    
    // 文章副标题
    var popupViewContentSubTitle: String? { return readableTime }
    
    // 文章正文
    var popupViewContent: String? { return serverModel.content ?? "" }
    
    // 确认按钮文本
    var popupViewConfirmButtonTitle: String? { return ASLocalizedString("KDApplicationViewController_tips_i_know") }
}

extension KDNoticeModel: KDNoticeBoxViewContentDataSource {
    
    // 标题
    var boxViewTitle: String? { return serverModel.title ?? " " }
    
    // 内容
    var boxViewContent: String? { return serverModel.content ?? "" }
    
    // 副标题
    var boxViewSubTitle: String? { return readableTime ??  "" }

}

extension KDNoticeModel: KDNoticeListCellDataSource {
    
    // 标题
    var noticeListCellTitle: String? { return serverModel.title ?? "" }
    
    // 副标题
    var noticeListCellSubtitle: String? { return readableTime }
    
    // 内容
    var noticeListCellContent: String? { return serverModel.content ?? "" }
}

extension KDNoticeModel: KDNoticeDetailVCDataSource {
    
    // 标题
    var noticeDetailVCTitle: String? { return serverModel.title ?? "" }
    
    // 副标题
    var noticeDetailVCSubtitle: String? { return readableTime }
    
    // 内容
    var noticeDetailVCContent: String? { return serverModel.content ?? "" }
    
    // id, 用于页面回传
    var noticeDetailVCNoticeId: String? { return serverModel.noticeId ?? "" }

}
