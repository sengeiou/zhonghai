//
//  KDNoticeListVC.swift
//  kdweibo
//
//  Created by Darren Zheng on 2017/2/13.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

// MARK: - Input -

enum KDNoticeListMode {
    case empty(isAdmin: Bool)
    case list(isAdmin: Bool, data: [KDNoticeListCellDataSource])
}

protocol KDNoticeListVCDataSource: class {
    var noticeListVCMode: KDNoticeListMode { get }
}

// MARK: - Output -

@objc protocol KDNoticeListVCDelegate {
    func noticeListVCOnViewDidLoad(_ noticeListVC: KDNoticeListVC)
    func noticeListVCFetchNew(_ noticeListVC: KDNoticeListVC)
    func noticeListVCFetchOld(_ noticeListVC: KDNoticeListVC)
    func noticeListVCCreateButtonPressed(_ noticeListVC: KDNoticeListVC)
    func noticeListVC(_ noticeListVC: KDNoticeListVC, didPressIndex: Int)

}

class KDNoticeListVC: UIViewController {
    
    // MARK: - Properties -
    
    weak var delegate: KDNoticeListVCDelegate?
    weak var dataSource: KDNoticeListVCDataSource? {
        didSet {
            update()
        }
    }
    
    var cellDataSources = [KDNoticeListCellDataSource]()
    
    lazy var tableView: UITableView = {
        $0.delegate = self
        $0.dataSource = self
        $0.separatorStyle = .none
        $0.backgroundColor = UIColor.kdBackgroundColor1()
        $0.contentInset = UIEdgeInsetsMake(8, 0, 0, 0)

        return $0
    }(UITableView())
 
    
    lazy var emptyContainerView: KDNoticeEmptyView = {
        $0.delegate = self
        $0.dataSource = self
        return $0
    }(KDNoticeEmptyView())
    
    lazy var helpView: KDHelpWhiteBGView = {
        let helpView = KDHelpWhiteBGView(frame: KDFrame.screenBounds())
        helpView.backgroundPressed = {
            self.hideHelpView()
        }
        helpView.title = ASLocalizedString("Notice_Introduction")
        helpView.backgroundColor = UIColor.clear
        helpView.imageViewMask.alpha = 0
        helpView.alpha = 0
        let mArray = NSMutableArray()
        let model1 = KDHelpWhiteBGViewModel()
        model1.tips = ASLocalizedString("Notice_Intro1")
        mArray.add(model1)
        let model2 = KDHelpWhiteBGViewModel()
        model2.tips = ASLocalizedString("Notice_Intro2")
        mArray.add(model2)
        let model3 = KDHelpWhiteBGViewModel()
        model3.tips = ASLocalizedString("Notice_Intro3")
        mArray.add(model3)
        helpView.mArrayModels = mArray
        helpView.imageViewTriangle.mas_updateConstraints{ make in
            _ = make?.centerX.equalTo()(helpView.popDownBgView.centerX)?.with().offset()(42)
        }
        helpView.popDownBgView.mas_updateConstraints{ make in
            _ = make?.height.mas_equalTo()(260)
        }
        return helpView
    }()
    
    var isShowHelpView: Bool = false
    
    func hideHelpView() {
        self.helpView.shrinkView()
        UIView.animate(withDuration: 0.25, animations: {
            self.helpView.imageViewMask.alpha = 0
            self.helpView.alpha = 0
            }, completion: { (complete) in
                self.helpView.removeFromSuperview()
                self.isShowHelpView = !self.isShowHelpView
        })
    }
    
    func showHelpView() {
//        KDEventAnalysis.event(groupnotice_tips)
        self.navigationController?.view.addSubview(self.helpView)
        self.helpView.restore()
        UIView.animate(withDuration: 0.25, animations: {
            self.helpView.imageViewMask.alpha = 0.3
            self.helpView.alpha = 1
            }, completion: { (complete) in
                self.isShowHelpView = !self.isShowHelpView
        })
    }
    func queryImagePressed() {
        if !self.isShowHelpView {
            self.showHelpView()
        } else {
            self.hideHelpView()
        }
    }
  
    lazy var navTitleView: UIView = {
        let navTitleView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        let titleLabel = UILabel()
        titleLabel.text = ASLocalizedString("Notice_Group")
        titleLabel.textColor = FC1;
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = FS1
        let queryImageView = UIImageView()
        queryImageView.image = UIImage(named: "contact_buttn_help_normal")
        queryImageView.highlightedImage = UIImage(named: "contact_buttn_help_press")
        queryImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(KDNoticeListVC.queryImagePressed))
        navTitleView.addGestureRecognizer(tap)
        
        navTitleView.addSubviews([titleLabel, queryImageView])
        
        titleLabel.mas_makeConstraints { make in
            _ = make?.center.equalTo()(navTitleView)
            _ = make?.height.mas_equalTo()(44)
            return()
        }
        
        queryImageView.mas_makeConstraints { make in
            _ = make?.centerY.equalTo()(navTitleView.centerY)
            _ = make?.left.equalTo()(titleLabel.right)?.with().offset()(8)
            return()
        }
        
        return navTitleView
    }()
    
    
    // MARK: - Setup -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = ASLocalizedString("Notice_Group")
        view.backgroundColor = UIColor.kdBackgroundColor1()
        self.automaticallyAdjustsScrollViewInsets = false
        view.addSubviews([tableView])
        tableView.register(KDNoticeListCell.self, forCellReuseIdentifier: "KDNoticeListCell")
        
        navigationItem.titleView = navTitleView;

        self.delegate?.noticeListVCOnViewDidLoad(self)
        addHeader {
            self.delegate?.noticeListVCFetchNew(self)
        }
        headerBeginRefreshing()

        kd_setupVFL(bindings,
                    metrics: metrics,
                    constraints: vfls,
                    delayInvoke: false)
//        emptyContainerView.kd_setCenterX()
//        emptyContainerView.kd_setCenterY()
        
        tableView.addSubview(emptyContainerView)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideHelpView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emptyContainerView.frame = CGRect(x: 0, y: 0, width: 200, height: 250)
        emptyContainerView.center = CGPoint(x: tableView.center.x, y: tableView.center.y - 64) //tableView.center
    }
    
    lazy var bindings: [String: AnyObject] = {
        return [
            "tableView" : self.tableView,
//            "emptyContainerView": self.emptyContainerView,
            ]
    }()
    
    var metrics: [String: AnyObject] {
        return [
            :
        ]
    }
    
    let vfls: [String] = [
        "H:|[tableView]|",
        "V:|-72-[tableView]|",
//        "H:[emptyContainerView(200)]",
//        "V:[emptyContainerView(250)]"
        ]
    
 
    // MARK: - Update -
    
    func update() {
        guard let dataSource = dataSource
            else { return }
        
        navigationItem.rightBarButtonItem = nil
        switch dataSource.noticeListVCMode {
        case .empty(let isAdmin):
            emptyContainerView.isHidden = false
//            tableView.hidden = true
            if isAdmin {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: ASLocalizedString("Notice_Create"), style: UIBarButtonItemStyle.done, target: self, action: #selector(KDNoticeListVC.createButtonPressed))
            }
            self.cellDataSources.removeAll()
            tableView.reloadData()

        case .list(let isAdmin, let cellDataSources):
            emptyContainerView.isHidden = true
            tableView.isHidden = false
            if cellDataSources.count >= 10 {
                addFooter {
                    self.delegate?.noticeListVCFetchOld(self)
                }
            }
            if isAdmin {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: ASLocalizedString("Notice_Create"), style: UIBarButtonItemStyle.done, target: self, action: #selector(KDNoticeListVC.createButtonPressed))
            }
            self.cellDataSources = cellDataSources
            tableView.reloadData()
        }
    }
    
}

// MARK: - EmptyView -

extension KDNoticeListVC: KDNoticeEmptyViewDelegate, KDNoticeEmptyViewDataSource {
    
//<<<<<<< HEAD
//    func noticeEmptyViewCreateButtonPressed(noticeEmptyView: KDNoticeEmptyView) {
//
//=======
    func noticeEmptyViewCreateButtonPressed(_ noticeEmptyView: KDNoticeEmptyView) {
//>>>>>>> b52866a... xcode8.3.3
        self.delegate?.noticeListVCCreateButtonPressed(self)

    }

    var isAdmin: Bool {
        guard let dataSource = dataSource
            else { return false }
        switch dataSource.noticeListVCMode {
        case .empty(let isAdmin):
            return isAdmin
        default:
            return false
        }
    }

}

// MARK: - TableView -

extension KDNoticeListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 156
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDataSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "KDNoticeListCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? KDNoticeListCell
        if cell == nil {
            cell = KDNoticeListCell(style: .default, reuseIdentifier: cellId)
        }
        let cellDataSource = cellDataSources[indexPath.row]
        cell?.dataSource = cellDataSource
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.noticeListVC(self, didPressIndex: indexPath.row)
    }
}

// MARK: - 上拉下拉 -

extension KDNoticeListVC {
    
    func addHeader(_ callBack: (() -> Void)?) {
        tableView.addHeader {
            callBack?()
        }
    }
    
    func addFooter(_ callBack: (() -> Void)?) {
        tableView.addFooter {
            callBack?()
        }
    }
    func removeFooter() {
        tableView.removeFooter()
    }
    
    func headerEndRefreshing() {
        tableView.headerEndRefreshing()
    }
    
    func headerBeginRefreshing() {
        tableView.headerBeginRefreshing()
    }
    
    func footerEndRefreshing() {
        tableView.footerEndRefreshing()
    }
}

// MARK: - Events -

extension KDNoticeListVC {
    
    func createButtonPressed() {
        KDEventAnalysis.event(event_group_manage_announcement_create)
        KDEventAnalysis.eventCountly(event_group_manage_announcement_create)
        delegate?.noticeListVCCreateButtonPressed(self)
    }
}
