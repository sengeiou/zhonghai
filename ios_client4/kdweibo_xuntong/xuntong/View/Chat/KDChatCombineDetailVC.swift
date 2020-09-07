//
//  KDChatCombineDetailVC.swift
//  kdweibo
//
//  Created by Darren Zheng on 7/26/16.
//  Copyright © 2016 www.kingdee.com. All rights reserved.
//

@objc protocol KDChatCombineDetailVCDataSource {
    func chatViewController() -> XTChatViewController?
}

final class KDChatCombineDetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate, KDChatCombineTextCellDelegate ,MJPhotoBrowserDelegate {
    
    // MARK: - Table View
    var models = [KDMarkModel]()
    var record: RecordDataModel?
    weak var dataSource: KDChatCombineDetailVCDataSource?
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(KDChatCombineTextCell.self, forCellReuseIdentifier: "KDChatCombineTextCell")
        tableView.register(KDChatCombineImageCell.self, forCellReuseIdentifier: "KDChatCombineImageCell")
        tableView.register(KDChatCombineLinkCell.self, forCellReuseIdentifier: "KDChatCombineLinkCell")
        tableView.register(KDChatCombineVoiceCell.self, forCellReuseIdentifier: "KDChatCombineVoiceCell")
        tableView.register(KDChatCombineLocationCell.self, forCellReuseIdentifier: "KDChatCombineLocationCell")
        tableView.register(KDChatCombineVideoCell.self, forCellReuseIdentifier: "KDChatCombineVideoCell")
        tableView.tableFooterView = UIView() // 余分な境界線を非表示にする
        return tableView
    }()
    
    override func viewDidDisappear(_ animated: Bool) {
        if (audioPlayer?.isPlaying())! {
            audioPlayer?.stopPlay()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.kdBackgroundColor1()
        view.addSubview(tableView)
        tableView.mas_makeConstraints { make in
            make?.top.equalTo()(self.tableView.superview!.top)?.with().offset()(8)
            make?.left.equalTo()(self.tableView.superview!.left)?.with().offset()(0)
            make?.right.equalTo()(self.tableView.superview!.right)?.with().offset()(-0)
            make?.bottom.equalTo()(self.tableView.superview!.bottom)?.with().offset()(-0)
            return()
        }
        if let model = record?.param.paramObject as? MessageCombineForwardDataModel {
            title = model.title
            KDOpenAPIClientWrapper.sharedInstance.getMerge(model.mergeId, completion: { (succ, errorMsg, data) in
                if let array = data as? [[String : AnyObject]], succ {
                    array.forEach { self.models += [KDMarkModel(dict: $0)] }
                }
                self.models.sort { $0.updateTime! < $1.updateTime! }
                DispatchQueue.main.async { () -> Void in
                    if self.models.count > 0 {
                        self.tableView.reloadData()
                    }
                }
            })
        }
        
        if BOSSetting.shared().openWaterMark(UInt(WaterMarkTypeConversation))
        {
            KDWaterMarkAddHelper.cover(on: self.view, withFrame: self.view.bounds)
        }
    
        tableView.separatorColor = UIColor.kdDividingLine()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = models[indexPath.row]
        var cellId = ""
        switch model.type {
        case .voice:
            cellId = "KDChatCombineVoiceCell"
        case .image:
            cellId = "KDChatCombineImageCell"
        case .link:
            cellId = "KDChatCombineLinkCell"
        case .location:
            cellId = "KDChatCombineLocationCell"
        case .video:
            cellId = "KDChatCombineVideoCell"
        case .text: fallthrough
        default:
            cellId = "KDChatCombineTextCell"
        }
        return tableView.fd_heightForCell(withIdentifier: cellId, cacheBy: indexPath, configuration: {  cell in
            self.configure(cell as! UITableViewCell, model: model)
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func configure(_ cell: UITableViewCell, model: KDMarkModel) {
        
        switch cell {
        case let cell as KDChatCombineVoiceCell:
            cell.titleLabel.text = model.title
            cell.timeLabel.text = model.humanReadableUpdateTime
            if let headUrl = model.headUrl {
                cell.headView.setImageWith(URL(string: headUrl), placeholderImage: XTImageUtil.headerDefaultImage())
            }
            if let len = model.length, let lenInt = Int(len) {
                cell.msgLen = CGFloat(lenInt)
            }
            cell.delegate = self
            
        case let cell as KDChatCombineTextCell:
            cell.titleLabel.text = model.title
            cell.timeLabel.text = model.humanReadableUpdateTime
            if let headUrl = model.headUrl {
                cell.headView.setImageWith(URL(string: headUrl), placeholderImage: XTImageUtil.headerDefaultImage())
            }
            if let text = model.text {
                cell.contentTextView.attributedText = KDRichTextView.renderedText(text as NSString, patternOptionSet: [], font: FS3!, textColor: FC1!)
            } else {
                cell.contentTextView.text = " "
            }
            
        case let cell as KDChatCombineImageCell:
            cell.titleLabel.text = model.title
            cell.timeLabel.text = model.humanReadableUpdateTime
            if let headUrl = model.headUrl {
                cell.headView.setImageWith(URL(string: headUrl), placeholderImage: XTImageUtil.headerDefaultImage())
            }
            
            if let imageUrl = model.imgUrl {
                cell.contentImageView.setImageWith(URL(string: imageUrl), placeholderImage: XTImageUtil.cellThumbnailImage(withType: 2))
            }
            
        case let cell as KDChatCombineLinkCell:
            cell.titleLabel.text = model.title
            cell.timeLabel.text = model.humanReadableUpdateTime
            if let headUrl = model.headUrl {
                cell.headView.setImageWith(URL(string: headUrl), placeholderImage: XTImageUtil.headerDefaultImage())
            }
            
            if let icon = model.icon, KDString.isSolidString(icon) {
                if icon.lowercased().hasPrefix("http") {
                    cell.contentHeadImageView.setImageWith(URL(string: icon), placeholderImage: UIImage(named:"mark_tip_link"))
                    cell.contentSubtitleLabel.text = model.text
                } else {
                    cell.contentHeadImageView.setImageWith(nil, placeholderImage: UIImage(named:XTFileUtils.thumbnailImage(withExt: icon)))
                    cell.contentSubtitleLabel.text = XTFileUtils.fileSize(model.text ?? "0")
                }
            } else {
                cell.contentHeadImageView.image = UIImage(named:"mark_tip_link")
            }
            cell.contentTitleLabel.text = model.header
            
        case let cell as KDChatCombineLocationCell:
            cell.titleLabel.text = model.title
            cell.timeLabel.text = model.humanReadableUpdateTime
            if let headUrl = model.headUrl {
                cell.headView.setImageWith(URL(string: headUrl), placeholderImage: XTImageUtil.headerDefaultImage())
            }
            
            if let imageUrl = model.imgUrl {
                cell.contentImageView.setImageWith(URL(string: imageUrl), placeholderImage: XTImageUtil.cellThumbnailImage(withType: 2))
            }
            
            if let text = model.text
            {
                if let dataDic:NSDictionary? = (NSString.jsonObject(with: text) as? NSDictionary)
                {
                    if let dataModel = MessageTypeLocationDataModel.init(dictionary:dataDic as? [AnyHashable: Any])
                    {
                        if let address = dataModel.address {
                            cell.detailLabel.text = address
                        }
                    }
                }
            }
            
        case let cell as KDChatCombineVideoCell:
            cell.titleLabel.text = model.title
            cell.timeLabel.text = model.humanReadableUpdateTime
            if let headUrl = model.headUrl {
                cell.headView.setImageWith(URL(string: headUrl), placeholderImage: XTImageUtil.headerDefaultImage())
            }
            
            
            if let text = model.text
            {
                if let dataDic:NSDictionary? = (NSString.jsonObject(with: text) as? NSDictionary)
                {
                    if let dataModel = MessageTypeShortVideoDataModel.init(dictionary:dataDic as? [AnyHashable: Any])
                    {
                        cell.dataModel = dataModel
                        
                        if let imageUrl = dataModel.thumbImageUrl() {
                            cell.contentImageView.setImageWith(URL(string: imageUrl), placeholderImage: XTImageUtil.cellThumbnailImage(withType: 2))
                        }
                        
                        if let size = dataModel.videoSize() {
                            cell.sizeLabel.text = size
                        }
                        
                        if let duartion = dataModel.videoDuartion() {
                            cell.durationLabel.text = duartion
                        }
                    }
                }
            }

        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        switch model.type {
        case .voice:
            let cellId = "KDChatCombineVoiceCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? KDChatCombineVoiceCell
            configure(cell!, model: model)
            return cell!
        case .image:
            let cellId = "KDChatCombineImageCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? KDChatCombineImageCell
            configure(cell!, model: model)
            return cell!
        case .link:
            let cellId = "KDChatCombineLinkCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? KDChatCombineLinkCell
            configure(cell!, model: model)
            return cell!
        case .location:
            let cellId = "KDChatCombineLocationCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? KDChatCombineLocationCell
            configure(cell!, model: model)
            return cell!
        case .video:
            let cellId = "KDChatCombineVideoCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? KDChatCombineVideoCell
            configure(cell!, model: model)
            return cell!
        case .text: fallthrough
        default:
            let cellId = "KDChatCombineTextCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? KDChatCombineTextCell
            configure(cell!, model: model)
            return cell!
        }
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = models[indexPath.row]
        if model.type == .image {
            // 打开图片
            if let urlString = model.imgUrl {
                let photo = MJPhoto()
                photo.originUrl = URL(string: urlString)
                photo.bFullScrean = true
                let photoBrowser = MJPhotoBrowser()
                photoBrowser.delegate = self
                photoBrowser.photos = [photo]
                //photoBrowser.bHideToolBar = true
                photoBrowser.view.backgroundColor = UIColor.black
                photoBrowser.show()
            }
        }
        
        if model.type == .link {
            //KDEventAnalysis.event(event_merge_chatlog_open_app)
            if let uri = model.uri {
                let type = KDSchema.open(withUrl: uri, controller: self)
                if type == KDSchemeHostType.schemeHostType_HTTP || type == KDSchemeHostType.schemeHostType_HTTPS {
                    if let appid = model.appid {
                        let webVC = KDWebViewController(urlString:uri , appId: appid)
                        self.navigationController?.pushViewController(webVC!, animated: true)
                    } else {
                        let webVC = KDWebViewController(urlString:uri)
                        self.navigationController?.pushViewController(webVC!, animated: true)
                    }
                    
                }
            }
        }
        
        if model.type == .location {
            //打开地图界面
            if let text = model.text
            {
                if let dataDic:NSDictionary? = (NSString.jsonObject(with: text) as? NSDictionary)
                {
                    if let dataModel = MessageTypeLocationDataModel.init(dictionary:dataDic as? [AnyHashable: Any])
                    {
                        let mvc:KDMapViewController = KDMapViewController.init()
                        mvc.obj = (dataModel as? KDMapViewData)
                        mvc.data = dataModel
                        self.navigationController?.pushViewController(mvc, animated: true)
                    }
                }
            }
        }
    }
    
    let audioPlayer = BOSAudioPlayer.shared()
    var voiceData: Data?
    var isSpeechFirstRead = false
    func play(_ filePath: String, msgId: String, cell: KDCommonAudioCell) {
        voiceData = DecodeAMRToWAVE(ContactUtils.xor80(try? Data(contentsOf: URL(fileURLWithPath: filePath))))
        if voiceData == nil {
            
        }
        if let voiceData = voiceData {
            audioPlayer?.createPlayer(with: voiceData, identifier: msgId, cell: cell)
            if (audioPlayer?.isPlaying())! {
                audioPlayer?.stopPlay()
            } else {
                audioPlayer?.startPlay()
            }
        }
    }
    
//    func play(_ filePath: String) {
//        voiceData = DecodeAMRToWAVE(ContactUtils.xor80(try? Data(contentsOf: URL(fileURLWithPath: filePath))))
//        if voiceData == nil {
//            dataInternal.record.msgPlayType = MessagePlayTypeFailue
//            // 更新页面？
//            updateCell(chatVC, tableView: chatVC.bubbleTable, dataInternal: dataInternal)
//        }
//        if let voiceData = voiceData {
//            audioPlayer.createPlayer(with: voiceData, identifier: dataInternal.record.msgId, cell: self)
//            if (audioPlayer.isPlaying()) {
//                audioPlayer.stopPlay()
//            } else {
//                audioPlayer.startPlay()
//            }
//        }
//    }
    
    func voiceCell(_ cell: KDChatCombineVoiceCell, didTapVoiceView voiceView: BubbleVoiceView) {
        guard let indexPath = tableView.indexPath(for: cell)
            else { return }
        let model = models[(indexPath as IndexPath).row]
        if let msgId = model.msgId, let dataSource = dataSource, let group = dataSource.chatViewController()?.group, let groupId = group.groupId {
            
            if let filePath = ContactUtils.recordFilePath(withGroupId: groupId) {
                voiceData = DecodeAMRToWAVE(ContactUtils.xor80(try! Data(contentsOf: URL(fileURLWithPath: filePath))))
                
                if voiceData != nil {
                    if let voiceData = voiceData {
                        audioPlayer?.createPlayer(with: voiceData, identifier: msgId, cell: cell)
                        if (audioPlayer?.isPlaying())! {
                            audioPlayer?.stopPlay()
                        } else {
                            audioPlayer?.startPlay()
                        }
                        return
                    }
                }
            }
            
            func onGetVoiceDataSucceed(_ content: Data) {
                if let path = ContactUtils.recordFilePath(withGroupId: groupId) {
                    let filePath = "\(path)/\(msgId).xt"
                    do {
                     try content.write(to: URL(fileURLWithPath: filePath), options: [NSData.WritingOptions.atomicWrite])
                    } catch {
                    
                    }
                    play(filePath, msgId: msgId, cell: cell)
                }

            }
            
            func onGetVoiceDataFail() {
                
                
            }
            
            KDContactClientWrapper.sharedInstance.getFile(msgId) { succ, errorMsg, data in
                if succ {
                    if let data = data as? Data {
                        onGetVoiceDataSucceed(data)
                    }
                } else {
                    onGetVoiceDataFail()
                }
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
