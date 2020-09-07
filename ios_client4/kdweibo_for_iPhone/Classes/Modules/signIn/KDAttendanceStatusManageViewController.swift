//
//  KDAttendanceStatusManageViewController.swift
//  kdweibo
//
//  Created by 张培增 on 2016/12/12.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

import UIKit

class KDAttendanceStatusManageViewController: KDSignInRootViewController {

    fileprivate lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor .kdBackgroundColor1()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
        return tableView
    }()

    let textArray : NSArray = [ASLocalizedString("开启后,员工的迟到、早退、未签到状态需要负责人确认"), ASLocalizedString("开启后,员工外勤签到需要负责人确认")]

    var isExceptionFeedbackOn : Bool = false
    var isOutWorkFeedbackOn : Bool = false
    
    override func loadView() {
        super.loadView()
        
        getFeedbackSettingFlag()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor .kdBackgroundColor1()
        title = ASLocalizedString("考勤状态管理")
        
        view.addSubview(tableView)
        tableView.mas_makeConstraints { make in
            make?.edges.mas_equalTo()(self.view)?.with().insets()(UIEdgeInsets.zero)
        }
    }
    
    // MARK: - Interface -
    func getFeedbackSettingFlag() {
        KDPopup.showHUD()
        
        KDServiceActionInvoker.invokeWithSender(self, actionPath: "/signId/:getSignInFeedbackSetting", query: nil, configBlock: nil, completionBlock: { (results , request, response) in
            let statusCode = response?.statusCode()
            if statusCode == 200 {
                KDPopup.hideHUD()
                let resultsDic = results as? NSDictionary
                let data = resultsDic?["data"] as? [String: AnyObject]
//                let data = results["data"]
                if let isExceptionFeedbackOn = data?["isExceptionFeedbackOn"] as? Bool , let isOutWorkFeedbackOn = data?["isOutWorkFeedbackOn"] as? Bool {
                    self.isExceptionFeedbackOn = isExceptionFeedbackOn
                    self.isOutWorkFeedbackOn = isOutWorkFeedbackOn
                    self.tableView.reloadData()
                }
//                self.isExceptionFeedbackOn = data.bool(forKey: "isExceptionFeedbackOn", defaultValue: false)
//                self.isOutWorkFeedbackOn = data.bool(forKey: "isOutWorkFeedbackOn", defaultValue: false)
                self.tableView.reloadData()
                
            } else {
                KDPopup.showHUDToast(ASLocalizedString("获取考勤状态信息失败"))
            }
        })
        
        
        //签到迁移，暂时屏蔽
//        let request = KDGetSignInFeedbackSettingRequest()
//        request.startCompletionBlockWithSuccess({ (request: KDRequest?) -> Void in
//            
//                guard let data = request?.response.responseObject as? NSDictionary else {
//                    KDPopup.showHUDToast(ASLocalizedString("获取考勤状态信息失败"))
//                    return
//                }
//            
//                KDPopup.hideHUD()
//                self.isExceptionFeedbackOn = data.boolForKey("isExceptionFeedbackOn", defaultValue: false)
//                self.isOutWorkFeedbackOn = data.boolForKey("isOutWorkFeedbackOn", defaultValue: false)
//                self.tableView.reloadData()
//            
//            }, failure: { request in
//                KDPopup.showHUDToast(ASLocalizedString("获取考勤状态信息失败"))
//        })
        
    }
    
    func setFeedbackSettingFlag() {
        KDPopup.showHUD()
        
        let query = KDQuery()
        query.setParameter("isExceptionFeedbackOn", booleanValue: self.isExceptionFeedbackOn)
        query.setParameter("isOutWorkFeedbackOn", booleanValue: self.isOutWorkFeedbackOn)
        
        
        KDServiceActionInvoker.invokeWithSender(self, actionPath: "/signId/:setSignInFeedbackSetting", query: query, configBlock: nil) { (results, request, response ) in
            let statusCode = response?.statusCode()
            if statusCode == 200 {
                KDPopup.showHUDSuccess(ASLocalizedString("设置成功"))
            } else {
                KDPopup.showHUDSuccess(ASLocalizedString("设置失败"))
            }
        }
        
        
        //签到迁移，暂时屏蔽
//        let request = KDSetSignInFeedbackSettingRequest(isExceptionFeedbackOn: self.isExceptionFeedbackOn, isOutWorkFeedbackOn: self.isOutWorkFeedbackOn)
//        request.startCompletionBlockWithSuccess({ (request: KDRequest?) -> Void in
//            
//                KDPopup.showHUDSuccess(ASLocalizedString("设置成功"))
//            
//            }, failure: { request in
//                KDPopup.showHUDSuccess(ASLocalizedString("设置失败"))
//        })
    }
    
    // MARK: - Method -
    func calculateHeight(_ text: String) -> CGFloat {
        let size : CGSize = text.boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width - 24, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:FS7], context: nil).size
        if size.height > 15 {
            return 44
        }
        return 30
        
    }
    
    // MARK: - MemoryWarning -
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}

extension KDAttendanceStatusManageViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 44
        }
        else if indexPath.row == 1 {
            return calculateHeight(textArray[indexPath.section] as! String)
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
//        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NSNumber.kdDistance2()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                var cell = tableView.dequeueReusableCell(withIdentifier: "signInSettingCell") as? KDSignInSettingCell
                if cell == nil {
                    cell = KDSignInSettingCell(style: UITableViewCellStyle.default, reuseIdentifier: "signInSettingCell")
                    cell!.kd_contentView.install(cell!.contentView, style: KDListStyle.ls7)
                    cell!.addAccessorySwitch()
                    cell!.selectionStyle = UITableViewCellSelectionStyle.none
                }
                cell!.kd_contentView.kd_textLabel.text = ASLocalizedString("签到异常反馈确认")
                cell!.setSwitchStatus(self.isExceptionFeedbackOn)
                cell!.switchDidClickedBlock = {
                    self.isExceptionFeedbackOn = !self.isExceptionFeedbackOn
                    self.setFeedbackSettingFlag()
                }
                return cell!
            }
            else {
                let cell = KDLS8Cell(style: UITableViewCellStyle.default, reuseIdentifier: "LS8Cell")
                cell.kd_contentView.kd_textLabel.text = ASLocalizedString("开启后,员工的迟到、早退、未签到状态需要负责人确认")
                cell.kd_contentView.kd_textLabel.numberOfLines = 0
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            }
//        case 1:
//            if indexPath.row == 0 {
//                var cell = tableView.dequeueReusableCellWithIdentifier("signInSettingCell") as? KDSignInSettingCell
//                if cell == nil {
//                    cell = KDSignInSettingCell(style: UITableViewCellStyle.Default, reuseIdentifier: "signInSettingCell")
//                    cell!.kd_contentView.install(cell!.contentView, style: KDListStyle.LS7)
//                    cell!.addAccessorySwitch()
//                    cell!.selectionStyle = UITableViewCellSelectionStyle.None
//                }
//                cell!.kd_contentView.kd_textLabel.text = ASLocalizedString("外勤确认")
//                cell!.setSwitchStatus(self.isOutWorkFeedbackOn)
//                cell!.switchDidClickedBlock = {
//                    self.isOutWorkFeedbackOn = !self.isOutWorkFeedbackOn
//                    self.setFeedbackSettingFlag()
//                }
//                return cell!
//            }
//            else {
//                let cell = KDLS8Cell(style: UITableViewCellStyle.Default, reuseIdentifier: "LS8Cell")
//                cell.kd_contentView.kd_textLabel.text = ASLocalizedString("开启后,员工外勤签到需要负责人确认")
//                cell.selectionStyle = UITableViewCellSelectionStyle.None
//                return cell
//            }
        default:
            break
        }
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        
        return cell
    }
}
