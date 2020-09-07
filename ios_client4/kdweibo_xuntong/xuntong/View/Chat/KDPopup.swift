//
//  KDPopup.swift
//  DZFoundation
//
//  Created by Darren Zheng on 16/9/23.
//  Copyright © 2016年 Darren Zheng. All rights reserved.
//

/**
 
 `KDPopup` 是集成了HUD，Alert，ActionSheet的弹窗控件
 
 ## Overview
 
 KDPopup
 |- MBProgressHUD
 |- UIAlertView + UIAlertController
 |- UIActionSheet + UIAlertController
 
 ## ------------------- HUD -------------------
 
 ## Usage
 
 // 最简HUD， 显示在keyWindow上
 _ = KDPopup.showHUD()
 
 // 最简HUD + 显示在特定view上，每一种HUD都有inView方法，以下不再赘述
 _ = KDPopup.showHUD(inView: myView)
 
 // HUD + 文本
 _ = KDPopup.showHUD("加载中")
 
 // 文本
 _ = KDPopup.showHUDToast("加载失败")
 
 // 成功（对号图片 + 文本）
 _ = KDPopup.showHUDSuccess("加载成功")
 
 // 自定义
 _ = KDPopup.showHUDCustomView(customView, desc: "自定义文本")
 
 // 隐藏keywindow的HUD
 _ = KDPopup.hideHUD()
 
 // 隐藏特定view的HUD
 _ = KDPopup.hideHUD(inView: myView)
 
 // 打开背景灰色蒙层
 KDPopup.showHUD().kd_setDimBackground(true)
 
 
 ## Important
 
 - HUD的show方法都返回了MBProgressHUD实例，提供以进一步修改
 - 传入的自定义View必须有intrinsicContentSize，例如UIView没有则需要重写intrinsicContentSize方法
 - 如果显示的时候传入了inView，那隐藏的时候也需要传入
 
 ## ------------------- Alert -------------------
 
 ## Usage
 
 // 最简
 KDPopup.showAlert(title: "title", message: "message", buttonTitles: ["cancel", "confirm"]) { index in
 
 }
 
 // 包含指定红色按钮样式的index
 KDPopup.showAlert(title: "title", message: "message", buttonTitles: ["cancel", "confirm"], destructiveIndex: 1) { index in
 }
 
 ## Important
 
 - 取消永远是buttonTitles第0位
 - destructiveIndex给0是无效的，因为cancel按钮的样式永远是加粗蓝色
 
 
 ## ------------------- Actioin Sheet -------------------
 
 ## Usage
 
 // 最简
 KDPopup.showActionSheet(title: "title", buttonTitles: ["Cancel", "Destroy", "OK"]) { index in
 
 }
 
 // 包含指定红色按钮样式的index
 KDPopup.showActionSheet(title: "title", buttonTitles: ["Cancel", "Destroy", "OK"], destructiveIndex: 1) { index in
 
 }
 
 ## Important
 
 - 取消永远是buttonTitles第0位
 - destructiveIndex给0是无效的，因为cancel按钮的样式永远是加粗蓝色
 
 */

class KDPopup: NSObject {
    
    static let sharedInstance = KDPopup()
    var onAlertTap: ((_ index: Int) -> ())?
    var onActionSheetTap: ((_ index: Int) -> ())?
    
}

// MARK: - HUD -
extension KDPopup {
    
    // --------------- Loading ---------------
    
    class func showHUD() -> MBProgressHUD? {
        return showHUD(inView: nil)
    }
    
    class func showHUD(inView: UIView?) -> MBProgressHUD? {
        return showHUD(nil, inView: inView)
    }
    
    // --------------- Loading + detail text ---------------
    
    class func showHUD(_ desc: String?) -> MBProgressHUD? {
        return showHUD(desc, inView: nil)
    }
    
    class func showHUD(_ desc: String?, inView: UIView?) -> MBProgressHUD? {
        let hud = currentHud(inView: inView)
        hud?.mode = MBProgressHUDModeIndeterminate
        hud?.margin = 20
        hud?.customView = nil
        hud?.labelText = desc
        hud?.detailsLabelText = nil
        hud?.show(true)
        return hud
    }
    
    // --------------- Toast ----- ----------
    
    class func showHUDToast(_ desc: String?) -> MBProgressHUD? {
        return showHUDToast(desc, inView: nil)
    }
    
    class func showHUDToast(_ desc: String?, inView: UIView?) -> MBProgressHUD? {
        let hud = currentHud(inView: inView)
        hud?.mode = MBProgressHUDModeText
        hud?.margin = 20
        hud?.customView = nil
        hud?.detailsLabelText = nil
        hud?.labelText = desc
        hud?.show(true)
        hud?.hide(false, afterDelay: 2)
        return hud
    }
    
    // --------------- Succ ---------------
    
    class func showHUDSuccess(_ desc: String?) -> MBProgressHUD? {
        return showHUDSuccess(desc, inView: nil)
    }
    
    class func showHUDSuccess(_ desc: String?, inView: UIView?) -> MBProgressHUD? {
        let hud = currentHud(inView: inView)
        hud?.mode = MBProgressHUDModeCustomView
        hud?.customView = UIImageView(image: UIImage(named: "Checkmark"))
        hud?.margin = 20
        hud?.detailsLabelText = nil
        hud?.labelText = desc
        hud?.show(true)
        hud?.hide(false, afterDelay: 1)
        return hud
    }
    
    // --------------- Custom ---------------
    
    class func showHUDCustomView(_ customView: UIView?, desc: String?) -> MBProgressHUD? {
        return showHUDCustomView(customView, desc: desc, inView: nil)
    }
    
    class func showHUDCustomView(_ customView: UIView?, desc: String?, inView: UIView?) -> MBProgressHUD? {
        let hud = currentHud(inView: inView)
        hud?.mode = MBProgressHUDModeCustomView
        hud?.margin = 0
        hud?.customView = customView
        hud?.detailsLabelText = nil
        hud?.labelText = desc
        hud?.show(true)
        return hud
    }
    
    // --------------- hide ---------------
    
    class func hideHUD() {
        if let window = UIApplication.shared.keyWindow {
            hideHUD(inView: window)
        }
    }
    
    class func hideHUD(inView: UIView?) {
        if let inView = inView {
            MBProgressHUD(for: inView)?.hide(false)
            
        }
    }
    
    fileprivate class func currentHud(inView: UIView?) -> MBProgressHUD? {
        
        func getHud(in inView: UIView) -> MBProgressHUD? {
            return MBProgressHUD(for: inView) ?? MBProgressHUD.showAdded(to: inView, animated: true)
        }
        
        var hud: MBProgressHUD? = nil
        if let inView = inView {
            hud = getHud(in: inView)
        } else {
            if let window = UIApplication.shared.keyWindow {
                hud = getHud(in: window)
            }
        }
        
        return hud
    }
}

extension MBProgressHUD {
    
    func kd_setDimBackground(_ dim: Bool) -> MBProgressHUD? {
//        backgroundView.style = MBProgressHUDBackgroundStyle.SolidColor
        color = dim ? UIColor(white: 0, alpha: 0.3) : UIColor.kdBackgroundColor5()
        return self
    }
    
}

// MARK: - Action Sheet -
extension KDPopup: UIActionSheetDelegate {
    
    @objc class func showActionSheet(title: String?,
                                           buttonTitles: [String]?,
                                           onTap: ((_ index: Int) -> ())?) {
        
        showActionSheet(title: title, buttonTitles: buttonTitles, destructiveIndex: -1, onTap: onTap)
    }
    
    @objc class func showActionSheet(title: String?,
                                           buttonTitles: [String]?,
                                           destructiveIndex: Int,
                                           onTap: ((_ index: Int) -> ())?) {
        
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController
            else { return }
        
        if #available(iOS 8.0, *) {
            let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
            buttonTitles?.enumerated()
                .forEach { (index, element) in
                    let style: UIAlertActionStyle = index == 0 ? .cancel : index == destructiveIndex ? .destructive : .default
                    let action = UIAlertAction(title: element, style: style) { _ in
                        onTap?(index)
                    }
                    alertController.addAction(action)
            }
            
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                rootViewController.present(alertController, animated: true) {}
            }
        } else {
            let popup = KDPopup.sharedInstance
            let actionSheet = UIActionSheet()
            actionSheet.delegate = popup
            actionSheet.title = title ?? ""
            popup.onActionSheetTap = onTap
            buttonTitles?.forEach { actionSheet.addButton(withTitle: $0) }
            actionSheet.actionSheetStyle = .default
            actionSheet.cancelButtonIndex = 0
            actionSheet.destructiveButtonIndex = destructiveIndex
            actionSheet.show(in: rootViewController.view)
        }
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        onActionSheetTap?(buttonIndex)
    }
    
}

// MARK: - Alert -
extension KDPopup: UIAlertViewDelegate {
    
    @objc class func showAlert(title: String?,
                                     message: String?,
                                     buttonTitles: [String]?,
                                     onTap: ((_ index: Int) -> ())?) {
        showAlert(title: title, message: message, buttonTitles: buttonTitles, destructiveIndex: -1, onTap: onTap)
    }
    
    @objc class func showAlert(title: String?,
                                     message: String?,
                                     buttonTitles: [String]?,
                                     destructiveIndex: Int,
                                     onTap: ((_ index: Int) -> ())?) {
        if #available(iOS 8.0, *) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            buttonTitles?.enumerated()
                .forEach { (index, element) in
                    let style: UIAlertActionStyle = index == 0 ? .cancel : index == destructiveIndex ? .destructive : .default
                    let action = UIAlertAction(title: element, style: style) { _ in
                        onTap?(index)
                    }
                    alertController.addAction(action)
            }
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                rootViewController.present(alertController, animated: true) {}
            }
        } else {
            let popup = KDPopup.sharedInstance
            popup.onAlertTap = onTap
            let alertView = UIAlertView(title: title, message: message, delegate: popup, cancelButtonTitle: buttonTitles?.first)
            alertView.alertViewStyle = .default
            
            buttonTitles?.enumerated()
                .filter { $0.0 != 0 }
                .forEach { alertView.addButton(withTitle: $0.1) }
            
            alertView.show()
        }
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        onAlertTap?(buttonIndex)
    }
    
}

