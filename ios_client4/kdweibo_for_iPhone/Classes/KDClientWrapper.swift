//
//  KDClientWrapper.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/4/2.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

/// 对于各种BOSConnect的子类xxClient的封装，一个client一个扩展
/// 通过这层封装解决两件事：1，block回调代替target-action 2，统一处理了回调的常规防御

class KDClientWrapper: NSObject {
    
    typealias BOSConnectCompletion = (_ succ: Bool, _ errorMsg: String?, _ data: AnyObject?) -> Void
    func handleCompletion(_ client: BOSConnect?, result: BOSResultDataModel?, completion: BOSConnectCompletion?) {
        guard let completion = completion
            else { return }
        guard let client = client, let result = result
            else { completion(false, nil, nil); return }
        if result.responds(to: #selector(getter: BOSResultDataModel.success)) {
            guard !client.hasError && result.success
                else { completion(false, result.error, nil); return }
            var data: AnyObject? = nil
            if result.data == nil {
                data = nil
            } else {
                data = result.data as AnyObject
            }
            completion(true, nil, data)
        } else {
            guard !client.hasError
                else { completion(false, result.error, nil); return }
            completion(true, nil, result)
        }
    }
    
}

