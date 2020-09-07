//
//  KDNoticeDetailVC.swift
//  kdweibo
//
//  Created by Darren Zheng on 2017/2/15.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//


@objc protocol KDNoticeDetailVCDelegate {
    func noticeDetailVCDeleteButtonPressed(_ noticeDetailVC: KDNoticeDetailVC)
}

@objc protocol KDNoticeDetailVCDataSource {
    var noticeDetailVCTitle: String? { get }
    var noticeDetailVCSubtitle: String? { get }
    var noticeDetailVCContent: String? { get }
    var noticeDetailVCNoticeId: String? { get }
}

@objc protocol KDNoticeDetailVCIsAdminDataSource {
    var noticeDetailVCIsAdmin: Bool { get }
}

class KDNoticeDetailVC: UIViewController {

    weak var delegate: KDNoticeDetailVCDelegate?
    weak var dataSource: KDNoticeDetailVCDataSource? 
    
    weak var isAdminDataSource: KDNoticeDetailVCIsAdminDataSource? {
        didSet {
            
            self.navigationItem.rightBarButtonItem = nil

            if let isAdmin = isAdminDataSource?.noticeDetailVCIsAdmin, isAdmin {
                let button = KDSimpleHighlightedButton()
                button.setTitleColor(FC4, for: UIControlState())
                button.titleLabel?.font = FS3
                button.setTitle(ASLocalizedString("Mark_delete"), for: UIControlState())
                button.addTarget(self, action: #selector(KDNoticeDetailVC.deleteButtonPressed), for: UIControlEvents.touchUpInside)
                button.frame = CGRect(x: 0, y: 0, width: (FS3?.lineHeight)! * 2, height: (FS3?.lineHeight)!)
                let barButton = UIBarButtonItem(customView: button)
                self.navigationItem.rightBarButtonItem = barButton
            }
        }
    }
    
    lazy var tableView: UITableView = {
        $0.delegate = self
        $0.dataSource = self
        $0.separatorStyle = .none
        return $0
    }(UITableView())
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = ASLocalizedString("Notice_Detail")
        
        view.backgroundColor = UIColor.white
        
        tableView.register(KDNoticeListCell.self, forCellReuseIdentifier: "KDNoticeListCell")


        
        view.addSubviews([tableView])
        kd_setupVFL(bindings,
                    metrics: metrics,
                    constraints: vfls,
                    delayInvoke: false)

    }
    
    func deleteButtonPressed() {
        delegate?.noticeDetailVCDeleteButtonPressed(self)
    }

    lazy var bindings: [String: AnyObject] = {
        return [
            "tableView" : self.tableView,
            ]
    }()
    
    var metrics: [String: AnyObject] {
        return [
            :
        ]
    }
    
    let vfls: [String] = [
        "H:|[tableView]|",
        "V:|[tableView]|",
        ]


}

// MARK: - TableView Delegate & DataSource -

extension KDNoticeDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let content = dataSource?.noticeDetailVCContent {
            return KDString.heightForString(content, width: KDFrame.screenWidth() - 24,font: FS4!) + 12 + FS2!.lineHeight + 3 + FS7!.lineHeight + 12 + 1 + 12
        } else {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "KDNoticeDetailCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? KDNoticeDetailCell
        if cell == nil {
            cell = KDNoticeDetailCell(style: .default, reuseIdentifier: cellId)
            cell!.selectionStyle = .none
        }
        cell?.dataSource = dataSource
        return cell!
    }
    
}
