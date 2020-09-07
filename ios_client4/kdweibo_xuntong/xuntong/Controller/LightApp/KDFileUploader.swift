//  KDFileUploader.swift
//  kdweibo
//
//  Created by Darren Zheng on 2016/11/29.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

import Foundation

@objc class KDFileUploader: NSObject {
    
    /// 文件上传服务
    ///
    /// - Parameters:
    ///   - fileDict: [文件名: 二进制数据]
    ///   - completion: succ: 成功与否 files: 上传结果集合
    class func kd_uploadFiles(_ fileDict: [String: Any]?, completion: ((_ succ: Bool, _ files: [DocumentFileModel]?) -> Void)?) {
        guard let fileDict = fileDict, let wbNetworkId = BOSConfig.shared().user?.wbNetworkId, let userId = BOSConfig.shared().user?.userId
            else { return }
        var handler: KDUploadHandler? = KDUploadHandler()
        var uploadPhotoClient: XTWbClient? = XTWbClient(target: handler, action: #selector(KDUploadHandler.uploadPhotoDidReceive(_:result:)))
        uploadPhotoClient?.uploadFile(withNetworkId: wbNetworkId, userId: userId, fileDict: fileDict)
        handler?.onUpload = { succ, files in
            handler = nil
            uploadPhotoClient = nil
            completion?(succ, files)
        }
    }
}

class KDUploadHandler: NSObject {
    
    var onUpload:((_ succ: Bool, _ files: [DocumentFileModel]?) -> Void)?
    
    func uploadPhotoDidReceive(_ client: XTWbClient, result: BOSResultDataModel?) {
        guard let onUpload = onUpload
            else { return }
        guard let result = result, let dataArray = result.data as? [NSDictionary], !client.hasError && result.success
            else { onUpload(false, nil); return }
        var results = [DocumentFileModel]()
        dataArray.forEach { results += [DocumentFileModel(dictionary: $0 as! [AnyHashable: Any])] }
        onUpload(true, results)
    }
}
