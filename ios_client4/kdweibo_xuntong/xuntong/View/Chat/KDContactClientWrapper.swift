//
//  KDContactClientWrapper.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/11.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//


// MARK: - ContactClient
class KDContactClientWrapper: KDClientWrapper {
    
    static let sharedInstance = KDContactClientWrapper()
    
    // 获取真实消息内容 xuntong/ecLite/convers/notrace/msgInfo
    lazy var getNotraceMsgInfoClient: ContactClient = ContactClient(target: self, action: #selector(KDContactClientWrapper.getNotraceMsgInfoDidReceive(_:result:)))
    var getNotraceMsgInfoCompletion: BOSConnectCompletion?
    @objc func getNotraceMsgInfo(_ groupId: String?, msgId: String?, completion: BOSConnectCompletion?) {
        guard let groupId = groupId, let msgId = msgId
            else { return }
        getNotraceMsgInfoCompletion = completion;
        KDPopup.showHUD()
        getNotraceMsgInfoClient.getNotraceMsgInfo(withGroupId: groupId, msgId: msgId)

    }
    @objc func getNotraceMsgInfoDidReceive(_ client: ContactClient?, result: BOSResultDataModel?) {
        handleCompletion(client, result: result, completion: getNotraceMsgInfoCompletion)
    }
    
    // 删除真实消息内容 xuntong/ecLite/convers/notrace/delMsg
    lazy var delNotraceMsgInfoClient: ContactClient = ContactClient(target: self, action: #selector(KDContactClientWrapper.delNotraceMsgInfoDidReceive(_:result:)))
    var deleteNotraceMsgInfoCompletion: BOSConnectCompletion?
    @objc func delNotraceMsgInfo(_ groupId: String?, msgId: String?, completion: BOSConnectCompletion?) {
        guard let groupId = groupId, let msgId = msgId
            else { return }
        deleteNotraceMsgInfoCompletion = completion
        delNotraceMsgInfoClient.deleteNotraceMsgInfo(withGroupId: groupId, msgId: msgId)
    }
    @objc func delNotraceMsgInfoDidReceive(_ client: ContactClient?, result: BOSResultDataModel?) {
        handleCompletion(client, result: result, completion: deleteNotraceMsgInfoCompletion)
    }
    
    //获取文件消息 xuntong/ecLite/convers/getFile.action
    lazy var getFileClient: ContactClient = ContactClient(target: self, action: #selector(KDContactClientWrapper.getFileDidReceive(_:result:)))
    var getFileCompletion: BOSConnectCompletion?
    @objc func getFile(_ msgId: String?, completion: BOSConnectCompletion?) {
        guard let msgId = msgId
            else { return }
        getFileCompletion = completion
        //getFileClient.getFileWithMsgId(msgId)
        getFileClient.getFileWithMsgId(msgId, groupId: nil)
    }
    @objc func getFileDidReceive(_ client: ContactClient?, result: BOSResultDataModel?) {
        handleCompletion(client, result: result, completion: getFileCompletion)
    }
//
//    //获取公共号文件消息 xuntong/ecLite/convers/public/getFile.action
//    lazy var publicGetFileClient: ContactClient = ContactClient(target: self, action: #selector(KDContactClientWrapper.publicGetFileDidReceive(_:result:)))
//    var publicGetFileCompletion: BOSConnectCompletion?
//    @objc func publicGetFile(publicId: String?, msgId: String?, completion: BOSConnectCompletion?) {
//        guard let publicId = publicId, msgId = msgId
//            else { return }
//        publicGetFileCompletion = completion
//        publicGetFileClient.publicGetFileWithPublicId(publicId, msgId: msgId)
//    }
//    @objc func publicGetFileDidReceive(client: ContactClient?, result: BOSResultDataModel?) {
//        handleCompletion(client, result: result, completion: publicGetFileCompletion)
//    }
//    
//    //发短信提醒
//    lazy var notifyUnreadUsersClient: ContactClient = ContactClient(target: self, action: #selector(KDContactClientWrapper.notifyUnreadUserseDidReceive(_:result:)))
//    var notifyUnreadUsersCompletion: BOSConnectCompletion?
//    @objc func notifyUnreadUsers(groupId: String?, msgId: String?, completion: BOSConnectCompletion?) {
//        guard let groupId = groupId, msgId = msgId
//            else { return }
//        notifyUnreadUsersCompletion = completion
//        notifyUnreadUsersClient.notifyUnreadUsersWithGroupId(groupId, msgId: msgId)
//    }
//    @objc func notifyUnreadUserseDidReceive(client: ContactClient?, result: BOSResultDataModel?) {
//        handleCompletion(client, result: result, completion: notifyUnreadUsersCompletion)
//    }
    
    
}
