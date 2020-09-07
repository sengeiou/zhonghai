//
//  KDSignInAdvancedSettingViewController.swift
//  kdweibo
//
//  Created by 张培增 on 2016/12/12.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

import UIKit

class KDSignInAdvancedSettingViewController: KDSignInRootViewController {
    
    fileprivate lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.kdBackgroundColor1()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
        return tableView
    }()
    
    fileprivate lazy var pickerView : KDSignInAdvancedSettingPickerView = {
        let picker = KDSignInAdvancedSettingPickerView()
        picker.isHidden = true
        return picker
    }()
    
    var advancedSettingModel : KDSignInAdvancedSettingModel = KDSignInAdvancedSettingModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = ASLocalizedString("高级设置")
        
        view.backgroundColor = UIColor .kdBackgroundColor1()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: ASLocalizedString("保存"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(saveBtnPressed(_:)))
        navigationItem.rightBarButtonItem?.setTitlePositionAdjustment(UIOffsetMake(NSNumber.kdRightItemDistance(), 0), for: UIBarMetrics.default)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: FS3, NSForegroundColorAttributeName: FC6], for: UIControlState())
        
        view.addSubview(tableView)
        tableView.mas_makeConstraints { make in
            make?.edges.mas_equalTo()(self.view)?.with().insets()(UIEdgeInsets.zero)
        }
        
        navigationController!.view.addSubview(pickerView)
        pickerView.mas_makeConstraints { make in
            make?.edges.mas_equalTo()(self.navigationController!.view)?.with().insets()(UIEdgeInsets.zero)
        }
        
        getAdvancedSettingMessage()
        
    }
 
    // MARK: - Method -
    func saveBtnPressed(_ sender: AnyObject) {
        saveAttendanceSetAdvancedMessage()
    }
    
    // MARK: - Interface -
    func getAdvancedSettingMessage() {
        KDPopup.showHUD()
        
        KDServiceActionInvoker.invokeWithSender(self, actionPath: "/signId/:getAttendanceSetAdvanced", query: nil, configBlock: nil, completionBlock: { (results , request, response) in
            if results != nil {
                KDPopup.hideHUD()
                
//                let data = results["data"]
                let resultsDic = results as? NSDictionary
                let data = resultsDic?["data"] as? [String: AnyObject]
                
                let model = KDSignInAdvancedSettingModel(dict: data)
                
                self.advancedSettingModel = model
                
                self.tableView.reloadData()
            } else {
                KDPopup.showHUDToast(ASLocalizedString("获取高级设置信息失败"))
            }
        })
        
        
        //签到迁移，暂时屏蔽
//        let request = KDGetAttendanceSetAdvancedRequest()
//        request.startCompletionBlockWithSuccess({ (request: KDRequest?) -> Void in
//            
//                guard let model = request?.resultModel as? KDSignInAdvancedSettingModel else {
//                    KDPopup.showHUDToast(ASLocalizedString("获取高级设置信息失败"))
//                    return
//                }
//            
//                KDPopup.hideHUD()
//                self.advancedSettingModel = model
//                self.tableView.reloadData()
//            
//            }, failure: { request in
//                KDPopup.showHUDToast(ASLocalizedString("获取高级设置信息失败"))
//        })
        
    }
    
    func saveAttendanceSetAdvancedMessage() {
        KDPopup.showHUD()
        
        let dict: NSMutableDictionary = NSMutableDictionary()
        dict.setObject(NSNumber(value: advancedSettingModel.lateTime as Int), forKey: "lateTime" as NSCopying)
        dict.setObject(NSNumber(value: advancedSettingModel.earlyLeaveTime as Int), forKey: "earlyLeaveTime" as NSCopying)
        dict.setObject(NSNumber(value: advancedSettingModel.range as Int), forKey: "range" as NSCopying)
        dict.setObject(NSNumber(value: advancedSettingModel.isFlexibleAttendance as Bool), forKey: "flexibleAtt" as NSCopying)
        
        if advancedSettingModel.isFlexibleAttendance == true {
            dict.setObject(NSNumber(value: advancedSettingModel.flexibleLateTime as Int), forKey: "flexibleLateTime" as NSCopying)
            dict.setObject(NSNumber(value: advancedSettingModel.flexibleWorkHours as Double), forKey: "flexibleWorkHours" as NSCopying)
        }
        
        if advancedSettingModel.settingId != "" {
            dict.setObject(advancedSettingModel.settingId, forKey: "id" as NSCopying)
        }
        
        let jsonData  = try! JSONSerialization.data(withJSONObject: dict)
        let jsonStr = String(data: jsonData, encoding: String.Encoding.utf8)
        
        let query = KDQuery()
        query.setParameter("jsonParam", stringValue: jsonStr)
        
        KDServiceActionInvoker.invokeWithSender(self, actionPath: "/signId/:saveAttendanceSetAdvanced", query: query, configBlock: nil) { (results , request, response ) in
            if results != nil {
                KDPopup.showHUDSuccess(ASLocalizedString("保存成功"))
                delay(1, {
                    self.navigationController?.popViewController(animated: true)
                })
            } else {
                KDPopup.showHUDSuccess(ASLocalizedString("保存失败"))
            }
        }
        
        //签到迁移，暂时屏蔽
//        let request = KDSaveAttendanceSetAdvancedRequest(jsonParam: jsonStr)
//        request.startCompletionBlockWithSuccess({ (request: KDRequest?) -> Void in
//            
//                KDPopup.showHUDSuccess(ASLocalizedString("保存成功"))
//                delay(1, {
//                    self.navigationController?.popViewControllerAnimated(true)
//                })
//            
//            }, failure: { request in
//                KDPopup.showHUDToast(ASLocalizedString("保存失败"))
//        })
        
    }
    
}

extension KDSignInAdvancedSettingViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || (section == 2 && advancedSettingModel.isFlexibleAttendance) {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "advancedSettingCell") as? KDSignInAdvancedSettingCell
            
            if cell == nil {
                cell = KDSignInAdvancedSettingCell(style: .default, reuseIdentifier: "advancedSettingCell")
                cell!.selectionStyle = .none
            }
            
            if indexPath.row == 0 {
                cell!.kd_contentView.kd_textLabel.text = ASLocalizedString("迟到")
                cell!.leftLabel.text = ASLocalizedString("上班后")
                cell!.timeBtn.setTitle(String(advancedSettingModel.lateTime) + ASLocalizedString("分钟"), for: UIControlState())
                cell!.rightLabel.text = ASLocalizedString("为迟到")
                cell!.btnBlock = {
                    self.pickerView.dataType = 1
                    self.pickerView.setTitle(String(self.advancedSettingModel.lateTime))
                    self.pickerView.isHidden = false
                    self.pickerView.confirmBlock = { [weak self] title in
                        self?.advancedSettingModel.lateTime = Int(title!)!
                        cell!.timeBtn.setTitle(title! + ASLocalizedString("分钟"), for: UIControlState())
                    }
                }
            }
            else if indexPath.row == 1 {
                cell!.kd_contentView.kd_textLabel.text = ASLocalizedString("早退")
                cell!.leftLabel.text = ASLocalizedString("下班前")
                cell!.timeBtn.setTitle(String(advancedSettingModel.earlyLeaveTime) + ASLocalizedString("分钟"), for: UIControlState())
                cell!.rightLabel.text = ASLocalizedString("为早退")
                cell!.btnBlock = {
                    self.pickerView.dataType = 1
                    self.pickerView.setTitle(String(self.advancedSettingModel.earlyLeaveTime))
                    self.pickerView.isHidden = false
                    self.pickerView.confirmBlock = { [weak self] title in
                        self?.advancedSettingModel.earlyLeaveTime = Int(title!)!
                        cell!.timeBtn.setTitle(title! + ASLocalizedString("分钟"), for: UIControlState())
                    }
                }
            }
            
            if advancedSettingModel.isFlexibleAttendance {
                cell!.changeAlpha(false)
                cell!.btnBlock = nil
            }
            else {
                cell!.changeAlpha(true)
            }
            
            return cell!
        }
        else if indexPath.section == 1 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "advancedSettingCell") as? KDSignInAdvancedSettingCell
            
            if cell == nil {
                cell = KDSignInAdvancedSettingCell(style: .default, reuseIdentifier: "advancedSettingCell")
                cell!.selectionStyle = .none
            }
            
            cell!.kd_contentView.kd_textLabel.text = ASLocalizedString("最早签到时间")
            cell!.leftLabel.text = ASLocalizedString("可提前")
            cell!.timeBtn.setTitle(String(advancedSettingModel.range) + ASLocalizedString("分钟"), for: UIControlState())
            cell!.rightLabel.text = ASLocalizedString("签到")
            cell!.btnBlock = {
                self.pickerView.dataType = 2
                self.pickerView.setTitle(String(self.advancedSettingModel.range))
                self.pickerView.isHidden = false
                self.pickerView.confirmBlock = { [weak self] title in
                    self?.advancedSettingModel.range = Int(title!)!
                    cell!.timeBtn.setTitle(title! + ASLocalizedString("分钟"), for: UIControlState())
                }
            }
            
            return cell!
        }
        else if indexPath.section == 2 {
            if indexPath.row == 0 {
                var cell = tableView.dequeueReusableCell(withIdentifier: "signInSettingCell") as? KDSignInSettingCell
                if cell == nil {
                    cell = KDSignInSettingCell(style: UITableViewCellStyle.default, reuseIdentifier: "signInSettingCell")
                    cell!.kd_contentView.install(cell!.contentView, style: KDListStyle.ls7)
                    cell!.addAccessorySwitch()
                    cell!.selectionStyle = UITableViewCellSelectionStyle.none
                    cell!.kd_contentView.kd_separatorLine.isHidden = true
                }
                cell!.kd_contentView.kd_textLabel.text = ASLocalizedString("弹性考勤")
                cell!.setSwitchStatus(advancedSettingModel.isFlexibleAttendance)
                cell!.switchDidClickedBlock = {
                    self.advancedSettingModel.isFlexibleAttendance = !self.advancedSettingModel.isFlexibleAttendance
                    self.tableView.reloadData()
                }
                return cell!
            }
            else {
                var cell = tableView.dequeueReusableCell(withIdentifier: "advancedSettingCell") as? KDSignInFlexibleAttendanceCell
                
                if cell == nil {
                    cell = KDSignInFlexibleAttendanceCell(style: .default, reuseIdentifier: "advancedSettingCell")
                    cell!.selectionStyle = .none
                }
                
                cell!.lateTimeBtn.setTitle(String(advancedSettingModel.flexibleLateTime) + ASLocalizedString("分钟"), for: UIControlState())
                cell!.workingHoursBtn.setTitle(String(Int(advancedSettingModel.flexibleWorkHours)) + ASLocalizedString("小时"), for: UIControlState())
                cell!.buttonBlock = { index in
                    if index == 0 {
                        self.pickerView.dataType = 1
                        self.pickerView.setTitle(String(self.advancedSettingModel.flexibleLateTime))
                        self.pickerView.confirmBlock = { [weak self] title in
                            self?.advancedSettingModel.flexibleLateTime = Int(title!)!
                            cell!.lateTimeBtn.setTitle(title! + ASLocalizedString("分钟"), for: UIControlState())
                        }
                    }
                    else if index == 1 {
                        self.pickerView.dataType = 3
                        self.pickerView.setTitle(String(Int(self.advancedSettingModel.flexibleWorkHours)))
                        self.pickerView.confirmBlock = { [weak self] title in
                            self?.advancedSettingModel.flexibleWorkHours = Double(title!)!
                            cell!.workingHoursBtn.setTitle(title! + ASLocalizedString("小时"), for: UIControlState())
                        }
                    }
                    
                    self.pickerView.isHidden = false
                }
                
                return cell!
            }
        }
        
        let cell = KDTableViewCell(style: .default, reuseIdentifier: "cell")
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NSNumber.kdDistance2()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
