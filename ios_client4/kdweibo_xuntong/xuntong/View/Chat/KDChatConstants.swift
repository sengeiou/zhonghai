//
//  KDChatConstants.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/23.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

class KDChatConstants: NSObject {
    
    static let bubbleTitleNewMessages = "———————  以下为新消息  ———————"
    static let bubbleMaxWidth = KDFrame.screenWidth() - (12 + 44 + 10) * 2
    static let newsContentMaxWidth: CGFloat = KDFrame.screenWidth() - (12 + 12) * 2
    static let bubbleContentLabelMaxWidth = bubbleMaxWidth - 16
    static let sourceNameFromPC = "来自桌面端"
    static let leftHighlightColor = UIColor(hexRGB: "e5e5e5")
    static let rightHighlightColor = UIColor(hexRGB: "36a7e5")
    static let newsPicHeight = (KDFrame.screenWidth() - 24) * 5/9.0
}
