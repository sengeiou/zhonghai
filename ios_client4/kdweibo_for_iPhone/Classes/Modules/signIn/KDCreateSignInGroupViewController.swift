//
//  KDCreateSignInGroupViewController.swift
//  kdweibo
//
//  Created by 张培增 on 2016/12/2.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

import UIKit

class KDCreateSignInGroupViewController: UIViewController {
    
    fileprivate lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.kdBackgroundColor1()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
        return tableView
    }()
    
    fileprivate lazy var signInGroupNameCell : KDSignInSettingCell = {
        let cell = KDSignInSettingCell(style: .default, reuseIdentifier: "signInGroupNameCell")
        cell.kd_contentView.install(cell.contentView, style: KDListStyle.ls7)
        cell.addTextField()
        cell.kd_contentView.kd_textLabel.text = ASLocalizedString("签到组名称")
        cell.accessoryTextField.placeholder = ASLocalizedString("请输入签到组名称,最多20字")
        cell.accessoryTextField.text = self.signInGroupModel.groupName
        cell.accessoryTextField.delegate = self
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }()
    
    var signInGroupModel : KDSignInGroupLocalModel = {
        let model = KDSignInGroupLocalModel()
        return model
    }()
    
    var departmentCellHeight : CGFloat = 0
    
    //签到落地页：JS桥触发的用户引导
    var isFromJSBridge : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setNavigationStyle(KDNavigationStyleBlue)
        
        view.backgroundColor = UIColor .kdBackgroundColor1()
        
         navigationItem.rightBarButtonItem = UIBarButtonItem(title: ASLocalizedString("保存"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(saveBtnPressed(_:)))
         navigationItem.rightBarButtonItem?.setTitlePositionAdjustment(UIOffsetMake(NSNumber.kdRightItemDistance(), 0), for: UIBarMetrics.default)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: FS3, NSForegroundColorAttributeName: FC6], for: UIControlState())
        
        let backButton : UIButton = UIButton.backBtnInBlueNav(withTitle: "")
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        view.addSubview(tableView)
        tableView.mas_makeConstraints { make in
            make?.edges.mas_equalTo()(self.view)?.with().insets()(UIEdgeInsets.zero)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        departmentCellHeight = calculateDepartmentCellHeight()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        signInGroupNameCell.accessoryTextField.resignFirstResponder()
    }
    
// MARK: - Method -
    func calculateDepartmentCellHeight() -> CGFloat {
        guard signInGroupModel.departmentsArray.count > 0 else {
            return 0
        }
        
        var height : CGFloat = 0.0
        var maxRow : NSInteger = 1
        var maxWidth : CGFloat = 0.0
        
        for model in signInGroupModel.departmentsArray {
            let text = model.departmentName
            let size : CGSize = text.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:FS4], context: nil).size
            model.itemWidth = ceil(size.width + 56 > UIScreen.main.bounds.size.width - 24 ? UIScreen.main.bounds.size.width - 24 : size.width + 56)
            
            if maxWidth > 0.0 && (maxWidth + model.itemWidth > UIScreen.main.bounds.size.width - 36)  {
                maxRow += 1
                maxWidth = 0.0
            }
            maxWidth += model.itemWidth
        }
        
        height = CGFloat(Float(30 * maxRow + 12 * (maxRow - 1) + 30))
        
        return height
    }
    
    func getSourceAttSetsStr(signInPointArray array : NSArray) -> String? {
        
        if array.count < 1 {
            return nil
        }
        
        let sourceAttSets : NSMutableArray = NSMutableArray()
        for index in 0 ..< array.count {
            if let point = array.object(at: index) as? KDSignInPoint {
                sourceAttSets.add(["lng": NSNumber(value: point.lng as Double), "lat": NSNumber(value: point.lat as Double), "offset": NSNumber(value: Double( point.offset) as Double)])
            }
        }
        let jsonData  = try! JSONSerialization.data(withJSONObject: sourceAttSets)
        let jsonStr = String(data: jsonData, encoding: String.Encoding.utf8)
        return jsonStr
    }
    
    func back() {
        KDPopup.showAlert(title: ASLocalizedString("是否保存?"), message: nil, buttonTitles: [ASLocalizedString("取消"),ASLocalizedString("保存")], onTap: { (index) in
                if index == 0 {
                    self.popViewController()
                }
                else {
                    self.saveBtnPressed(UIButton())
                }
            })
    }
    
    func popViewController() {
        if !isFromJSBridge {
            for vc in self.navigationController!.viewControllers.reversed() {
                if vc.isKind(of: KDSignInGroupManageViewController.self) {
                    self.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func saveBtnPressed(_ sender: AnyObject){
        signInGroupNameCell.accessoryTextField.resignFirstResponder()
        
        if signInGroupNameCell.accessoryTextField.text == nil || signInGroupNameCell.accessoryTextField.text == "" {
            KDPopup.showAlert(title: ASLocalizedString("签到组名称不能为空"), message: nil, buttonTitles: [ASLocalizedString("确定")], onTap: nil)
            return
        }
        
        if let text = signInGroupNameCell.accessoryTextField.text, text.characters.count > 20 {
            KDPopup.showAlert(title: ASLocalizedString("签到组名称不能超过20个字"), message: nil, buttonTitles: [ASLocalizedString("确定")], onTap: nil)
            return
        }
        
        // 签到部门 和 签到个人不能同时为空
        if signInGroupModel.departmentsArray.count == 0 && signInGroupModel.usersArray.count == 0 {
            KDPopup.showAlert(title: ASLocalizedString("请添加签到人员"), message: nil, buttonTitles: [ASLocalizedString("确定")], onTap: nil)
            return
        }
        
        if signInGroupModel.signInPointsArray.count == 0 {
            KDPopup.showAlert(title: ASLocalizedString("请添加签到点"), message: nil, buttonTitles: [ASLocalizedString("确定")], onTap: nil)
            return
        }
        
        checkHasAttSetGroupForDept()
    }
    
    func createSignInGroupGuideFinish() {
        guard let rtvcs : [UIViewController] = self.navigationController!.viewControllers else {
            return;
        }
        
        let vcs : NSMutableArray = NSMutableArray(array: rtvcs)
        vcs.removeLastObject()
        vcs.removeLastObject()
        vcs.removeLastObject()
        
        let signInVC = KDSignInViewController()
        vcs.add(signInVC)
        
        let settingVC = KDSignInSettingViewController()
        vcs.add(settingVC)
        
        vcs.add(self)
        
        let vcArr : [UIViewController] = NSArray(array: vcs) as! [UIViewController]
        self.navigationController!.viewControllers = vcArr
    }
    
    fileprivate func getSignInPersonCellDetailText() -> String {
        let count = signInGroupModel.usersArray.count
        
        if count == 1 {
            return "\(signInGroupModel.usersArray[0].personName!)"
        }
        else if count == 2 {
            return "\(signInGroupModel.usersArray[0].personName!),\(signInGroupModel.usersArray[1].personName!)"
        }
        else if count > 2 {
            return "\(signInGroupModel.usersArray[0].personName!),\(signInGroupModel.usersArray[1].personName!)" + ASLocalizedString("等\(count)人")
        }
        else {
            return ""
        }
    }
    
    private func selectedPersonIds() -> [AnyObject] {
        let array = NSMutableArray()
        for model in signInGroupModel.usersArray {
            if let personArr = XTDataBaseDao.sharedDatabaseDaoInstance().queryPerson(withWbPersonIds: [model.wbUserId]), personArr.count > 0 {
                array.add((personArr[0] as AnyObject).personId)
            }
        }
        
        return array as [AnyObject]
    }
    
    private func getCheckHasAttSetGroupResult(deptsArr: [String], userIdsArr: [String]) -> String {
        
        var result = ""
        var count = 0 // 有部门或人员在其他签到组的时候,弹窗提示显示3个名称（部门名称在前,人员名称在后）
        
        for deptId in deptsArr {
            if count >= 3 {
                return result.substring(to: result.characters.index(before: result.endIndex))
            }
            for index in 0 ..< self.signInGroupModel.departmentsArray.count {
                let model = self.signInGroupModel.departmentsArray[index]
                if model.departmentID == deptId {
                    result += model.departmentName
                    result += ","
                    count += 1
                    break
                }
            }
        }
        
        for userId in userIdsArr {
            if count >= 3 {
                 return result.substring(to: result.characters.index(before: result.endIndex))
            }
            for model in self.signInGroupModel.usersArray {
                if model.wbUserId == userId {
                    result += model.personName
                    result += ","
                    count += 1
                    break
                }
            }
        }
        
        if result.characters.count > 0 {
            result = result.substring(to: result.characters.index(before: result.endIndex))
        }
        
        return result
    }
    
// MARK: - interface -
    func checkHasAttSetGroupForDept() {
         KDPopup.showHUD(inView:self.view)
        
        var deptIds: String = ""
        if signInGroupModel.departmentsArray.count > 0 {
            for model in signInGroupModel.departmentsArray {
                deptIds += model.departmentID
                deptIds += ","
            }
            deptIds = deptIds.substring(to: deptIds.characters.index(before: deptIds.endIndex))
        }
        
        var userIds: String = ""
        if signInGroupModel.usersArray.count > 0 {
            for model in signInGroupModel.usersArray {
                userIds += model.wbUserId
                userIds += ","
            }
            userIds = userIds.substring(to: userIds.characters.index(before: userIds.endIndex))
        }
        
        let query = KDQuery()
        query.setParameter("deptIds", stringValue: deptIds)
        query.setParameter("userIds", stringValue: userIds)
        query.setParameter("attSetGroupId", stringValue: signInGroupModel.groupId)
        
        KDServiceActionInvoker.invokeWithSender(self, actionPath: "/signId/:checkHasAttSetGroup", query: query, configBlock: nil) { (results, request, response) in
            let statusCode = response?.statusCode()
            if statusCode == 200 {
                if let resultsDic = results as? NSDictionary,
                    let data = resultsDic["data"] as? [String: AnyObject],
                    let deptIdsArray = data["deptIds"] as? [String],
                    let userIdsArray = data["userIds"] as? [String] {
                    if deptIdsArray.count > 0 || userIdsArray.count > 0 {
                        let str = self.getCheckHasAttSetGroupResult(deptsArr: deptIdsArray, userIdsArr: userIdsArray)
                        KDPopup.hideHUD()
                        KDPopup.showAlert(title: ASLocalizedString("【\(str)】等已经在其他考勤组,确定要移动至此考勤组?"), message: nil, buttonTitles: [ASLocalizedString("取消"), ASLocalizedString("确定")], onTap: { (index) in
                            if index == 1 {
                                KDPopup.showHUD()
                                self.saveSignInGroupMessage()
                            }
                        })
                    } else {
                        self.saveSignInGroupMessage()
                    }
                }
            } else {
                KDPopup.showHUDToast(ASLocalizedString("保存失败"))
            }
        }
        
        
        //签到迁移，暂时屏蔽
//        let request = KDCheckHasAttSetGroupRequest(deptIds: deptIds, userIds: userIds, attSetGroupId: signInGroupModel.groupId)
//        request.startCompletionBlockWithSuccess({ (request: KDRequest?) -> Void in
//            
//                guard let data = request?.resultModel as? KDCheckHasAttSetGroupModel, deptIdsArray = data.deptIds, userIdsArray = data.userIds else {
//                    KDPopup.showHUDToast(ASLocalizedString("保存失败"))
//                    return
//                }
//            
//                if deptIdsArray.count > 0 || userIdsArray.count > 0 {
//                    let str = self.getCheckHasAttSetGroupResult(deptIdsArray, userIdsArr: userIdsArray)
//                    KDPopup.hideHUD()
//                    KDPopup.showAlert(title: ASLocalizedString("【\(str)】等已经在其他考勤组,确定要移动至此考勤组?"), message: nil, buttonTitles: [ASLocalizedString("取消"), ASLocalizedString("确定")], onTap: { (index) in
//                        if index == 1 {
//                            KDPopup.showHUD()
//                            self.saveSignInGroupMessage()
//                        }
//                    })
//                }
//                else {
//                    self.saveSignInGroupMessage()
//                }
//
//            }, failure: { request in
//                KDPopup.showHUDToast(ASLocalizedString("保存失败"))
//        })
    }
    
    func saveSignInGroupMessage() {
        let depsArr : NSMutableArray = NSMutableArray()
        for model in signInGroupModel.departmentsArray {
            depsArr.add(["id": model.departmentID, "name": model.departmentName])
        }
        
        let usersArr: NSMutableArray = NSMutableArray()
        for model in signInGroupModel.usersArray {
            usersArr.add(["userId": model.wbUserId, "username": model.personName])
        }
        
        let signInPointArr : NSMutableArray = NSMutableArray()
        for point in signInGroupModel.signInPointsArray {
            signInPointArr.add(["lng": point.lng,
                                "lat": point.lat,
                                "offset": point.offset,
                                "attendanceSetId": point.signInPointId,
                                "positionName": point.positionName,
                                "address": point.detailAddress ?? "",
                                "alias": point.alias ?? ""])
        }
        
        let dict : NSMutableDictionary = ["attendanceSetGroupName": signInGroupNameCell.accessoryTextField.text!, "attendanceSets": signInPointArr, "depts": depsArr, "users": usersArr]
        if signInGroupModel.groupId != "" {
            dict.setValue(signInGroupModel.groupId, forKey: "id")
        }
        let jsonData  = try! JSONSerialization.data(withJSONObject: dict)
        let jsonStr = String(data: jsonData, encoding: String.Encoding.utf8)
        
        let query = KDQuery()
        query.setParameter("operateType", integerValue: signInGroupModel.groupId == "" ? 0 : 1) //0: add, 1: update, 2: delete
        query.setParameter("jsonParam", stringValue: jsonStr)
        
        KDServiceActionInvoker.invokeWithSender(self, actionPath: "/signId/:setSignInGroup", query: query, configBlock: nil) { (results, request , response ) in
            let statusCode = response?.statusCode()
            if statusCode == 200 {
                KDPopup.showHUDSuccess(ASLocalizedString("保存成功"))
                delay(1, {
                    if self.isFromJSBridge {
                        self.createSignInGroupGuideFinish()
                    }
                    self.popViewController()
                })

            } else {
                KDPopup.showHUDToast(ASLocalizedString("保存失败"))
            }
            
        }
        
        //签到迁移，暂时屏蔽
//        let request = KDSetSignInGroupRequest(operateType: signInGroupModel.groupId == "" ? 0 : 1, jsonParam: jsonStr)
//        request.startCompletionBlockWithSuccess( { (request: KDRequest?) -> Void in
//            
//                KDPopup.showHUDSuccess(ASLocalizedString("保存成功"))
//                delay(1, {
//                    if self.isFromJSBridge {
//                        self.createSignInGroupGuideFinish()
//                    }
//                    self.popViewController()
//                })
//
//            }, failure: { request in
//                KDPopup.showHUDToast(ASLocalizedString("保存失败"))
//        })
    }
    
// MARK: - MemoryWarning -
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: - UITableViewDataSource && UITableViewDelegate -
extension KDCreateSignInGroupViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                return 30
            }
            else if indexPath.row == 1 {
                return 60
            }
            else if indexPath.row == 2 && signInGroupModel.departmentsArray.count > 0 {
                return departmentCellHeight
            }
        }
        if indexPath.section == 2 && indexPath.row != 0 {
            return 60
        }
        return 44
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return signInGroupModel.departmentsArray.count > 0 ? 4 : 3
        }
        if section == 2 {
            return signInGroupModel.signInPointsArray.count > 0 ? signInGroupModel.signInPointsArray.count + 1 : 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NSNumber.kdDistance2()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        
        if indexPath.section == 0 {
            return signInGroupNameCell
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = KDLS8Cell(style: .default, reuseIdentifier: "signInRangeCell")
                cell.kd_contentView.kd_textLabel.text = ASLocalizedString("签到人员（优先选取个人规则，其次部门规则）")
                cell.kd_contentView.kd_separatorLine.isHidden = true
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            }
            else if indexPath.row == 1 {
                let cell = KDSignInSettingCell(style: .default, reuseIdentifier: "signInDepartmentHeaderCell")
                cell.kd_contentView.install(cell.contentView, style: KDListStyle.ls4)
                cell.kd_contentView.kd_detailTextLabel.font = FS7
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.kd_contentView.kd_separatorLine.isHidden = signInGroupModel.departmentsArray.count > 0 ? true : false
                
                cell.addButton()
                cell.buttonDidClickedBlock = {
                    let chooseDepartmentVC = KDChooseDepartmentViewController()
                    chooseDepartmentVC.fromType = KDChooseDepartmentVCFromType_Native
                    chooseDepartmentVC.isMulti = true
                    chooseDepartmentVC.delegate = self
                    
                    let tempDepartmentsArray = NSMutableArray()
                    for model in self.signInGroupModel.departmentsArray {
                        //签到迁移你，暂时屏蔽
                        tempDepartmentsArray.add(KDChooseDepartmentModel(dictionary: ["id": model.departmentID, "orgName": model.departmentName]))
                    }
                    
                    chooseDepartmentVC.setSelectedDepartments(tempDepartmentsArray as [AnyObject])
                    self.navigationController?.pushViewController(chooseDepartmentVC, animated: true)
                }
                
                cell.kd_contentView.kd_textLabel.text = ASLocalizedString("签到部门")
                cell.kd_contentView.kd_detailTextLabel.text = ASLocalizedString("新入职员工将自动归入其部门签到组中")
                
                return cell
            }
            else if indexPath.row == 2 && signInGroupModel.departmentsArray.count > 0 {
                let cell = KDSignInDepartmentsCell(style: .default, reuseIdentifier: "signInDepartmentsCell")
                cell.departmentsArray = self.signInGroupModel.departmentsArray
                cell.deleteItem = { itemIndex in
                    let itemModel = self.signInGroupModel.departmentsArray[itemIndex]
                    KDPopup.showAlert(title: ASLocalizedString("确定删除部门\n[\(itemModel.departmentName)]?"), message: nil, buttonTitles: [ASLocalizedString("取消"), ASLocalizedString("确定")], onTap: { (index) in
                        if index == 1 {
                            self.signInGroupModel.departmentsArray.remove(at:itemIndex)
                            self.departmentCellHeight = self.calculateDepartmentCellHeight()
                            self.tableView.reloadData()
                        }
                    })
                }
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            }
            else {
                let cell = KDTableViewCell(style: .value2, reuseIdentifier: "KDSignInPersonCell")
                cell.textLabel?.text = ASLocalizedString("签到个人")
                cell.detailTextLabel?.text = signInGroupModel.usersArray.count > 0 ? getSignInPersonCellDetailText() : ASLocalizedString("请选择")
                cell.accessoryStyle = .disclosureIndicator
                return cell
            }
        }
        else {
            if indexPath.row == 0 {
                let cell = KDSignInSettingCell(style: .default, reuseIdentifier: "signInPointHeaderCell")
                cell.kd_contentView.install(cell.contentView, style: KDListStyle.ls7)
                cell.kd_contentView.kd_separatorLine.isHidden = true
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                cell.addButton()
                cell.buttonDidClickedBlock = {
                    let setSignVC = KDSetSignInPointVC()
                    setSignVC.sourceType = SetSignInPointSource_signinPointVC
                    setSignVC.sourceAttSetsStr = self.getSourceAttSetsStr(signInPointArray: self.signInGroupModel.signInPointsArray as NSArray)
                    setSignVC.addOrUpdateSignInPointSuccessBlock = { (signInPointInfo: KDSignInPoint?, type: KDAddOrUpdateSignInPointType?) in
                        if let info = signInPointInfo {
                            self.signInGroupModel.signInPointsArray.append(info)
                            self.tableView.reloadData()
                        }
                        
                    }
                    let nav = UINavigationController(rootViewController: setSignVC)
                    self.present(nav, animated: true, completion: nil)
                }
                
                cell.kd_contentView.kd_textLabel.text = ASLocalizedString("签到点")
                
                return cell
            }
            else {
                var cell = tableView.dequeueReusableCell(withIdentifier: "signInPointCell") as? KDSignInPointCell
                
                if cell == nil {
                    cell = KDSignInPointCell(style: .default, reuseIdentifier: "signInPointCell")
                    cell!.accessoryStyle = KDTableViewCellAccessoryStyle.disclosureIndicator
                    cell!.separatorLineStyle = KDTableViewCellSeparatorLineStyle.space
                    cell!.iconImageView.image = UIImage(named: "sign_tip_location")
                    cell!.separatorLineInset = UIEdgeInsetsMake(0, 38, 0, 0)
                    cell!.detailLabel.font = FS7
                }
                
                let point = signInGroupModel.signInPointsArray[indexPath.row - 1]
                
                cell!.locationLabel.text = (point.alias != nil && point.alias != "") ? point.alias : point.positionName
                cell!.detailLabel.text = (point.detailAddress != nil && point.detailAddress != "") ? point.detailAddress : point.positionName
                
                return cell!
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && (signInGroupModel.departmentsArray.count > 0 ? indexPath.row == 3 : indexPath.row == 2) {
            //迁移新增
            let contentVC = XTChooseContentViewController.init(type: XTChooseContentAdd)
            var users = [PersonSimpleDataModel]()
            for person in self.signInGroupModel.usersArray {
                let personx = XTDataBaseDao.sharedDatabaseDaoInstance().queryPerson(withPersonId: person.personId)
                if let personx = personx {
                    users.append(personx)
                }
            }
            contentVC?.pType = 2
            contentVC?.isFilterTeamAcc = true
            contentVC?.selectedPersons = users
            contentVC?.delegate = self
            contentVC?.isFromConversation = false
            
            let contentNav = UINavigationController.init(rootViewController: contentVC!)
            self.present(contentNav, animated: true, completion: { 
                UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: false)
            })
        }
        else if indexPath.section == 2 && indexPath.row > 0 {
            
            let point = signInGroupModel.signInPointsArray[indexPath.row - 1]
            
            let editSignInPointVC = KDAddOrUpdateSignInPointController()
            editSignInPointVC.addOrUpdateSignInPointType = .update
            editSignInPointVC.signInPointId = point.signInPointId
            editSignInPointVC.rowIndex = indexPath.row - 1
            editSignInPointVC.delegate = self
            
            let tempArray : NSMutableArray = NSMutableArray(array: signInGroupModel.signInPointsArray)
            tempArray.remove(at:indexPath.row - 1)
            editSignInPointVC.sourceAttSetsStr = getSourceAttSetsStr(signInPointArray: tempArray)
            
            navigationController?.pushViewController(editSignInPointVC, animated: true)
        }
    }
}

// MARK: - XTChooseContentViewControllerDelegate -
extension KDCreateSignInGroupViewController: XTChooseContentViewControllerDelegate {
    
    func chooseContentView(_ controller: XTChooseContentViewController!, persons: [Any]!) {
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
        guard let personsArray = persons as? [PersonSimpleDataModel] else {
            self.signInGroupModel.usersArray.removeAll()
            self.tableView.reloadData()
            return
        }
        
        self.signInGroupModel.usersArray = personsArray
        self.tableView.reloadData()
    }
    
    func cancelChoosePerson() {
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
    }
}

// MARK: - KDChooseDepartmentViewControllerDelegate -
extension KDCreateSignInGroupViewController : KDChooseDepartmentViewControllerDelegate {
    func didChooseDepartmentModels(_ models: [Any]!, longName: String!) {
        guard let modelsArray = models else {
            return
        }
        
        if signInGroupModel.departmentsArray.count > 0 {
            signInGroupModel.departmentsArray.removeAll()
        }
        
        for index in 0 ..< modelsArray.count {
            if let model = modelsArray[index] as? KDChooseDepartmentModel {
                signInGroupModel.departmentsArray.append(KDSignInDepartmentItemModel(dictionary: ["departmentID": model.strID, "departmentName": model.strName]))
            }
        }
        
        departmentCellHeight = calculateDepartmentCellHeight()
        tableView.reloadData()
    }
}

// MARK: - UITextFieldDelegate -
extension KDCreateSignInGroupViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        signInGroupNameCell.accessoryTextField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if (range.location >= 20 || range.location + string.characters.count >= 21) && string != "" {
//            return false
//        }
        
        return true
    }
}

// MARK: - KDAddOrUpdateSignInPointControllerDelegate -
extension KDCreateSignInGroupViewController : KDAddOrUpdateSignInPointControllerDelegate {
    func addOrUpdateSign(inPointSuccess signInPoint: KDSignInPoint!, signInPointType: KDAddOrUpdateSignInPointType, rowIndex index: Int) {
        if signInPointType == .update {
            signInGroupModel.signInPointsArray[index] = signInPoint
            tableView.reloadData()
        }
        else if signInPointType == .delete {
            signInGroupModel.signInPointsArray.remove(at: index)
            tableView.reloadData()
        }
    }
}
