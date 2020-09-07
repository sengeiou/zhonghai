//
//  KDChatBaseCell.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/24.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

@objc class KDChatAbstractCell: UITableViewCell {
    
    var dataInternal: BubbleDataInternal!
    weak var chatVC: XTChatViewController!
    
    /**
     初始化方法，用于写布局，写在里面的代码调用一次
     */
    func setupCell() {}
    
    /**
     更新方法，用于更新页面布局和给当前的数据，会在cell每次展现前调用
     */
    func updateCell(_ chatVC: XTChatViewController, tableView: UITableView, dataInternal: BubbleDataInternal) {}
    
    /**
     手势，一般在updateCell中调用，把closure指定为你需要的回调即可，如需要继承就要多调super.onTap(gestureRecognizer)
     */
    var onTap: ((_ gestureRecognizer: UITapGestureRecognizer) -> Void)?
    var onDoubleTap: ((_ gestureRecognizer: UITapGestureRecognizer) -> Void)?
    var onLongPress: ((_ gestureRecognizer: UILongPressGestureRecognizer) -> Void)?
    
    /**
     按下效果，用户手指按住cell，页面元素的背景色可能需要变化, 这里还拿不到dataInternal，chatVC
     */
    override func setHighlighted(_ highlighted: Bool, animated: Bool) { super.setHighlighted(highlighted, animated: animated) }
    
    /* --------- 子cell最低配备, updateBubbleImage若无即为无气泡图 -----------
     
     override func setupCell() {
     super.setupCell()
     
     }
     
     override func updateCell(chatVC: XTChatViewController, tableView: UITableView, dataInternal: BubbleDataInternal) {
     super.updateCell(chatVC, tableView: tableView, dataInternal: dataInternal)
     updateBubbleImage(bubbleImageView, direction: dataInternal.record.msgDirection, blueBorder: true)
     
     }
     
     */
    
}

class KDChatBaseCell: KDChatAbstractCell {
    
    var bubbleImageViewEdge: MASConstraint?
    var dir: MessageDirection = MessageDirectionLeft
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: 时间
    lazy var bubbleTitleLabel: BubbleTitleLabel  = {
        let bubbleTitleLabel = BubbleTitleLabel()
        bubbleTitleLabel.textAlignment = .center
        bubbleTitleLabel.isOpaque = true
        bubbleTitleLabel.bHideLines = true
        return bubbleTitleLabel
    }()
    
    
    // MARK: 气泡
    
    lazy var bubbleImageView: UIImageView = {
        let bubbleImageView = UIImageView()
        bubbleImageView.isUserInteractionEnabled = true
        bubbleImageView.backgroundColor = UIColor.clear
        return bubbleImageView
    }()

    lazy var leftReplyBubbleImagePressed: UIImage = {
        return UIImage(named: "message_bg_speak_查看原文_press")!.resizableImage(withCapInsets: UIEdgeInsetsMake(25.0, 15.0, 10.0, 15.0))
    }()
    lazy var leftReplyBubbleImage: UIImage = {
        return UIImage(named: "message_bg_查看原文_left")!.resizableImage(withCapInsets: UIEdgeInsetsMake(25.0, 15.0, 10.0, 15.0))
    }()

    lazy var leftOtherBubbleImage: UIImage = {
        return UIImage(named: "message_bg_speak_left")!.resizableImage(withCapInsets: UIEdgeInsetsMake(25.0, 15.0, 10.0, 15.0))
    }()
    
    lazy var leftOtherBubbleImagePressed: UIImage = {
        return UIImage(named: "message_bg_speak_left_press")!.resizableImage(withCapInsets: UIEdgeInsetsMake(25.0, 15.0, 10.0, 15.0))
    }()
    
    lazy var rightOtherBubbleImage: UIImage = {
        return UIImage(named: "message_bg_other_right")!.resizableImage(withCapInsets: UIEdgeInsetsMake(25.0, 15.0, 10.0, 15.0))
    }()
    
    lazy var rightOtherBubbleImagePressed: UIImage = {
        return UIImage(named: "message_bg_speak_查看原文_press")!.resizableImage(withCapInsets: UIEdgeInsetsMake(25.0, 15.0, 10.0, 15.0))
    }()
    
    lazy var leftDialogBubbleImage: UIImage = {
        return UIImage(named: "message_bg_speak_left")!.resizableImage(withCapInsets: UIEdgeInsetsMake(25.0, 15.0, 10.0, 15.0))
    }()
    
    lazy var leftDialogBubbleImagePressed: UIImage = {
        return UIImage(named: "message_bg_speak_left_press")!.resizableImage(withCapInsets: UIEdgeInsetsMake(25.0, 15.0, 10.0, 15.0))
    }()
    
    lazy var rightDialogBubbleImage: UIImage = {
        return UIImage(named: "message_bg_speak_right")!.resizableImage(withCapInsets: UIEdgeInsetsMake(25.0, 15.0, 10.0, 15.0))
    }()
    
    lazy var rightDialogBubbleImagePressed: UIImage = {
        return UIImage(named: "message_bg_speak_right_press")!.resizableImage(withCapInsets: UIEdgeInsetsMake(25.0, 15.0, 10.0, 15.0))
    }()

    func updateBubbleImage(_ view: UIImageView, direction: MessageDirection, blueBorder: Bool, replyMessage: Bool = false) {
        dir = direction
        let isLeft = direction == MessageDirectionLeft
        if replyMessage {
            view.image = isLeft ? leftReplyBubbleImage : rightDialogBubbleImage
            view.highlightedImage = isLeft ? leftReplyBubbleImagePressed : rightDialogBubbleImagePressed
        } else {
            if blueBorder {
                view.image = isLeft ? leftOtherBubbleImage : rightOtherBubbleImage
                view.highlightedImage = isLeft ? leftOtherBubbleImagePressed : rightOtherBubbleImagePressed
            } else {
                view.image = isLeft ? leftDialogBubbleImage : rightDialogBubbleImage
                view.highlightedImage = isLeft ? leftDialogBubbleImagePressed : rightDialogBubbleImagePressed
            }
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
//        if !editing {
//            bubbleImageView.highlighted = highlighted
//        }
//        
//        if highlighted && bubbleTitleLabel.text != KDChatConstants.bubbleTitleNewMessages {
//            bubbleTitleLabel.backgroundColor = UIColor(hexRGB: "cfd6e2")
//        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
//        if selected && bubbleTitleLabel.text != KDChatConstants.bubbleTitleNewMessages {
//            bubbleTitleLabel.backgroundColor = UIColor(hexRGB: "cfd6e2")
//        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        contentView.isUserInteractionEnabled = !editing
    }
    
    // MARK: 长按菜单
    
//    var longPressManager: KDChatLongPressManager?
//    
//    lazy var popover: KDMenuPopover = {
//        let popover = KDMenuPopover()
//        popover.dataSource = self
//        return popover
//    }()
//    
//    lazy var popoverTask: KDMenuPopover = {
//        let popover = KDMenuPopover()
//        popover.dataSource = self
//        return popover
//    }()
//    
//    func itemCountForRow() -> Int {
//        return 5
//    }
//    
//    func itemModels(popover: KDMenuPopover) -> [KDItem] {
//        if let longPressManager = longPressManager {
//            if self.popover == popover {
//                return longPressManager.normalChatItems(bubbleImageView, dataInternal: dataInternal, chatVC: chatVC, cell: self)!
//            } else {
//                return longPressManager.taskChatItems(bubbleImageView, dataInternal: dataInternal, chatVC: chatVC)!
//            }
//        } else {
//            return []
//        }
//    }
    
    
    // MARK: ---------- Inheritance Chain ----------
    
    override func updateCell(_ chatVC: XTChatViewController, tableView: UITableView, dataInternal: BubbleDataInternal) {
        self.dataInternal = dataInternal
        self.chatVC = chatVC
        bubbleTitleLabel.text = dataInternal.header
//        longPressManager = KDChatLongPressManager(group: dataInternal.group, record: dataInternal.record)
//        longPressManager?.chatVC = chatVC
//        if dataInternal.header != nil {
//            if dataInternal.header == KDChatConstants.bubbleTitleNewMessages {
//                bubbleTitleLabel.font = FS6
//                bubbleTitleLabel.textColor = FC2
//                bubbleTitleLabel.layer.cornerRadius = 0
//                bubbleTitleLabel.layer.masksToBounds = false
//                bubbleTitleLabel.bHideLines = false
//                bubbleTitleLabel.backgroundColor = UIColor.clearColor()
//            } else {
//                bubbleTitleLabel.font = FS8
//                bubbleTitleLabel.textColor = FC6
//                bubbleTitleLabel.layer.cornerRadius =  6
//                bubbleTitleLabel.layer.masksToBounds = true
//                bubbleTitleLabel.bHideLines = true
//                bubbleTitleLabel.backgroundColor = UIColor(hexRGB: "cfd6e2")
//            }
//            bubbleTitleLabel.textAlignment = .Center
//        }
        
        bubbleTitleLabel.mas_updateConstraints{ make in
            if dataInternal.header != nil {
                self.bubbleTitleLabel.isHidden = false
                make?.height.mas_equalTo()(22)
                if dataInternal.header == KDChatConstants.bubbleTitleNewMessages {
                    make?.width.mas_equalTo()(self.bubbleTitleLabel.intrinsicContentSize.width)
                } else {
                    make?.width.mas_equalTo()(self.bubbleTitleLabel.intrinsicContentSize.width + 16)
                }
            } else {
                self.bubbleTitleLabel.isHidden = true
                make?.height.mas_equalTo()(0)
            }
        }
        
        onLongPress = { gestureRecognizer in
            if (gestureRecognizer.state == .began) {
                self.isHighlighted = true
                self.showPopoverAt(self.bubbleImageView) {
                    self.isHighlighted = false
                }
            }
        }
        
    }
    
    func showPopoverAt(_ view: UIView, completion: () -> Void = {}) {
        //发送中或者接收中, 系统消息，不可长按
        if dataInternal.record.msgRequestState == MessageRequestStateRequesting || dataInternal.record.msgType == MessageTypeSystem {
            return
        }
        chatVC.view.endEditing(false)
        chatVC.hideInputBoard()
//        KDEventAnalysis.event(bubble_long_press)
//        popover.showAt(view)
//        popover.dxPopover.didShowHandler = {
//            completion()
//        }
    }
    

    
    override func setupCell() {
        
        contentView.addSubview(bubbleTitleLabel)
        bubbleTitleLabel.isHidden = true
        bubbleTitleLabel.mas_makeConstraints { make in
            make?.centerX.equalTo()(self.bubbleTitleLabel.superview!.centerX)
            make?.top.equalTo()(self.bubbleTitleLabel.superview!.top)?.with().offset()(12)
            make?.width.mas_equalTo()(0)
            make?.height.mas_equalTo()(0)
            return()
        }
        
        contentView.addSubview(bubbleImageView)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(KDChatDialogBaseCell.onBubbleImageViewTapGesture(_:)))
        bubbleImageView.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(KDChatDialogBaseCell.onBubbleImageViewDoubleTapGesture(_:)))
        doubleTap.numberOfTapsRequired = 2
        bubbleImageView.addGestureRecognizer(doubleTap)
        
        singleTap.require(toFail: doubleTap)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(KDChatDialogBaseCell.onBubbleImageViewLongPressGesture(_:)))
        bubbleImageView.addGestureRecognizer(longPress)
    }
    
    // MARK: 手势； 由子类实现各自的手势效果, 只需给相应block赋值
    
    func onBubbleImageViewTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        onTap?(gestureRecognizer)
    }
    
    func onBubbleImageViewDoubleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        onDoubleTap?(gestureRecognizer)
    }
    
    func onBubbleImageViewLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        onLongPress?(gestureRecognizer)
    }
    
    
    
}

