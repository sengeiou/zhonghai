//
//  KDChatTextswift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/23.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

class KDChatDialogBaseCell: KDChatBaseCell, XTPersonHeaderViewDelegate, UIAlertViewDelegate {
    
    // MARK: 头像
    
    var onPersonHeaderClicked: ((_ person: PersonSimpleDataModel?) -> Void)?
    var onKeywordTap: ((_ linkPrefix: String, _ keyword: String) -> Void)?
    
    
    // MARK: 已读未读按钮
    var unreadButtonEgde: MASConstraint?
    
    lazy var unreadButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(FC5, for: UIControlState())
        button.titleLabel?.font = FS8
        button.addTarget(self, action: #selector(KDChatDialogBaseCell.unreadButtonPressed), for: .touchUpInside)
        return button
    }()
    
    let unreadAlertTag = 100
    func unreadButtonPressed() {
        if tryItYourselfButton.isHidden == false {
            chatVC.reloadData()
        }
        if dataInternal.group.groupType == GroupTypeDouble {
//            KDAlert.showAlert(unreadAlertTag, title: "", message: "是否短信提醒TA", delegate: self, buttonTitles: ["取消", "发送"])
          
        } else {
            //KDEventAnalysis.event(event_unreadMessage_tipsPress)
            //跟新库小气泡已经被点击
            XTSetting.shared().pressMsgUnreadTipsOrNot = true
            XTSetting.shared().save()
    
        }
        //获取每条消息详细的已读未读信息
        KDApplicationQueryAppsHelper.share().getUnreadCountDetail(withGroupId: dataInternal.group.groupId,
                                                                                   msgId:dataInternal.record.msgId)
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if alertView.tag == unreadAlertTag {
            if buttonIndex != 0 {
//                KDContactClientWrapper.sharedInstance.notifyUnreadUsers(dataInternal.group.groupId, msgId: dataInternal.record.msgId, completion: { (succ, errorMsg, data) in
//                    var string = "已发送短信"
//                    if succ {
//                        if let name = self.dataInternal.group.firstParticipant()?.personName {
//                            string = "已发送短信通知到\(name)"
//                        }
//                    } else {
//                        string = "发送失败"
//                    }
//                    _ = KDPopup.showHUDToast(string)
//                    KDEventAnalysis.event(event_unreadMessage_sendUnreadUsers, attributes: [label_unreadMessage_sendUnreadUsers_type : label_unreadMessage_sendUnreadUsers_type_sms])
//                })
            }
        }
    }
    
    // 点击试试
    lazy var tryItYourselfButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "messageUnreadBubble"), for: UIControlState())
        button.addTarget(self, action: #selector(KDChatDialogBaseCell.tryItYourselfButtonPressed), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 9)
        button.setTitle("点击试试", for: UIControlState())
        button.setTitleColor(FC5, for: UIControlState())
        button.isHidden = true
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 4, 0)
        return button
    }()
    
    func tryItYourselfButtonPressed() {
        unreadButtonPressed()
    }
    
    // MARK: 发送失败button
    var failButtonIndicatorEgde: MASConstraint?
    
    lazy var failButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(XTImageUtil.chatSendFailueImage(), for: UIControlState())
        button.addTarget(self, action: #selector(KDChatDialogBaseCell.failButtonPressed), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    func failButtonPressed() {
        if dataInternal.record.msgPlayType == MessagePlayTypeFailue {
            return
        }
        if dataInternal.record.msgRequestState == MessageRequestStateFailue {
            if dataInternal.record.msgType == MessageTypeSpeech && dataInternal.record.xtFilePath() == nil {
                return
            }
//            UIAlertView.showWithTitle("重发该消息", message: "", cancelButtonTitle: "取消", otherButtonTitles: ["重发"], tapBlock: { (alertView, number) in
//                if number != 0 {
//                    self.dataInternal.record.isResend = true
//                    self.dataInternal.record.msgRequestState = MessageRequestStateRequesting
//                    self.chatVC.sendWithRecord(self.dataInternal.record)
//                    KDEventAnalysis.event(event_msg_resend)
//                    self.updateCell(self.chatVC, tableView: self.chatVC.bubbleTable, dataInternal: self.dataInternal)
//                }
//            })
        }
    }
    
    // MARK: 发送中风火轮
    var sendingActivityIndicatorEgde: MASConstraint?
    
    lazy var sendingActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.isHidden = true
        return indicator
    }()
    
    // MARK: 左头像
    
    lazy var leftHeadView: XTPersonHeaderView = {
        //let headView = XTPersonHeaderView(frame: CGRectMake(0.0, 0.0, 44, 44), checkStatus: false)
        let headView = XTPersonHeaderView(frame: CGRect(x: 0.0, y: 0.0, width: 44, height: 44))

        headView.personNameLabel.isHidden = true
        headView.personHeaderImageView.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        headView.isOpaque = true
        headView.delegate = self
        return headView
    }()
    
    // MARK: 右头像
    
    lazy var rightHeadView: XTPersonHeaderView = {
        //let headView = XTPersonHeaderView(frame: CGRectMake(0.0, 0.0, 44, 44), checkStatus: false)
        let headView = XTPersonHeaderView(frame: CGRect(x: 0.0, y: 0.0, width: 44, height: 44))
        headView.personNameLabel.isHidden = true
        headView.personHeaderImageView.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        headView.isOpaque = true
        headView.delegate = self
        return headView
    }()
    
    func personHeaderClicked(_ headerView: XTPersonHeaderView!, person: PersonSimpleDataModel!) {
        onPersonHeaderClicked?(person)
    }
    
    // MARK:  姓名
    
    lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.isOpaque = true
        return nameLabel
    }()
    
    class func nameLabelText(_ dataInternal: BubbleDataInternal?, chatVC: XTChatViewController?) -> NSAttributedString? {
        guard let dataInternal = dataInternal, let chatVC = chatVC
            else { return nil }
        
        func attributtedText(_ name: String?, department: String?, prefixIconName: String?) -> NSAttributedString? {
            
            guard let name = name
                else { return nil }
            
            let attri = NSMutableAttributedString()
            
            var location = 0
            
            // 图标
            if let prefixIconName = prefixIconName {
                attri.dz_insertImage(withName: prefixIconName, location: 0, bounds: CGRect(x: 0, y: -2, width: 14, height: 14))
                attri.appendString(" ")
                location += 2
            }
            
            // 姓名
            attri.appendString(name)
            attri.dz_setTextColor(FC1, range: NSMakeRange(location, name.characters.count))
            location += name.characters.count
            
            // 部门/公司名
            if let department = department {
                attri.appendString(" \(department)")
                attri.dz_setTextColor(FC2, range: NSMakeRange(location, department.characters.count + 1))
                location += department.characters.count + 1
            }
            
            attri.dz_setFont(FS6)
            return attri
        }
        
//        let personName = chatVC.personName(group: dataInternal.group, record: dataInternal.record)
//        let person = chatVC.person(group: dataInternal.group, record: dataInternal.record)
//        
//        if dataInternal.isLeft {
//            
//            if dataInternal.group.isExternalGroup() && chatVC.isExternalPerson(dataInternal.record.fromUserId) {
//                // 展示商务图标，公司名
//                return attributtedText(personName, department: person?.company?["name"] as? String, prefixIconName: "message_tip_shang_small")
//                
//            } else {
//                // 非商务组，展示部门名
//                var department: String?
//                if let myDepart = KDCacheHelper.personForKey(BOSConfig.sharedConfig().user?.userId)?.department, otherDepart = person?.department where dataInternal.group.participantCount > 10 && myDepart != otherDepart {
//                    department = person?.department
//                }
//                return attributtedText(personName, department: department, prefixIconName: nil)
//            }
//        }
        return nil
    }
    
    // MARK: 来源
    
    lazy var sourceNameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    func setSourceNameLabelWithImageName(_ imageName: String?, content: String?, textColor: UIColor, bounds: CGRect) {
        guard let content = content
            else { sourceNameLabel.attributedText = nil; return }
        let attri = NSMutableAttributedString(string: " \(content)")
        attri.dz_setFont(FS7)
        attri.dz_setTextColor(textColor)
        if KDString.isSolidString(imageName) {
            attri.dz_insertImage(withName: imageName, location: 0, bounds: bounds)
        }
        sourceNameLabel.attributedText = attri
    }
    
    // MARK: ----------- Inheritance Chain -------------
    
    override func updateCell(_ chatVC: XTChatViewController, tableView: UITableView, dataInternal: BubbleDataInternal) {
        super.updateCell(chatVC, tableView: tableView, dataInternal: dataInternal)
        
        unowned let chatVC = chatVC
        
        leftHeadView.person = nil
        rightHeadView.person = nil
        
//        onPersonHeaderClicked = { person in
//            //意见反馈的左侧不能点击
//            if !(dataInternal.group.groupType == GroupTypePublicMany && dataInternal.isLeft) {
//                KDDetail.toDetailWithPerson(person, inController: chatVC)
//            }
//        }
//        
//        let person = chatVC.person(group: dataInternal.group, record: dataInternal.record)
//        
//        if dataInternal.isLeft {
//            nameLabel.attributedText = dataInternal.nameRenderedText
//        }
//        
//        if dataInternal.isLeft {
//            leftHeadView.person = person
//        } else {
//            rightHeadView.person = person
//        }
//        
//        nameLabel.hidden = dataInternal.personNameLabelHidden
//        leftHeadView.hidden = !dataInternal.isLeft
//        rightHeadView.hidden = dataInternal.isLeft
//        leftHeadView.longPressdelegate = chatVC
//        rightHeadView.longPressdelegate = chatVC
        
        leftHeadView.mas_updateConstraints { make in
            make?.top.equalTo()(self.leftHeadView.superview!.top)?.with().offset()(dataInternal.header != nil ? 12 + 24 + 22 : 12)
        }
        rightHeadView.mas_updateConstraints { make in
            make?.top.equalTo()(self.rightHeadView.superview!.top)?.with().offset()(dataInternal.header != nil ? 12 + 24 + 22 : 12)
        }
        
        bubbleImageViewEdge?.uninstall()
        bubbleImageView.mas_updateConstraints { make in
//            if dataInternal.isLeft {
//                self.bubbleImageViewEdge = make.left.equalTo()(self.leftHeadView.right).with().offset()(10)
//            } else {
//                self.bubbleImageViewEdge =  make.right.equalTo()(self.rightHeadView.left).with().offset()(-10)
//            }
            make?.top.equalTo()(self.leftHeadView.top)?.with().offset()(!dataInternal.personNameLabelHidden ? 3 + 16 : 3)
            
        }
        
        setSourceNameLabelWithImageName(nil, content: nil, textColor: UIColor.clear, bounds: CGRect.zero)
        
        onDoubleTap = { gestureRecognizer in
//            if gestureRecognizer.state == .Recognized {
//                if dataInternal.record.msgType == MessageTypeText || dataInternal.record.msgType == MessageTypeFile || dataInternal.record.msgType == MessageTypeShareNews {
//                    
//                    var isEmoji = false
//                    if let emojiType = dataInternal.record.strEmojiType where emojiType == "original" {
//                        isEmoji = true
//                    }
//                    
//                    if !isEmoji {
//                        self.longPressManager?.mark(dataInternal, chatVC: chatVC)
//                    }
//                    
//                }
//            }
        }
        
        // 关键字点击回调, 为了TextCell和ReplyCell可以共用，所以写在父类
        if dataInternal.record.msgType == MessageTypeText {
//            onKeywordTap = { linkPrefix, keyword in
//                if keyword.characters.count > 0 {
//                    switch linkPrefix {
//                    case KDRegex.KeywordPrefix:
//                        self.popoverTask.showAt(self.bubbleImageView)
//                    case KDRegex.PhonePrefix:
//                        XTTELHandle.sharedTELHandle().telWithPhoneNumbel(keyword)
//                    case KDRegex.URLPrefix:
//                        KDSiteTester.sharedInstance().openURLString(keyword, fromViewController: chatVC, completion: {})
//                    case KDRegex.AtPrefix:
//                        var person: PersonSimpleDataModel?
//                        for personId in dataInternal.group.participantIds {
//                            person = dataInternal.group.participantForKey(personId as! String)
//                            
//                            if keyword.stringByRemovingPercentEncoding == person?.personName {
//                                KDDetail.toDetailWithPerson(person, inController: chatVC)
//                                return
//                            }
//                        }
//                        if !dataInternal.group.isExternalGroup() {
//                            if let personModel = XTDataBaseDao.sharedDatabaseDaoInstance().queryPersonWithContactName(keyword.stringByRemovingPercentEncoding) {
//                                KDDetail.toDetailWithPerson(personModel, inController: chatVC)
//                            }
//                        }
//                    default:
//                        break
//                    }
//                }
//            }
            
        }
        
        if dataInternal.record.msgRequestState == MessageRequestStateRequesting {
            sendingActivityIndicator.isHidden = false
            sendingActivityIndicator.startAnimating()
            sendingActivityIndicatorEgde?.uninstall()
            sendingActivityIndicator.mas_updateConstraints{ make in
                if dataInternal.record.msgDirection == MessageDirectionLeft {
                    self.sendingActivityIndicatorEgde = make?.left.equalTo()(self.bubbleImageView.right)?.with().offset()(8)
                } else {
                    self.sendingActivityIndicatorEgde = make?.right.equalTo()(self.bubbleImageView.left)?.with().offset()(-8)
                }
            }
        } else {
            sendingActivityIndicator.isHidden = true
            sendingActivityIndicator.stopAnimating()
        }
        
        if dataInternal.record.msgRequestState == MessageRequestStateFailue || dataInternal.record.msgPlayType == MessagePlayTypeFailue {
            failButton.isHidden = false
            failButtonIndicatorEgde?.uninstall()
            failButton.mas_updateConstraints{ make in
                if dataInternal.record.msgDirection == MessageDirectionLeft {
                    self.failButtonIndicatorEgde = make?.left.equalTo()(self.bubbleImageView.right)?.with().offset()(8)
                } else {
                    self.failButtonIndicatorEgde = make?.right.equalTo()(self.bubbleImageView.left)?.with().offset()(-8)
                }
            }
        } else {
            failButton.isHidden = true
        }
        
        tryItYourselfButton.isHidden = true
        unreadButton.isHidden = true
        if dataInternal.record.msgUnreadCount > 0 && dataInternal.group.chatAvailable() {
            
            var unreadLabelText: String?
            if dataInternal.group.groupType == GroupTypeDouble {
                unreadLabelText = "对方未读"
            } else {
                unreadLabelText = "\(dataInternal.record.msgUnreadCount)人未读"
            }
            if let unreadLabelText = unreadLabelText {
                unreadButton.setTitle(unreadLabelText, for: UIControlState())
                unreadButton.isHidden = false
                
                self.unreadButtonEgde?.uninstall()
                self.unreadButton.mas_updateConstraints{ make in
                    if self.dataInternal.record.msgDirection == MessageDirectionLeft {
                        make?.left.equalTo()(self.bubbleImageView.right)?.with().offset()(10)
                    } else {
                        make?.right.equalTo()(self.bubbleImageView.left)?.with().offset()(-10)
                    }
                }
            }
            
            tryItYourselfButton.isHidden = !(!XTSetting.shared().pressMsgUnreadTipsOrNot && dataInternal.group.groupType == GroupTypeMany)
        }        
    }
    
    
    override func setupCell() {
        super.setupCell()
        contentView.addSubview(leftHeadView)
        leftHeadView.mas_makeConstraints { make in
            make?.left.equalTo()(self.leftHeadView.superview!.left)?.with().offset()(12)
            make?.top.equalTo()(self.leftHeadView.superview!.top)?.with().offset()(12)
            make?.width.mas_equalTo()(44)
            make?.height.mas_equalTo()(44)
            return()
        }
        
        contentView.addSubview(rightHeadView)
        rightHeadView.mas_makeConstraints { make in
            make?.right.equalTo()(self.rightHeadView.superview!.right)?.with().offset()(-12)
            make?.top.equalTo()(self.rightHeadView.superview!.top)?.with().offset()(12)
            make?.width.mas_equalTo()(44)
            make?.height.mas_equalTo()(44)
            return()
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.mas_makeConstraints { make in
            make?.left.equalTo()(self.leftHeadView.right)?.with().offset()(10)
            make?.top.equalTo()(self.leftHeadView.top)?.with().offset()(0)
            make?.width.mas_equalTo()(KDChatConstants.bubbleMaxWidth)
            make?.height.mas_equalTo()(16)
            return()
        }
        
        bubbleImageView.mas_makeConstraints { make in
            self.bubbleImageViewEdge = make?.left.equalTo()(self.leftHeadView.right)?.with().offset()(10)
            make?.top.equalTo()(self.leftHeadView.top)?.with().offset()(0)
            return()
        }
        
        contentView.addSubview(sourceNameLabel)
        sourceNameLabel.mas_makeConstraints { make in
            make?.top.equalTo()(self.bubbleImageView.bottom)?.with().offset()(3)
            make?.left.equalTo()(self.bubbleImageView.left)?.with().offset()(5)
            make?.width.mas_equalTo()(KDChatConstants.bubbleMaxWidth)
            make?.bottom.equalTo()(self.sourceNameLabel.superview!.bottom)?.with().offset()(-12)?.priority()(MASLayoutPriorityDefaultLow)
            return()
        }
        
        
        contentView.addSubview(sendingActivityIndicator)
        sendingActivityIndicator.mas_makeConstraints { make in
            self.sendingActivityIndicatorEgde = make?.left.equalTo()(self.bubbleImageView.right)?.with().offset()(8)
            make?.centerY.equalTo()(self.bubbleImageView.centerY)
            return()
        }
        
        contentView.addSubview(failButton)
        failButton.mas_makeConstraints { make in
            make?.height.mas_equalTo()(24)
            make?.width.mas_equalTo()(24)
            self.failButtonIndicatorEgde = make?.left.equalTo()(self.bubbleImageView.right)?.with().offset()(8)
            make?.centerY.equalTo()(self.bubbleImageView.centerY)
            return()
        }
        
        contentView.addSubview(unreadButton)
        unreadButton.mas_makeConstraints { make in
            self.unreadButtonEgde = make?.left.equalTo()(self.bubbleImageView.right)?.with().offset()(10)
            make?.centerY.equalTo()(self.bubbleImageView.centerY)
            return()
        }
        
        contentView.addSubview(tryItYourselfButton)
        tryItYourselfButton.mas_makeConstraints { make in
            make?.bottom.equalTo()(self.unreadButton.top)?.with().offset()(-0)
            make?.centerX.equalTo()(self.unreadButton.centerX)
            return()
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        unreadButton.alpha = editing ?  0 : 1
        tryItYourselfButton.alpha = editing ? 0 : 1
//        failButton.alpha = editing ?  0 : 1
        sendingActivityIndicator.alpha = editing ?  0 : 1
    }
    
    
}
