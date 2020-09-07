//
//  KDMarkListVC.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/10.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

final class KDMarkListVC: UIViewController, UITableViewDataSource, UITableViewDelegate, KDMarkListBaseCellDelegate {
    
    // MARK: - Table View
    var models = [KDMarkModel]()
    var moreData = true
    let itemCountPerPage: Int32 = 10
    var hasFooter = false
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.kdBackgroundColor1()
        return tableView
    }()
    
    override func viewDidLoad() {
        
        //加水印
        if BOSSetting.shared().openWaterMark(WaterMarkType(WaterMarkTypeConversation))
        {
            let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            KDWaterMarkAddHelper.cover(on: self.tableView,withFrame: frame);
        }
        else {
            KDWaterMarkAddHelper.removeWaterMark(from: self.tableView)
        }

        
        title = ASLocalizedString("Mark_mark")
        view.backgroundColor = UIColor.kdBackgroundColor1()
        view.addSubview(tableView)
        tableView.mas_makeConstraints { make in
            make?.top.equalTo()(self.tableView.superview!.top)?.with().offset()(kd_StatusBarAndNaviHeight + 8)
            make?.left.equalTo()(self.tableView.superview!.left)?.with().offset()(0)
            make?.right.equalTo()(self.tableView.superview!.right)?.with().offset()(-0)
            make?.bottom.equalTo()(self.tableView.superview!.bottom)?.with().offset()(-0)
            return()
        }
        tableView.estimatedRowHeight = 100
        tableView.register(KDMarkTextCell.self, forCellReuseIdentifier: "KDMarkTextCell")
        tableView.register(KDMarkTextCell.self, forCellReuseIdentifier: "KDMarkImageCell")
        tableView.register(KDMarkTextCell.self, forCellReuseIdentifier: "KDMarkLinkCell")
        tableView.register(KDMarkTextCell.self, forCellReuseIdentifier: "KDMarkListGuideCell")
        tableView.register(KDMarkTextCell.self, forCellReuseIdentifier: "KDMarkListEmptyCell")
        
        addHeader {
            self.loadDataFromServer(direction: .new, markId: nil)
        }
        
        headerBeginRefreshing()
    }
    
    func loadDataFromDB(currentModels: [KDMarkModel]?, perPage: Bool) {
        if let marks = XTDataBaseDao.sharedDatabaseDaoInstance().queryMarks(fromUpdateTime: currentModels?.sorted{ $0.updateTime! < $1.updateTime! }.first?.updateTime ?? "", pageCount: perPage ? self.itemCountPerPage : 0) as? [KDMarkModel] {
            self.models += marks
            self.models.sort{ $0.updateTime! > $1.updateTime! }
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationStyle(KDNavigationStyleNormal)
        
        // 全量刷新
        models.removeAll()
        loadDataFromDB(currentModels: nil, perPage: false)
        
        if models.count == 0 {
            if !showGuide() {
                showEmpty()
            }
        }
    }
    
    deinit {
        KDOpenAPIClientWrapper.sharedInstance.deleteMarkClient.cancelRequest()
        KDOpenAPIClientWrapper.sharedInstance.queryMarkListClient.cancelRequest()
    }
    
    
    var lastMarkId: String? {
        if models.count == 0 {
            return nil
        } else {
            return models.last?.id
        }
    }
    
    func loadDataFromServer(direction: PagingDirectioin, markId: String?) {
        
        KDOpenAPIClientWrapper.sharedInstance.queryMarkList(markId: markId, pageSize: itemCountPerPage, direction: Int32(direction.rawValue)) { (succ, errorMsg, data) in
            
            if direction == .new {
                self.headerEndRefreshing()
            } else {
                self.footerEndRefreshing()
            }
            
            if succ {
                guard let data = data, let more = data["more"] as? Int, let list = data["list"] as? [AnyObject]
                    else { return }
                
                var models = [KDMarkModel]()
                
                if list.count > 0 {
                    KDUserDefaults.sharedInstance().consumeFlag(kMarkUsed)
                }
                
                if direction == .new {
                    self.models.removeAll()
                    XTDataBaseDao.sharedDatabaseDaoInstance().clearMarkTable()
                }
                
                for dict in list {
                    if let dict = dict as? [String: AnyObject] {
                        models += [KDMarkModel(dict: dict)]
                    }
                }
                
                XTDataBaseDao.sharedDatabaseDaoInstance().insertMarks(models)
                
                // 从数据库取的原因是为了联表查闹钟
                self.loadDataFromDB(currentModels: self.models, perPage: true)
                
                self.moreData = (more != 0)
                self.updateFooter()
                
                if direction == .new && list.count == 0 {
                    if !self.showGuide() {
                        self.showEmpty()
                    }
                }
                
            } else {
                KDAlert.showToast(inView: self.view, text: errorMsg)
            }
        }
    }
    
    func updateFooter() {
        if !self.moreData {
            self.removeFooter()
            hasFooter = false
        } else {
            hasFooter = true
            self.addFooter {
                self.loadDataFromServer(direction: .old, markId: self.lastMarkId)
            }
        }
    }
    
    func refreshFooter() {
        if hasFooter {
            self.removeFooter()
            self.addFooter {
                self.loadDataFromServer(direction: .old, markId: self.lastMarkId)
            }
        }
    }
    
    func showGuide() -> Bool {
        let shouldShow = !KDUserDefaults.sharedInstance().isFlagConsumed(kMarkUsed)
        if shouldShow {
            let model = KDMarkModel(dict: nil)
            model.type = .guide
            models += [model]
            tableView.reloadData()
        }
        return shouldShow
    }
    
    func showEmpty() {
        let model = KDMarkModel(dict: nil)
        model.type = .empty
        models += [model]
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = models[indexPath.row]
        switch model.type {
        case .text:
            return tableView.fd_heightForCell(withIdentifier: "KDMarkTextCell", cacheBy: indexPath, configuration: {  cell in
                self.configure(cell as! UITableViewCell, model: model)
            })
        case .image:
            return 12 + 44 + 12 + 14 + 12 + 140 + 45
        case .link:
            return 12 + 44 + 12 + 60 + 12 + 6 + 45
        case .guide, .empty: fallthrough
        default:
            return KDFrame.screenHeight() - 64 - 8
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    
    func configure(_ cell: UITableViewCell, model: KDMarkModel) {
        if let cell = cell as? KDMarkTextCell {
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.nameLabel.text = model.title
            cell.timeLabel.text = model.humanReadableUpdateTime
            if let headUrl = model.headUrl {
                cell.headImageView.setImageWith(URL(string: headUrl), placeholderImage: XTImageUtil.headerDefaultImage())
            }
            cell.alarmClockOn = model.localEventId != nil
            if let text = model.text {
                cell.contentTextView.attributedText = KDRichTextView.renderedText(text as NSString, patternOptionSet: [], font: FS3!, textColor: FC1!)
            }
            cell.baseDelegate = self
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        switch model.type {
            
        case .image:
            let cellId = "KDMarkImageCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? KDMarkImageCell
            if cell == nil {
                cell = KDMarkImageCell(style: .default, reuseIdentifier: cellId)
                cell!.selectionStyle = UITableViewCellSelectionStyle.none
            }
            cell!.baseDelegate = self
            cell!.alarmClockOn = model.localEventId != nil
            cell!.nameLabel.text = model.title
            cell!.timeLabel.text = model.humanReadableUpdateTime
            if let headUrl = model.headUrl {
                cell!.headImageView.setImageWith(URL(string: headUrl), placeholderImage: XTImageUtil.headerDefaultImage())
            }
            
            if let imageUrl = model.imgUrl {
                cell!.contentImageView.setImageWith(URL(string: imageUrl), placeholderImage: XTImageUtil.cellThumbnailImage(withType: 2))
            }
            return cell!
        case .link:
            let cellId = "KDMarkLinkCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? KDMarkLinkCell
            if cell == nil {
                cell = KDMarkLinkCell(style: .default, reuseIdentifier: cellId)
                cell!.selectionStyle = UITableViewCellSelectionStyle.none
            }
            cell!.baseDelegate = self
            cell!.nameLabel.text = model.title
            cell!.timeLabel.text = model.humanReadableUpdateTime
            if let headUrl = model.headUrl {
                cell!.headImageView.setImageWith(URL(string: headUrl), placeholderImage: UIImage.init(named: "todo"))

            }
            
            cell!.alarmClockOn = model.localEventId != nil
            if let icon = model.icon, KDString.isSolidString(icon) {
                if icon.lowercased().hasPrefix("http") {
                    cell!.contentHeadImageView.setImageWith(URL(string: icon), placeholderImage: UIImage(named:"mark_tip_link"))
                    cell!.contentSubtitleLabel.text = model.text
                } else {
                    cell!.contentHeadImageView.setImageWith(nil, placeholderImage: UIImage(named:XTFileUtils.thumbnailImage(withExt: icon)))
                    cell!.contentSubtitleLabel.text = XTFileUtils.fileSize(model.text ?? "0")
                }
            } else {
                cell!.contentHeadImageView.image = UIImage(named:"mark_tip_link")
                 cell!.contentSubtitleLabel.text = nil
            }
          
            cell!.contentTitleLabel.text = model.header
            
            return cell!
        case .guide:
            let cellId = "KDMarkListGuideCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? KDMarkListGuideCell
            if cell == nil {
                cell = KDMarkListGuideCell(style: .default, reuseIdentifier: cellId)
                cell!.selectionStyle = UITableViewCellSelectionStyle.none
            }
            return cell!
        case .empty:
            let cellId = "KDMarkListEmptyCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? KDMarkListEmptyCell
            if cell == nil {
                cell = KDMarkListEmptyCell(style: .default, reuseIdentifier: cellId)
                cell!.selectionStyle = UITableViewCellSelectionStyle.none
            }
            return cell!
            
        case .text: fallthrough
        default:
            let cellId = "KDMarkTextCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? KDMarkTextCell
            if cell == nil {
                cell = KDMarkTextCell(style: .default, reuseIdentifier: cellId)
            }
            configure(cell!, model: model)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = models[indexPath.row]
        if model.type == .text || model.type == .image {
            navigationController?.pushViewController(KDMarkDetailVC(model: model), animated: true)
        } else {
            if let uri = model.uri {
                let type = KDSchema.open(withUrl: uri, controller: self)
                if type == KDSchemeHostType.schemeHostType_HTTP || type == KDSchemeHostType.schemeHostType_HTTPS {
                    let webVC = KDWebViewController(urlString:uri)
                    self.navigationController?.pushViewController(webVC!, animated: true)
                }
            }
        }
    }
    //
    //    func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool {
    //        return true
    //    }
    //
    //    func swipeableTableViewCell(cell: SWTableViewCell!, canSwipeToState state: SWCellState) -> Bool {
    //        return true
    //    }
    //
    //    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
    //        guard let indexPath = tableView.indexPathForCell(cell)
    //            else { return }
    //        let model = models[indexPath.row]
    //
    //        switch index {
    //        case 0:
    //            KDEventAnalysis.event(mark_swipe_alarm)
    //            KDMarkModel.onSetEvent(self, model: model)
    //        case 1:
    //            KDEventAnalysis.event(mark_swipe_delete)
    //            KDOpenAPIClientWrapper.sharedInstance.deleteMark(markId: model.id ?? "", completion: { (succ, errorMsg, data) in
    //                if succ {
    //                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
    //                        if (XTDataBaseDao.sharedDatabaseDaoInstance().deleteMarkWithMarkId(model.id ?? "")) {
    //                            self.models.removeAtIndex(indexPath.row)
    //                            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    //                            if self.models.count == 0 {
    //                                self.showEmpty()
    //                            }
    //                            self.refreshFooter()
    //                        }
    //                    }
    //                } else {
    //                    KDAlert.showToast(inView: self.view, text: errorMsg)
    //                }
    //            })
    //        default: break
    //        }
    //        cell.hideUtilityButtonsAnimated(true)
    //    }
    
    func rightButtons() -> [AnyObject] {
        let buttons = NSMutableArray()
        buttons.sw_addUtilityButton(with: UIColor.kdBackgroundColor1(), icon: UIImage(named: "mark_btn_remind"))
        buttons.sw_addUtilityButton(with: UIColor.kdBackgroundColor1(), icon: UIImage(named: "mark_btn_delete"))
        return buttons as [AnyObject]
    }
    
    // MARK: 上拉下拉
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
    
    func remindButtonPressedWithCell(_ cell: KDMarkListBaseCell) {
        guard let indexPath = tableView.indexPath(for: cell)
            else { return }
        let model = models[indexPath.row]
//        KDEventAnalysis.event(mark_swipe_alarm)
        KDMarkModel.onSetEvent(self, model: model)
    }
    
    func deleteButtonPressedWithCell(_ cell: KDMarkListBaseCell) {
        guard let indexPath = tableView.indexPath(for: cell)
            else { return }
        let model = models[indexPath.row]
//        KDEventAnalysis.event(mark_swipe_delete)
        KDOpenAPIClientWrapper.sharedInstance.deleteMark(markId: model.id ?? "", completion: { (succ, errorMsg, data) in
            if succ {
                DispatchQueue.main.async { () -> Void in
                    if (XTDataBaseDao.sharedDatabaseDaoInstance().deleteMark(withMarkId: model.id ?? "")) {
                        self.models.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                        if self.models.count == 0 {
                            self.loadDataFromServer(direction: .new, markId: nil)
                        }
                        self.refreshFooter()
                    }
                }
            } else {
                KDAlert.showToast(inView: self.view, text: errorMsg)
            }
        })
        
    }
    
}
