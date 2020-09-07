//
//  KDMarkDetailVC.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/10.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//



final class KDMarkDetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate,MJPhotoBrowserDelegate {
    
    // MARK: - Table View
    var model: KDMarkModel!
    var imageHeight: CGFloat = 0
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(model: KDMarkModel) {
        self.init(nibName: nil, bundle: nil)
        self.model = model
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.kdBackgroundColor1()
        return tableView
    }()
    
    override func viewDidLoad() {
        title = ASLocalizedString("Mark_mark")// "标记"
        view.backgroundColor = UIColor.kdBackgroundColor1()
        view.addSubview(tableView)
        tableView.mas_makeConstraints { make in
            make?.top.equalTo()(self.tableView.superview!.top)?.with().offset()(8)
            make?.left.equalTo()(self.tableView.superview!.left)?.with().offset()(0)
            make?.right.equalTo()(self.tableView.superview!.right)?.with().offset()(-0)
            make?.bottom.equalTo()(self.tableView.superview!.bottom)?.with().offset()(-0)
            return()
        }
        tableView.register(KDMarkDetailImageCell.self, forCellReuseIdentifier: "KDMarkDetailImageCell")
        tableView.register(KDMarkDetailTextCell.self, forCellReuseIdentifier: "KDMarkDetailTextCell")

        let button = UIButton.btnInNav(with: UIImage(named:"nav_btn_more_normal"), highlightedImage: UIImage(named:"nav_btn_more_press"))
        button?.addTarget(self, action: #selector(KDMarkDetailVC.rightBarButtonPressed), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button!)
        
        //加水印
        if BOSSetting.shared().openWaterMark(WaterMarkType(WaterMarkTypeConversation))
        {
            let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            KDWaterMarkAddHelper.cover(on: self.tableView,withFrame: frame);
        }
        else {
            KDWaterMarkAddHelper.removeWaterMark(from: self.tableView)
        }
    }
    
    func rightBarButtonPressed() {
        let actionsheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle:ASLocalizedString("Global_Cancel"), destructiveButtonTitle: nil, otherButtonTitles: ASLocalizedString("Mark_setAlert"), ASLocalizedString("Mark_Unmark"))
        actionsheet.show(in: view)
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        switch buttonIndex {
        case 1:
//            KDEventAnalysis.event(mark_detail_more, attributes: [label_mark_detail_more_type: label_mark_detail_more_type_alarm])
            KDMarkModel.onSetEvent(self, model: model)
        case 2:
//            KDEventAnalysis.event(mark_detail_more, attributes: x[label_mark_detail_more_type: label_mark_detail_more_type_detele])
            KDOpenAPIClientWrapper.sharedInstance.deleteMark(markId: model.id ?? "", completion: { (succ, errorMsg, data) in
                DispatchQueue.main.async { () -> Void in
                    XTDataBaseDao.sharedDatabaseDaoInstance().deleteMark(withMarkId: self.model.id ?? "")
                    self.navigationController?.popViewController(animated: true)
                }
            })
        default:
            break
        }
    }
    
    func configure(_ cell: UITableViewCell, model: KDMarkModel) {
        if let cell = cell as? KDMarkDetailImageCell {
            cell.nameLabel.text = model.title
            cell.timeLabel.text = model.humanReadableUpdateTime
            if let headUrl = model.headUrl {
                cell.headImageView.setImageWith(URL(string: headUrl), placeholderImage: XTImageUtil.headerDefaultImage())
            }
            
            if let desc = self.model.titleDesc, KDString.isSolidString(desc) {
                cell.groupNameLabel.text = "来自\(desc)"
            }
            cell.alarmClockOn = model.localEventId != nil
            if let imageUrl = model.imgUrl {
               let imageUrl = imageUrl + "?original"
                cell.contentImageView.image = XTImageUtil.cellThumbnailImage(withType: 2)
                SDWebImageManager.shared().download(with: URL(string: imageUrl), options: [], progress: nil, completed: { (image, error, type, bo, url) in
                    if image != nil
                    {
                        cell.contentImageView.image = image
                    }
                    cell.contentImageView.mas_updateConstraints { make in
                        make?.height.mas_equalTo()((KDFrame.screenWidth() - 24) * cell.contentImageView.image!.heightDivideWidthRatio)
                    }
                })
                
                cell.onTapContentImageView = {
                    let photo = MJPhoto()
                    photo.originUrl = URL(string: imageUrl)
                    photo.bFullScrean = true
                    let photoBrowser = MJPhotoBrowser()
                    photoBrowser.delegate = self
                    photoBrowser.photos = [photo]
//                    photoBrowser.currentPhotoIndex = 0;
                    photoBrowser.bHideToolBar = true
                    photoBrowser.view.backgroundColor = UIColor.black
                    photoBrowser.show()
                }
            }

        }
        
        if let cell = cell as? KDMarkDetailTextCell {
            cell.contentTextView.onKeywordTap = { linkPrefix, keyword in
                if linkPrefix == KDRegex.URLPrefix {
                    if KDString.isSolidString(keyword) {
                        let webVC = KDWebViewController(urlString:keyword)
                        self.navigationController?.pushViewController(webVC!, animated: true)
                    }
                }
                if linkPrefix == KDRegex.PhonePrefix {
                    if KDString.isSolidString(keyword) {
                        XTTELHandle.shared().tel(withPhoneNumbel: keyword)
                    }
                }
                
            }
            cell.nameLabel.text = model.title
            cell.timeLabel.text = model.humanReadableUpdateTime
            if let headUrl = model.headUrl {
                cell.headImageView.setImageWith(URL(string: headUrl), placeholderImage: XTImageUtil.headerDefaultImage())
            }
            cell.alarmClockOn = model.localEventId != nil
            if let text = model.text {
                cell.contentTextView.attributedText = KDRichTextView.renderedText(text as NSString, patternOptionSet: [.emotion, .URL, .phone], font: FS3!, textColor: FC1!)
            }
            
            if let desc = model.titleDesc, KDString.isSolidString(desc) {
                cell.groupNameLabel.text = "来自\(desc)"
                KDFrame.setHeight(cell.groupNameLabel, height: KDString.heightForString(cell.groupNameLabel.text!, width: KDFrame.screenWidth() - (12 + 12), font: FS6!))
            }
            
            cell.contentTextView.isHidden = false
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let fullHeight = KDFrame.screenHeight() - 64 - 44 - 8
        if indexPath.row == 0 {
            switch model.type {
            case .image:
                let height = tableView.fd_heightForCell(withIdentifier: "KDMarkDetailImageCell", cacheBy: indexPath, configuration: {  cell in
                    self.configure(cell as! UITableViewCell, model: self.model)
                })
                return max(height, fullHeight)
            case .text: fallthrough
            default:
                let height = tableView.fd_heightForCell(withIdentifier: "KDMarkDetailTextCell", cacheBy: indexPath, configuration: {  cell in
                    self.configure(cell as! UITableViewCell, model: self.model)
                })
                return max(height, fullHeight)
            }
        } else {
            return 44
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            switch model.type {
            case .image:
                let cellId = "KDMarkDetailImageCell"
                var cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? KDMarkDetailImageCell
                if cell == nil {
                    cell = KDMarkDetailImageCell(style: .default, reuseIdentifier: cellId)
                    cell!.selectionStyle = UITableViewCellSelectionStyle.none
                }
                configure(cell!, model: model)
                
                return cell!
            case .text: fallthrough
            default:
                let cellId = "KDMarkDetailTextCell"
                var cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? KDMarkDetailTextCell
                if cell == nil {
                    cell = KDMarkDetailTextCell(style: .default, reuseIdentifier: cellId)
                    cell!.selectionStyle = UITableViewCellSelectionStyle.none
                }
                configure(cell!, model: model)

                return cell!
            }
            
        case 1: fallthrough
        default:
            let cellId = "KDMarkButtonCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? KDMarkButtonCell
            if cell == nil {
                cell = KDMarkButtonCell(style: .default, reuseIdentifier: cellId)
                cell!.selectionStyle = UITableViewCellSelectionStyle.blue
            }
            cell!.label.text = ASLocalizedString("Mark_Jump")
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0: break
        case 1: fallthrough
        default:
//            KDEventAnalysis.event(mark_detail_jump_back)
            if let uri = model.uri {
                KDSchema.open(withUrl: uri, controller: self)
            }
        }
    }
    
    //识别二维码
    func photoBrowser(_ photoBrowser: MJPhotoBrowser!, scanWithresult result: String!) {
        KDQRAnalyse .sharedManager().execute(result) { (qrCode, qrResult) in
            
            photoBrowser.hide()
            KDQRAnalyse.sharedManager().gotoResultVC(inTargetVC: self, withQRResult: qrResult, andQRCode: qrCode)
            
        }
    }

}
