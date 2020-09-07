//
//  KDAlert.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/4/13.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//


class KDAlert: NSObject {
    
    @objc class func showToast(inView view: UIView?, text: String?) {
        showToast(inView: view, text: text, duration: 2)
    }
    
    @objc class func showToast(inView view: UIView?, text: String?, duration: Double) {
        guard let text = text, let viewValue = view
            else { return }
        MBProgressHUD.showAdded(to: viewValue, animated: true)
        MBProgressHUD(for:viewValue).detailsLabelText = text
//        MBProgressHUD(forView:viewValue).mode = MBProgressHUDMode.Text
        MBProgressHUD(for:viewValue).detailsLabelFont = FS5
        MBProgressHUD(for:viewValue).hide(true, afterDelay: duration)
    }
    
    @objc class func showAlert(_ tag: Int, title: String?, message: String?, delegate: NSObject?, buttonTitles: [String]?) {
        guard let buttonTitles = buttonTitles, title != nil || message != nil
            else { return }
        DispatchQueue.main.async { () -> Void in
            let alert = UIAlertView()
            if let titleValue = title {
                alert.title = titleValue
            }
            if let messageValue = message {
                alert.message = messageValue
            }
            alert.cancelButtonIndex = 0
            for buttonTitle in buttonTitles {
                alert.addButton(withTitle: buttonTitle)
            }
            if let delegateValue = delegate {
                alert.delegate = delegateValue
            }
            alert.tag = tag
            alert.show()
        }
    }
    
    @objc class func showLoading() {
        MBProgressHUD.showAdded(to: KDWeiboAppDelegate.getAppDelegate().window, animated: true)
    }
    
    @objc class func hideLoading() {
        MBProgressHUD.hideAllHUDs(for: KDWeiboAppDelegate.getAppDelegate().window, animated: true)
    }
    
}
