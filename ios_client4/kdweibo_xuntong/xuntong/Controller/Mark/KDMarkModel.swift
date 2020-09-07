//
//  KDMarkModel.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/10.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

enum PagingDirectioin: Int {
    case old = 0, new
}

// 返回数据的mark类型， 1文本,2图片,3链接, 100展示引导页（客户端用）, 101空白小熊页（客户端用）
@objc enum MarkInfoType: Int32 {
    case text = 1, image, link, voice, video, location
    case guide = 100, empty
}

final class KDMarkModel: NSObject {
    // 主键id
    var id: String?
    // 消息发送人名称
    var title: String?
    // 发送者头像
    var headUrl: String?
    // 1文本,2图片,3链接
    var type: MarkInfoType = .text
    // 语音长度
    var length: String?
    // msg id
    var msgId: String?
    // 文本或者链接中的内容
    var text: String?
    // 本地供显示的富文本，不入库
    var renderedText: NSMutableAttributedString?
    // type 2图片类型的图片url
    var imgUrl: String?
    // type 3 链接内容的icon url
    var icon: String?
    // type 3 链接内容标题
    var header: String?
    // 跳转的scheme
    var uri: String?
    // 修改时间
    var updateTime: String?
    // 消息：消息的组名 待办：待办通知
    var titleDesc: String?
    var humanReadableUpdateTime: String?
    
    var localEventId: String?   // 本地日历事件id
    
    var appid: String?
    
    override init() {
        super.init()
    }
    
    convenience init(dict: [String: AnyObject]?) {
        self.init()
        guard let dict = dict
            else { return }
        dz_bindStringValue(fromDict: dict, toObj: self, withKey: "id")
        dz_bindStringValue(fromDict: dict, toObj: self, withKey: "title")
        dz_bindStringValue(fromDict: dict, toObj: self, withKey: "headUrl")
        dz_bindStringValue(fromDict: dict, toObj: self, withKey: "titleDesc")

        if let updateTimeDict = dict["updateTime"] as? [String: AnyObject] {
            if let time = updateTimeDict["time"] {
                updateTime = String(describing: time)
                if let updateTime = updateTime, let timeInterval = TimeInterval(updateTime) {
                    humanReadableUpdateTime = KDDate.humanReadableDateFrom1970(timeInterval)
                }
            }
        } else {
            if let updateTimeNumber = dict["updateTime"] {
                updateTime = String(describing: updateTimeNumber)
                if let updateTime = updateTime, let timeInterval = TimeInterval(updateTime) {
                    humanReadableUpdateTime = KDDate.humanReadableDateFrom1970(timeInterval)
                }
            }
        }

        if let media = dict["media"] as? [String: AnyObject] {
            if let value = media["type"] {
                let strValue = "\(value)"
                if let intValue = Int(strValue) {
                    if intValue == 1 {
                        type = .text
                    }
                    if intValue == 2 {
                        type = .image
                    }
                    if intValue == 3 {
                        type = .link
                    }
                    if intValue == 4 {
                        type = .voice
                    }
                    if intValue == 5 {
                        type = .video
                    }
                    if intValue == 6 {
                        type = .location
                    }
                }
            }
            dz_bindStringValue(fromDict: media, toObj: self, withKey: "length")
            dz_bindStringValue(fromDict: media, toObj: self, withKey: "text")
            dz_bindStringValue(fromDict: media, toObj: self, withKey: "imgUrl")
            dz_bindStringValue(fromDict: media, toObj: self, withKey: "icon")
            dz_bindStringValue(fromDict: media, toObj: self, withKey: "header")
            dz_bindStringValue(fromDict: media, toObj: self, withKey: "uri")
            dz_bindStringValue(fromDict: media, toObj: self, withKey: "msgId")
            dz_bindStringValue(fromDict: media, toObj: self, withKey: "appid")
        }
    }
    
    class func onSetEvent(_ viewController: UIViewController?, model: KDMarkModel?) {
        guard let viewController = viewController, let model = model
            else { return }
        KDCalendar.sharedInstance.requestAccess({ (succ) in
            if succ {
                let vc = KDMarkDatePickerVC(model: model)
                viewController.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = KDMarkGuideVC()
                viewController.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
    
    class func gotoH5Guide(_ vc: UIViewController?) {
        guard let vc = vc
            else { return }
        var urlString = ""
        var runOnceFlag = ""
        if KDKingdeeConfig.sharedInstance.isKingdeeCompany() {
            urlString = "im/mark/indexGuide.html"
            runOnceFlag = kMarkH5GuideOnceFlagKingdee
        } else {
            urlString = "/im/mark/todoGuide.html"
            runOnceFlag = kMarkH5GuideOnceFlag
        }
        KDUserDefaults.sharedInstance().runOnce(withFlag: runOnceFlag) {
            let webVC = KDWebViewController(urlString:URL(string: KDConfigurationContext.getCurrent().getDefaultPlistInstance().getServerBaseURL())?.appendingPathComponent(urlString).absoluteString)
            //已废弃
            webVC?.title = "消息标记引导"
            vc.navigationController?.pushViewController(webVC!, animated: true)
        }
    }
}
