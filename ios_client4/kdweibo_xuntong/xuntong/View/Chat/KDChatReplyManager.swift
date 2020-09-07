//
//  KDChatReplyManager.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/3/15.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

final class KDChatReplyManager: NSObject {
    
    static let sharedInstance = KDChatReplyManager()
    let lineColorLeft = UIColor(hex: 0xcfd5df)
    let lineColorRight = UIColor(hex: 0xa0ddff)
    let replyTextColorRight = UIColor(hex: 0xbae7ff)
    let replyTextColorLeft = UIColor(hex: 0xa9a9a9a)
    
}

extension KDChatReplyManager {
    
    func replyBottomContent(_ record: RecordDataModel?) -> String? {
        guard let paramModel = paramModel(record), let content = record?.content
            else { return nil }
        if let replyName = paramModel.replyPersonName, !replyName.isEmpty{
            return "回复@\(replyName) : \(content)"
        } else {
            return "回复@** : \(content)"
        }
    }
    
    func replyMsgId(_ record: RecordDataModel?) -> String? {
        guard let paramModel = paramModel(record)
            else { return nil }
        return paramModel.replyMsgId
    }
    
    func replyPersonName(_ record: RecordDataModel?) -> String? {
        guard let paramModel = paramModel(record)
            else { return nil }
        return paramModel.replyPersonName
    }
    
    func replySummary(_ record: RecordDataModel?) -> String? {
        guard let paramModel = paramModel(record)
            else { return nil }
        return paramModel.replySummary
    }
    
    func replyContent(_ record: RecordDataModel?) -> String? {
        guard let paramModel = paramModel(record)
            else { return nil }
        return "\(paramModel.replyPersonName ?? "**") : \(paramModel.replySummary ?? " ")"
    }
    
    func isReplyMsg(_ record: RecordDataModel?) -> Bool {
        guard let paramModel = paramModel(record)
            else { return false }
        return paramModel.replyMsgId != nil && !paramModel.replyMsgId.isEmpty
    }
    
    func paramModel(_ record: RecordDataModel?) -> MessageShareTextOrImageDataModel? {
        guard let record = record, let paramModel = record.param?.paramObject as? MessageShareTextOrImageDataModel, record.msgType == MessageTypeText
            else { return nil }
        return paramModel
    }
}
