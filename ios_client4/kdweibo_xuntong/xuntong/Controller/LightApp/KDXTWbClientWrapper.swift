//
//  KDXTWbClientWrapper.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/6/21.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//


class KDXTWbClientWrapper: KDClientWrapper {
    
    static let sharedInstance = KDXTWbClientWrapper()
    
//    lazy var stowFileClient: XTWbClient = XTWbClient(target: self, action: #selector(KDXTWbClientWrapper.stowFileDidReceived(_:result:)))
//    var stowFileCompletion: BOSConnectCompletion?
//    @objc func stowFile(fileId: String?, completion: BOSConnectCompletion?) {
//        guard let fileId = fileId
//            else { return }
//        stowFileCompletion = completion;
////        _ = KDPopup.showHUD(inView:UIApplication.sharedApplication().getTopView())
//        stowFileClient.stowFile(fileId)
//    }
//    @objc func stowFileDidReceived(client: XTWbClient?, result: BOSResultDataModel?) {
//        handleCompletion(client, result: result, completion: stowFileCompletion)
//    }
    
//    lazy var markDocMessageClient: XTWbClient = XTWbClient(target: self, action: #selector(KDXTWbClientWrapper.markDocMessageDidReceived(_:result:)))
//    var markDocCompletion: BOSConnectCompletion?
//    @objc func markDoc(fileId: String?, userId: String?, messageId: String?, networkId: String?, threadId: String?,completion: BOSConnectCompletion?) {
//        guard let fileId = fileId
//            else { return }
//        markDocCompletion = completion;
//        markDocMessageClient.markDocMessage(withFileId: fileId, userId: userId, messageId: messageId, networkId: networkId, threadId: threadId)
//    }
//    @objc func markDocMessageDidReceived(_ client: XTWbClient?, result: BOSResultDataModel?) {
//        handleCompletion(client, result: result, completion: stowFileCompletion)
//    }

}
