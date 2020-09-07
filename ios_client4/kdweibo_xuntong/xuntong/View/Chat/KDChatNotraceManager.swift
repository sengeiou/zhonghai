//
//  KDChatNotraceManager.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/3/31.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

final class KDChatNotraceManager: NSObject {
    
    static let sharedInstance = KDChatNotraceManager()
    
    // 最大字数限制
    let maxWordsLength = 140
    // 图片/文本的默认倒计时时长
    let textAndPictureTimer = 10
    // 蒙层的展示时长
    let maskTimer = 1
    // 本地删除延迟时间
    let localDeleteTimer = 0.5
    enum KDChatNotraceDisplayMode { case mask, text, picture }
    
    weak var chatVC: XTChatViewController?
    weak var cell: BubbleTableViewCell?
    var currentModel: MessageNotraceDataModel?
    var currentGroupId: String?
    var currentMsgId: String?
    var displayMode: KDChatNotraceDisplayMode?
    var photoBrowser = MJPhotoBrowser()
    
    lazy var cdView: KDChatNotraceCDView = {
        let cdView = KDChatNotraceCDView()
        return cdView
    }()
    lazy var textView: KDChatNotraceTextView = {
        let textView = KDChatNotraceTextView()
        return textView
    }()
    lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.font = FS6
        label.textColor = FC3
        return label
    }()
    lazy var maskView: KDChatNotraceMaskView = {
        let maskView = KDChatNotraceMaskView()
        return maskView
    }()
    
}

// MARK: - UI事件
extension KDChatNotraceManager {
    
    // 长按
    @objc func onLongPress(_ cell: BubbleTableViewCell?) {
        guard let chatVC = chatVC, let cell = cell, let msgId = cell.dataInternal?.record?.msgId, let groupId = cell.dataInternal?.group?.groupId
            else { return }
        self.cell = cell
        displayMode = nil
        chatVC.hideInputBoard()
        chatVC.view.endEditing(true)
        
        KDContactClientWrapper.sharedInstance.getNotraceMsgInfo(groupId, msgId: msgId)
        { (succ: Bool, errorMsg: String?, data: AnyObject?) in
            _ = KDPopup.hideHUD()
            if !succ && errorMsg != nil {
                _ = KDPopup.showHUDToast(errorMsg)
            }
            guard let data = data as? NSDictionary
                else { return }
            if let recordResult = RecordDataModel(dictionary: data as! [AnyHashable: Any]) {
                if let notracePramaModel = recordResult.param.paramObject as? MessageNotraceDataModel {
                    self.show(model: notracePramaModel)
                }
            }
            
        }
        currentGroupId = groupId
        currentMsgId = msgId
    }
    
    // 手指移开
    @objc func onAllFingersLeave() {
        KDContactClientWrapper.sharedInstance.getNotraceMsgInfoClient.cancelRequest()
        KDContactClientWrapper.sharedInstance.delNotraceMsgInfoClient.cancelRequest()
        _ = KDPopup.hideHUD()
        if displayMode != nil {
            hide(true)
        }
    }
    
    // 倒计时结束
    @objc func onCountdownEnd() {
        KDContactClientWrapper.sharedInstance.getNotraceMsgInfoClient.cancelRequest()
        KDContactClientWrapper.sharedInstance.delNotraceMsgInfoClient.cancelRequest()
        _ = KDPopup.hideHUD()
        if displayMode != nil {
            hide(false)
        }
    }
    
}

// MARK: - 核心展示逻辑
private extension KDChatNotraceManager {
    
    func show(model: MessageNotraceDataModel?) {
        guard let model = model
            else { return }
        currentModel = model
        if (!KDUserDefaults.sharedInstance().isFlagConsumed(kChatNotraceMask)) {
            KDUserDefaults.sharedInstance().runOnce(withFlag: kChatNotraceMask) {
                self.displayMode = .mask
                self.showMask() {
                    self.hide(false)
                }
                self.showCD(false, duration: self.maskTimer)
            }
        } else {
            if model.msgType == MessageTypeText {
                showTextView(content: model.content) {
                    self.hide(false)
                }
                displayMode = .text
            }
            if model.msgType == MessageTypeFile  {
                let url = cell?.dataInternal.record.originalPictureUrl()
                showPhoto(url: url) {
                    self.hide(false)
                }
                displayMode = .picture
            }
            showWarningView()
            if let record = cell?.dataInternal?.record {
                warningLabel.isHidden = record.msgDirection == MessageDirectionRight
                if record.msgDirection == MessageDirectionLeft {
                    showCD(true, duration: Int(model.effectiveDuration))
                }
            }
        }
        UIApplication.shared.isStatusBarHidden = true
    }
    
    // 手指移开的hide有特殊性，要中断所有的操作，例如蒙层结束后不能再继续
    func hide(_ allFingersLeave: Bool) {
        UIApplication.shared.isStatusBarHidden = false
        hideCD()
        if let mode = displayMode, let cell = cell {
            switch mode {
            case .text: fallthrough
            case .picture:
                cell.isUserInteractionEnabled = false
                if mode == .text {
                    hideTextView()
                } else {
                    hidePhotoView()
                }
                hideWarningView()
                if let record = cell.dataInternal?.record, record.msgDirection == MessageDirectionLeft {
                    delay(0.5) {
                        // 防御本地删除前被网络删除
                        if let chatVC = self.chatVC, let recordsList = chatVC.recordsList, self.currentMsgId != nil {
                            if (chatVC.findMsgId(self.currentMsgId, inRecords: recordsList) != nil) {
                                
                                KDContactClientWrapper.sharedInstance.delNotraceMsgInfo(self.currentGroupId, msgId: self.currentMsgId, completion: nil)
                                XTDataBaseDao.sharedDatabaseDaoInstance().deleteRecord(withMsgId: self.currentMsgId)
                                cell.isUserInteractionEnabled = true
                                chatVC.cancelMsgId = self.currentMsgId
                                chatVC.cancelMsgCell = cell;
                                chatVC.deleteCancelCell()
                            }
                        }
                    }
                } else {
                    cell.isUserInteractionEnabled = true
                }
            case .mask:
                hideMask()
                if !allFingersLeave {
                    show(model: currentModel)
                }
                break
            }
        }
    }
}

// MARK: - Mask
private extension KDChatNotraceManager {
    func showMask(_ fail: ()->()) {
        guard let keywindow = UIApplication.shared.keyWindow
            else { fail(); return }
        keywindow.addSubview(maskView)
        maskView.mas_makeConstraints { make in
            make?.edges.equalTo()(self.maskView.superview!)?.with().insets()(UIEdgeInsets.zero)
            return()
        }
    }
    
    func hideMask() {
        maskView.removeFromSuperview()
    }
}

// MARK: - Text View
private extension KDChatNotraceManager {
    
    func showTextView(content: String?, fail: ()->()) {
        guard let keywindow = UIApplication.shared.keyWindow, var content = content
            else { fail(); return }
        keywindow.addSubview(textView)
        if content.characters.count > maxWordsLength {
            content = content.substring(to: content.characters.index(content.startIndex, offsetBy: maxWordsLength))
        }
        
        textView.contentTextView.text = content
        textView.mas_makeConstraints { make in
            make?.edges.equalTo()(self.textView.superview)?.with().insets()(UIEdgeInsets.zero)
            return()
        }
    }
    
    func hideTextView() {
        textView.removeFromSuperview()
    }
}


// MARK: - Warning
private extension KDChatNotraceManager {
    
    func showWarningView() {
        guard let keywindow = UIApplication.shared.keyWindow
            else { return }
        keywindow.addSubview(warningLabel)
        warningLabel.mas_makeConstraints { make in
            make?.centerX.equalTo()(self.warningLabel.superview!.centerX)
            make?.bottom.equalTo()(self.warningLabel.superview!.bottom)?.with().offset()(-15)
            return()
        }
        warningLabel.text = ASLocalizedString("XTChatViewController_Notrace_Tips")
        keywindow.bringSubview(toFront: warningLabel)
    }
    
    func hideWarningView() {
        warningLabel.removeFromSuperview()
    }
}

// MARK: - Countdown
private extension KDChatNotraceManager {
    
    func showCD(_ showLabel: Bool, duration: Int?) {
        guard let keywindow = UIApplication.shared.keyWindow
            else { return }
        cdView = KDChatNotraceCDView()
        if displayMode == .mask {
            cdView.timer = duration ?? textAndPictureTimer
        } else {
            cdView.timer = duration ?? textAndPictureTimer
        }
        keywindow.addSubview(cdView)
        keywindow.bringSubview(toFront: cdView)
        cdView.onCountdownEnd = {
            self.onCountdownEnd()
        }
        cdView.mas_makeConstraints { make in
            make?.right.equalTo()(self.cdView.superview!.right)?.with().offset()(-15)
            make?.top.equalTo()(self.cdView.superview!.top)?.with().offset()(8)
            make?.height.mas_equalTo()(30)
            make?.width.mas_equalTo()(100)
            return()
        }
        cdView.startCounting()
        cdView.cdLabel.isHidden = !showLabel
    }
    
    func hideCD() {
        cdView.clock?.invalidate()
        cdView.removeFromSuperview()
    }
}

// MARK: - Photo
private extension KDChatNotraceManager {
    
    func showPhoto(url: URL?, fail: (()->())?) {
        guard let url = url
            else { fail?(); return }
        let photo = MJPhoto()
        photo.url = url
        photo.bFullScrean = true
        photoBrowser = MJPhotoBrowser()
        photoBrowser.photos = [photo]
        photoBrowser.bHideToolBar = true
        photoBrowser.bHideMenuBar = true
        //        photoBrowser.pictureSingleTap = {}
        photoBrowser.view.backgroundColor = UIColor.black
        photoBrowser.show()
    }
    
    func hidePhotoView() {
        photoBrowser.hide()
    }
}

