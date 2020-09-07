//
//  KDChooseSignInGroupTypeVC.swift
//  kdweibo
//
//  Created by 张培增 on 2017/3/24.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import UIKit

let SCHEDULE_GUIDANCE_URL = "/attendancelight/guidance/schedule-guidance.html"

class KDChooseSignInGroupTypeVC: UIViewController {
    
    //签到落地页：JS桥触发的用户引导
    var isFromJSBridge : Bool = false
    
    lazy var tableView: UITableView = {
        $0.delegate = self
        $0.dataSource = self
        $0.isScrollEnabled = false
        $0.backgroundColor = UIColor.kdBackgroundColor1()
        $0.separatorStyle = UITableViewCellSeparatorStyle.none;
        return $0
    }(UITableView(frame: CGRect.zero, style: .grouped))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backBtn = UIButton.backBtnInBlueNav(withTitle: ASLocalizedString(""))
        backBtn?.addTarget(self, action: #selector(backAction), for:  .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn!)
        
        view.backgroundColor = UIColor.kdBackgroundColor1()
        //setNavigationStyle(KDNavigationStyleBlue)
        
        view.addSubview(tableView)
        kd_setupVFL([
            "tableView" : tableView
            ], constraints: [
                "H:|[tableView]|",
                "V:|[tableView]|"
            ])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func backAction() {
        navigationController?.popViewController(animated: true)
    }
}

extension KDChooseSignInGroupTypeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 136
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.kdBackgroundColor1()
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "SignInGroupTypeCell") as? KDSignInGroupTypeCell
        if cell == nil {
            cell = KDSignInGroupTypeCell(style: .default, reuseIdentifier:"SignInGroupTypeCell")
            cell!.backgroundColor = UIColor.kdBackgroundColor1()
        }
        
        if indexPath.section == 0 {
            cell!.type = .fixedShift
        }
        else if indexPath.section == 1 {
            cell!.type = .shift
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            let createSignInGroupVC = KDCreateSignInGroupViewController()
            createSignInGroupVC.title = ASLocalizedString("新建签到组")
            createSignInGroupVC.isFromJSBridge = self.isFromJSBridge
            navigationController?.pushViewController(createSignInGroupVC, animated: true)
        }
        else {
            let webVC = KDWebViewController(urlString: KDConfigurationContext.getCurrent().getDefaultPlistInstance().getServerBaseURL() + SCHEDULE_GUIDANCE_URL)
            webVC?.isBlueNav = true
            navigationController?.pushViewController(webVC!, animated: true)
        }
    }
    
}
