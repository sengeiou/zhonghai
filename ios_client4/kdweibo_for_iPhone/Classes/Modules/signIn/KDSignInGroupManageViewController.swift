//
//  KDSignInGroupManageViewController.swift
//  kdweibo
//
//  Created by 张培增 on 2016/12/2.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

import UIKit

let signInGroupListPageLimit = 10

class KDSignInGroupManageViewController: UIViewController {
    
    fileprivate lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.kdBackgroundColor1()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
        tableView.showsVerticalScrollIndicator = false
        tableView.addHeader { [weak self] in
            self?.getSignInGroupList(loadMore: false)
        }
        return tableView
    }()
    
    fileprivate lazy var defaultView : KDSignInGroupManageDefaultView = {
        let view = KDSignInGroupManageDefaultView()
        view.createSignInGroup = {
            let chooseSignInGroupTypeVC = KDChooseSignInGroupTypeVC()
            chooseSignInGroupTypeVC.title = ASLocalizedString("新建签到组")
            chooseSignInGroupTypeVC.isFromJSBridge = self.isFromJSBridge
            self.navigationController?.pushViewController(chooseSignInGroupTypeVC, animated: true)
        }
        return view
    }()
    
    fileprivate lazy var createSignInGroupBtn : UIButton = {
        let button = UIButton()
        button.titleLabel?.font = FS2
        button.setTitleColor(FC5, for: UIControlState())
        button.setTitle(ASLocalizedString("新建签到组"), for: UIControlState())
        button.setBackgroundImage(UIImage.kd_image(with: UIColor.white), for: UIControlState())
        button.setBackgroundImage(UIImage.kd_image(with: UIColor(rgb: 0xe8eef0)), for: UIControlState.highlighted)
        button.addTarget(self, action: #selector(createSignInGroupBtnPressed(_:)), for: UIControlEvents.touchUpInside)
        
        let line = UIView()
        line.backgroundColor = UIColor.kdDividingLine()
        button.addSubview(line)
        line.mas_makeConstraints { make in
            make?.top.and().left().and().right().mas_equalTo()(button)
            make?.height.mas_equalTo()(0.5)
        }
        
        return button
    }()
    
    var dataArray : NSMutableArray = NSMutableArray()
    
    var start : NSInteger = 0
    
    //签到首页：签到设置升级啦用户引导
    var showGuideView : Bool = false
    
    //签到落地页：JS桥触发的用户引导
    var isFromJSBridge : Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFromJSBridge == false {
            tableView.headerBeginRefreshing()
            
            if showGuideView == true {
                addGuideView()
                showGuideView = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        setNavigationStyle(KDNavigationStyleBlue)
        
        view.backgroundColor = UIColor .kdBackgroundColor1()
        title = ASLocalizedString("签到组管理")
        
        let backBtn = UIButton.backBtnInBlueNav(withTitle: ASLocalizedString(""))
        backBtn?.addTarget(self, action: #selector(backAction), for:  .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn!)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: ASLocalizedString("高级设置"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(advancedSettingBtnPressed(_:)))
        navigationItem.rightBarButtonItem?.setTitlePositionAdjustment(UIOffsetMake(NSNumber.kdRightItemDistance(), 0), for: UIBarMetrics.default)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: FS3, NSForegroundColorAttributeName: FC6], for: UIControlState())
        
        if isFromJSBridge == false {
            view.addSubview(tableView)
            tableView.mas_makeConstraints { make in
                make?.left.and().right().and().top().mas_equalTo()(self.view)
                make?.bottom.mas_equalTo()(self.view)?.with().offset()(-44)
            }
            
            view.addSubview(createSignInGroupBtn)
            createSignInGroupBtn.mas_makeConstraints { make in
                make?.left.and().right().and().bottom().mas_equalTo()(self.view)
                make?.height.mas_equalTo()(44)
            }
        }
        else {
            if view.subviews.contains(defaultView) == false {
                view.addSubview(defaultView)
                defaultView.mas_makeConstraints { make in
                    make?.edges.mas_equalTo()(self.view)?.with().insets()(UIEdgeInsets.zero)
                }
            }
        }
    }
    
// MARK: - interface -
    func getSignInGroupList(loadMore: Bool) {
        start = loadMore ? start + signInGroupListPageLimit : 0
        
        let query = KDQuery()
        query.setParameter("operateType", integerValue: 3)
        query.setParameter("start", integerValue: start)
        query.setParameter("limit", integerValue: signInGroupListPageLimit)
        
        KDServiceActionInvoker.invokeWithSender(self, actionPath: "/signId/:getSignInGroupList", query: query, configBlock: nil) { (results, request, response) in
            self.stopRefreshing()
            if let results = results {
                let data = results as? [AnyObject]
                var array = [KDSignInGroupServerModel]()
                for dict in data! {
                    if let dict = dict as? [String: AnyObject] {
                        array += [KDSignInGroupServerModel(dict: dict)]
                    }
                }
                
                if array.count == 1 && array[0].id == nil {
                    self.reloadTableView()
                    return
                }
                
                if self.start == 0 && self.dataArray.count > 0 {
                    self.dataArray.removeAllObjects()
                }
                
                for index in 0 ..< array.count {
                    let model = KDSignInGroupLocalModel()
                    model.serverModel = array[index]
                    self.dataArray.add(model)
                }
                
                let needCount = self.start + signInGroupListPageLimit
                if self.dataArray.count < needCount {
                    if self.start > 0 {
                        self.tableView.removeFooter()
                    }
                }
                else {
                    if self.start == 0 {
                        self.tableView.addFooter { [weak self] in
                            self?.getSignInGroupList(loadMore: true)
                        }
                    }
                }
                self.reloadTableView()
            } else {
                KDPopup.showHUDSuccess(ASLocalizedString("获取签到组信息失败"))
            }
        }
        
        //签到迁移，暂时屏蔽
//        let request = KDGetSignInGroupListRequest(start: start, limit: signInGroupListPageLimit)
//        request.startCompletionBlockWithSuccess( { (request: KDRequest?) -> Void in
//                self.stopRefreshing()
//                guard let array = request?.resultModels as? [KDSignInGroupServerModel] else {
//                    return
//                }
//                
//                if self.start == 0 && self.dataArray.count > 0 {
//                    self.dataArray.removeAllObjects()
//                }
//                
//                for index in 0 ..< array.count {
//                    let model = KDSignInGroupLocalModel()
//                    model.serverModel = array[index]
//                    self.dataArray.addObject(model)
//                }
//                
//                let needCount = self.start + signInGroupListPageLimit
//                if self.dataArray.count < needCount {
//                    if self.start > 0 {
//                        self.tableView.removeFooter()
//                    }
//                }
//                else {
//                    if self.start == 0 {
//                        self.tableView.addFooterWithCallback { [weak self] in
//                            self?.getSignInGroupList(loadMore: true)
//                        }
//                    }
//                }
//                self.reloadTableView()
//            
//            }, failure: { request in
//                self.stopRefreshing()
//                KDPopup.showHUDToast(ASLocalizedString("获取签到组信息失败"))
//        })
    }
    
    func stopRefreshing() {
        if self.start == 0 {
            self.tableView.headerEndRefreshing()
        }
        else {
            self.tableView.footerEndRefreshing()
        }
    }
    
    func deleteSignInGroup(_ signInGroupID: String, modelIndex: NSInteger) {
        KDPopup.showHUD()
        
        let dict : NSDictionary = ["id": signInGroupID]
        let jsonData  = try! JSONSerialization.data(withJSONObject: dict)
        let jsonStr = String(data: jsonData, encoding: String.Encoding.utf8)
        
        let query = KDQuery()
        query.setParameter("operateType", integerValue: 2)
        query.setParameter("jsonParam", stringValue: jsonStr)
        
        KDServiceActionInvoker.invokeWithSender(self, actionPath: "/signId/:setSignInGroup", query: query, configBlock: nil) { (results , request, response) in
            let statusCode = response?.statusCode()
            if statusCode == 200 {
                KDPopup.showHUDSuccess(ASLocalizedString("签到组删除成功"))
                delay(1, {
                    self.dataArray.removeObject(at: modelIndex)
                    self.reloadTableView()
                })
            } else {
                KDPopup.showHUDToast(ASLocalizedString("签到组删除失败"))
            }
            
        }
        
        
        
 //签到迁移，暂时屏蔽
//        let request = KDSetSignInGroupRequest(operateType: 2, jsonParam: jsonStr)
//        request.startCompletionBlockWithSuccess( { (request: KDRequest?) -> Void in
//            
//                KDPopup.showHUDSuccess(ASLocalizedString("签到组删除成功"))
//                delay(1, {
//                    self.dataArray.removeObjectAtIndex(modelIndex)
//                    self.reloadTableView()
//                })
//
//            }, failure: { request in
//                KDPopup.showHUDToast(ASLocalizedString("签到组删除失败"))
//        })
    }

// MARK: - Method -
    func advancedSettingBtnPressed(_ sender: AnyObject) {
        let advancedSettingVC = KDSignInAdvancedSettingViewController()
        navigationController?.pushViewController(advancedSettingVC, animated: true)
    }
    
    func backAction() {
        navigationController?.popViewController(animated: true)
    }
    
    func createSignInGroupBtnPressed(_ sender: UIButton) {
        let chooseSignInGroupTypeVC = KDChooseSignInGroupTypeVC()
        chooseSignInGroupTypeVC.title = ASLocalizedString("新建签到组")
        navigationController?.pushViewController(chooseSignInGroupTypeVC, animated: true)
    }
    
    func calculateCellHeight(_ model: KDSignInGroupLocalModel?) -> CGFloat {
        guard let model = model else {
            return 0
        }
        
        //cell min-height
        var height : CGFloat = 129
        
        var size : CGSize = model.groupName.boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width - 24, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:FS2], context: nil).size
        height += size.height > 21 ? 41 : 20.5
        
        if model.departmentsArray.count > 0 && model.usersArray.count > 0 {
            height += 18
        }
        else {
            size = model.deptsOrPersonsName.boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width - 48, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:FS4], context: nil).size
            height += size.height > 20 ? 36 : 18
        }
        
        size = model.locationName.boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width - 48, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:FS4], context: nil).size
        height += size.height > 20 ? 36 : 18
        
        return height
    }
    
    func reloadTableView() {
        tableView.reloadData()
        
        if dataArray.count == 0 {
            tableView.isHidden = true
            createSignInGroupBtn.isHidden = true
            
            if view.subviews.contains(defaultView) == false {
                view.addSubview(defaultView)
                defaultView.mas_makeConstraints { make in
                    make?.edges.mas_equalTo()(self.view)?.with().insets()(UIEdgeInsets.zero)
                }
            }
        }
        else {
            tableView.isHidden = false
            createSignInGroupBtn.isHidden = false
            
            if view.subviews.contains(defaultView) == true {
                defaultView.removeFromSuperview()
            }
        }
    }
    
    func addGuideView() {
        let guideView = KDSignInSettingGuideView()
        guideView.type = 1
        guideView.actionBlock = {
            let advancedSettingVC = KDSignInAdvancedSettingViewController()
            self.navigationController?.pushViewController(advancedSettingVC, animated: true)
        }
        navigationController!.view.addSubview(guideView)
        guideView.mas_makeConstraints { make in
            make?.edges.mas_equalTo()(self.navigationController!.view)
        }
        
        guideView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: { 
            guideView.alpha = 1
        }) 
    }

// MARK: - MemoryWarning -
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension KDSignInGroupManageViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "signInGroupCell") as? KDSignInGroupCell
        
        if cell == nil {
            cell = KDSignInGroupCell(style: .default, reuseIdentifier: "signInGroupCell")
            cell?.selectionStyle = .none
        }
        
        cell!.groupIdLabel.text = String(format: ASLocalizedString("签到组%d"), indexPath.section + 1)
        
        if let model = dataArray.object(at: indexPath.section) as? KDSignInGroupLocalModel {
            cell!.signInGroupModel = model
            if model.isShift {
                cell!.gotoShiftWebsite = {
                    let webVC = KDWebViewController(urlString: KDConfigurationContext.getCurrent().getDefaultPlistInstance().getServerBaseURL() + SCHEDULE_GUIDANCE_URL)
                    webVC?.isBlueNav = true
                    self.navigationController?.pushViewController(webVC!, animated: true)
                }
            }
            else {
                cell!.edit = {
                    let createSignInGroupVC = KDCreateSignInGroupViewController()
                    createSignInGroupVC.title = ASLocalizedString("修改签到组")
                    createSignInGroupVC.signInGroupModel = model
                    self.navigationController?.pushViewController(createSignInGroupVC, animated: true)
                }
                cell!.delete22 = {
                    KDPopup.showAlert(title: ASLocalizedString("确定删除签到组\n[\(model.groupName)]?"), message: nil, buttonTitles: [ASLocalizedString("取消"),ASLocalizedString("确定")], onTap: { (index) in
                        if index == 1 {
                            self.deleteSignInGroup(model.groupId, modelIndex: indexPath.section)
                        }
                    })
                }
            }
        }
        
        return cell!
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
        return calculateCellHeight(dataArray.object(at: indexPath.section) as? KDSignInGroupLocalModel)
    }
}
