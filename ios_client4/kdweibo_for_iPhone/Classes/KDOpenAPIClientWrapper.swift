//
//  KDOpenAPIClientWrapper.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/11.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

class KDOpenAPIClientWrapper: KDClientWrapper {
    
    static let sharedInstance = KDOpenAPIClientWrapper()

    lazy var createMarkClient: KDTodoClient = KDTodoClient(target: self, action: #selector(KDOpenAPIClientWrapper.createMarkDidReceive(_:result:)))
    var createMarkCompletion: BOSConnectCompletion?
    @objc func createMark(_ markType: Int32, messageId: String?, todoId: String?, groupId: String?, appId: String?, title: String?,text: String?,url: String?,fileId: String?,icon: String?,completion: BOSConnectCompletion?) {
        createMarkCompletion = completion;
//        KDAlert.showLoading()
        createMarkClient.createMark(withMarkType: markType, messageId: messageId ?? "", todoId: todoId ?? "", groupId: groupId ?? "", appId: appId ?? "", title: title ?? "", text: text ?? "",url: url ?? "", fileId: fileId ?? "", icon: icon ?? "")//, personId: personId ?? "")
    }
    @objc func createMarkDidReceive(_ client: KDTodoClient?, result: BOSResultDataModel?) {
        handleCompletion(client, result: result, completion: createMarkCompletion)
    }
    
    lazy var deleteMarkClient: KDTodoClient = KDTodoClient(target: self, action: #selector(KDOpenAPIClientWrapper.deleteMarkDidReceive(_:result:)))
    var deleteMarkCompletion: BOSConnectCompletion?
    @objc func deleteMark(markId: String?, completion: BOSConnectCompletion?) {
        deleteMarkCompletion = completion;
//        KDAlert.showLoading()
        deleteMarkClient.deleteMark(withId: markId ?? "")//, personId: personId ?? "")
    }
    @objc func deleteMarkDidReceive(_ client: KDTodoClient?, result: BOSResultDataModel?) {
        handleCompletion(client, result: result, completion: deleteMarkCompletion)
    }
    
    lazy var queryMarkListClient: KDTodoClient = KDTodoClient(target: self, action: #selector(KDOpenAPIClientWrapper.queryMarkListDidReceive(_:result:)))
    var queryMarkListCompletion: BOSConnectCompletion?
    @objc func queryMarkList(markId: String?, pageSize: Int32, direction: Int32,completion: BOSConnectCompletion?) {
        queryMarkListCompletion = completion;
//        KDAlert.showLoading()
        queryMarkListClient.queryMarkList(withId: markId ?? "", pageSize: pageSize, direction: direction)//, personId: personId ?? "")
    }
    @objc func queryMarkListDidReceive(_ client: KDTodoClient?, result: BOSResultDataModel?) {
        handleCompletion(client, result: result, completion: queryMarkListCompletion)
    }
    
    
    lazy var createMergeListClient: KDTodoClient = KDTodoClient(target: self, action: #selector(KDOpenAPIClientWrapper.createMergeDidReceive(_:result:)))
    var createMergeCompletion: BOSConnectCompletion?
    @objc func createMerge(_ groupId: String?, msgIds: NSArray, completion: BOSConnectCompletion?) {
        createMergeCompletion = completion;
        //createMergeListClient.createMerge(withGroupId: groupId, mergeMsgIds: msgIds as [AnyObject])
        createMergeListClient.createMerge(withGroupId: groupId, mergeMsgIds: msgIds as [AnyObject])
    }
    @objc func createMergeDidReceive(_ client: KDTodoClient?, result: BOSResultDataModel?) {
        handleCompletion(client, result: result, completion: createMergeCompletion)
    }
    
    lazy var getMergeClient: KDTodoClient = KDTodoClient(target: self, action: #selector(KDOpenAPIClientWrapper.getMergeDidReceive(_:result:)))
    var  getMergeCompletion: BOSConnectCompletion?
    @objc func getMerge(_ mergeId: String?, completion: BOSConnectCompletion?) {
        getMergeCompletion = completion;
        getMergeClient.getMergeWithMergeId(mergeId)
    }
    @objc func getMergeDidReceive(_ client: KDTodoClient?, result: BOSResultDataModel?) {
        handleCompletion(client, result: result, completion: getMergeCompletion)
    }
    
    // 群公告
    lazy var createNoticeClient: KDNoticeClient = KDNoticeClient(target: self, action: #selector(KDOpenAPIClientWrapper.createNoticeDidReceive(_:result:)))
    var createNoticeCompletion: BOSConnectCompletion?
    @objc func createNotice(_ groupId: String?, title: String?, content: String?, completion: @escaping BOSConnectCompletion) {
        createNoticeCompletion = completion
        createNoticeClient.createNotice(withGroupId: groupId, title: title, content: content)
    }
    @objc func createNoticeDidReceive(_ client: KDNoticeClient?, result: BOSResultDataModel?) {
        handleCompletion(client, result: result, completion: createNoticeCompletion)
    }
    
    lazy var newestNoticeClient: KDNoticeClient = KDNoticeClient(target: self, action: #selector(KDOpenAPIClientWrapper.newestNoticeDidReceive(_:result:)))
    var newestNoticeCompletion: BOSConnectCompletion?
    @objc func newestNotice(_ groupId: String?, completion: @escaping BOSConnectCompletion) {
        newestNoticeCompletion = completion
        newestNoticeClient.newestNotice(withGroupId: groupId)
    }
    @objc func newestNoticeDidReceive(_ client: KDNoticeClient?, result: BOSResultDataModel?) {
        handleCompletion(client, result: result, completion: newestNoticeCompletion)
    }
    
    lazy var listNoticeClient: KDNoticeClient = KDNoticeClient(target: self, action: #selector(KDOpenAPIClientWrapper.listNoticeDidReceive(_:result:)))
    var listNoticeCompletion: BOSConnectCompletion?
    @objc func listNotice(_ groupId: String?, noticeId: String?, count: String?, completion: @escaping BOSConnectCompletion) {
        listNoticeCompletion = completion
        listNoticeClient.listNotice(withGroupId: groupId, noticeId: noticeId, count: count)
    }
    @objc func listNoticeDidReceive(_ client: KDNoticeClient?, result: BOSResultDataModel?) {
        handleCompletion(client, result: result, completion: listNoticeCompletion)
    }
    
    lazy var deleteNoticeClient: KDNoticeClient = KDNoticeClient(target: self, action: #selector(KDOpenAPIClientWrapper.deleteNoticeDidReceive(_:result:)))
    var deleteNoticeCompletion: BOSConnectCompletion?
    @objc func deleteNotice(_ noticeId: String?, completion: @escaping BOSConnectCompletion) {
        deleteNoticeCompletion = completion
        deleteNoticeClient.deleteNotice(withNoticeId: noticeId)
    }
    @objc func deleteNoticeDidReceive(_ client: KDNoticeClient?, result: BOSResultDataModel?) {
        handleCompletion(client, result: result, completion: deleteNoticeCompletion)
    }
    
}
