//
//  KDNoticePopupVC.swift
//  kdweibo
//
//  Created by Darren Zheng on 2017/2/20.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

@objc protocol KDNoticePopupVCDelegate: KDNoticePopupViewDelegate {
    func noticePopupWillShow(_ popupVC: KDNoticePopupVC)
}

class KDNoticePopupVC: NSObject {
    
    weak var delegate: KDNoticePopupVCDelegate?
    
    lazy var popup: KDNoticePopupView = {
        $0.frame = KDWeiboAppDelegate.getAppDelegate().window.bounds
        $0.delegate = self.delegate
        return $0
    }(KDNoticePopupView())
    
    var isPopupShowing: Bool = false
    
    func showPopup() {
        isPopupShowing = true
        delegate?.noticePopupWillShow(self)
    }
    
    func showPopup(_ dataSource: KDNoticePopupViewDataSource?) {
        popup.dataSource = dataSource
        KDWeiboAppDelegate.getAppDelegate().window.addSubview(popup)
        popup.containerView.alpha = 1
        popup.maskBgButton.alpha = 0.8
    }
    
    func hidePopup() {
        popup.containerView.alpha = 0
        popup.maskBgButton.alpha = 0
        self.popup.removeFromSuperview()
        self.isPopupShowing = false
    }
}
