//
//  XTChatViewController+Notice.swift
//  kdweibo
//
//  Created by Darren Zheng on 2017/2/14.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import Foundation


extension XTChatViewController: KDNoticeControllerDataSource, KDNoticeControllerDelegate, UIGestureRecognizerDelegate {
    
    var noticeControllerNavigationController: UINavigationController? { return navigationController }
    var noticeControllerGroupId: String? {
        return group.groupId
    }
    var noticeControllerIsAdmin: Bool { return group.isManager() }
    var noticeControllerHasNewNotice: Bool { return group.isNotifyTypeNotice() }
    
    func noticeBoxVCBoxDidShow(_ noticeBoxVC: KDNoticeBoxVC) {
        bubbleTable.addGestureRecognizer(noticeBoxTapGesture)
    }
    
    func noticeBoxVCBoxDidHide(_ noticeBoxVC: KDNoticeBoxVC) {
        bubbleTable.removeGestureRecognizer(noticeBoxTapGesture)
        setupRightNavigationItem()
    }
}

// MARK: - Misc -
extension XTChatViewController {
    
    func noticeHandleTap(_ noticeController: KDNoticeController) {
        noticeController.hideBox(animated: true)
    }
    
    func noticeButtonPressed(_ noticeController: KDNoticeController) {
        if noticeController.isBoxShowing {
            noticeController.hideBox(animated: true)
        } else {
            noticeController.showBox()
//            workflowController.shrinkWorkflow(animated: true)
        }
        setupRightNavigationItem()
//        KDEventAnalysis.event(session_groupnotice)
    }
    
    func noticeOnViewDidload(_ noticeController: KDNoticeController) {
        if let group = self.group, group.isNotifyTypeNotice() {
            noticeController.showPopup()
        }
    }
    
    func noticeOnGroupChange(_ noticeController: KDNoticeController) {
        if let group = self.group, group.isNotifyTypeNotice() {
            noticeController.showBox()
//            workflowController.shrinkWorkflow(animated: true)
        }
    }
    
}
