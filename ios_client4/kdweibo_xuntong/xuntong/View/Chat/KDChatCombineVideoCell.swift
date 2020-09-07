//
//  KDChatCombineVideoCell.swift
//  kdweibo
//
//  Created by fang.jiaxin on 16/11/10.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

import UIKit

class KDChatCombineVideoCell: KDChatCombineBaseCell,ASIProgressDelegate {
    
    var dataModel:MessageTypeShortVideoDataModel?
    var chatVC:XTChatViewController?
    
    lazy var contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = XTImageUtil.cellThumbnailImage(withType: 2)
        return imageView
    }()
    
    lazy var playBtn: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "videoPlay"), for: UIControlState())
        btn.addTarget(self, action:#selector(KDChatCombineVideoCell.loadAndPlayVideo), for: .touchUpInside)
        return btn
    }()
    
    lazy var progressHud: MBProgressHUD = {
        let hud = MBProgressHUD.init(view: self.contentImageView)
        hud?.color = UIColor.clear
        hud?.mode = MBProgressHUDModeDeterminate
        return hud!
    }()

    
    lazy var detailBgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage.init(named: "locationBg")
        return imageView
    }()
    
    lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.font = FS6
        label.textColor = FC6
        label.textAlignment = .left
        return label
    }()
    
    lazy var sizeLabel: UILabel = {
        let label = UILabel()
        label.font = FS6
        label.textColor = FC6
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(contentImageView)
        contentImageView.mas_makeConstraints { make in
            make?.height.mas_equalTo()(140)
            make?.left.equalTo()(self.contentImageView.superview!.left)?.with().offset()(12 + 44 + 12)
            make?.right.equalTo()(self.contentImageView.superview!.right)?.with().offset()(-12 - 44 - 12)
            make?.top.equalTo()(self.headView.bottom)?.with().offset()(12)
            make?.bottom.equalTo()(self.contentImageView.superview!.bottom)?.with().offset()(-12)
            return()
        }
        
        contentImageView.addSubview(playBtn)
        playBtn.mas_makeConstraints { make in
            make?.height.mas_equalTo()(100)
            make?.width.mas_equalTo()(100)
            make?.centerX.equalTo()(self.contentImageView.centerX)
            make?.centerY.equalTo()(self.contentImageView.centerY)
            return()
        }
        
        contentImageView.addSubview(progressHud)
        
        contentImageView.addSubview(detailBgImageView)
        detailBgImageView.mas_makeConstraints { make in
            make?.height.mas_equalTo()(30)
            make?.left.equalTo()(self.detailBgImageView.superview!.left)?.with().offset()(0)
            make?.right.equalTo()(self.detailBgImageView.superview!.right)?.with().offset()(0)
            make?.bottom.equalTo()(self.detailBgImageView.superview!.bottom)?.with().offset()(0)
            return()
        }
        
        contentImageView.addSubview(durationLabel)
        durationLabel.mas_makeConstraints { make in
            make?.height.mas_equalTo()(24)
            make?.width.mas_equalTo()(self.frame.size.width/2)
            make?.left.equalTo()(self.durationLabel.superview!.left)?.with().offset()(5)
            make?.centerY.equalTo()(self.detailBgImageView.centerY)
            return()
        }
        
        contentImageView.addSubview(sizeLabel)
        sizeLabel.mas_makeConstraints { make in
            make?.height.mas_equalTo()(24)
            make?.width.mas_equalTo()(self.frame.size.width/2)
            make?.right.equalTo()(self.sizeLabel.superview!.right)?.with().offset()(-5)
            make?.centerY.equalTo()(self.detailBgImageView.centerY)
            return()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadAndPlayVideo(){
        
        if dataModel == nil
        {
            return
        }
        
        let file:FileModel = FileModel.init()
        file.fileId = dataModel?.file_id;
        file.ext = dataModel?.ext;
 
        if (dataModel?.videoUrl != nil) && FileManager.default.fileExists(atPath: (dataModel?.videoUrl)!)
        {
            //直接播放
            self.playVideo((dataModel?.videoUrl)!)
        }
        else
        {
            //如果存在  则直接播放 否则请求服务器
            let path = ContactUtils.fileFilePath().appendingFormat("/%@.%@", file.fileId,file.ext)
            if FileManager.default.fileExists(atPath: path)
            {
                self.playVideo(path)
            }
            else
            {
                playBtn.isHidden = true
                progressHud.show(true)
                
                let messageHandler:KDMediaMessageHandler = KDMediaMessageHandler.shared()
                messageHandler.progressDelegate = self
                messageHandler.downLoadFile(byFile: file, finish: { (downLoadUrl, success) in
                    if success
                    {
                        self.progressHud.hide(true)
                        self.playBtn.isHidden = false;
                        self.playVideo(downLoadUrl!)
                    }
                })
            }
            
        }
    }
    
    func setProgress(_ newProgress: Float) {
        progressHud.progress = newProgress
    }
    
    func playVideo(_ file:String) {
        if self.chatVC == nil
        {
            let vc:XTChatViewController = XTChatViewController.init()
            self.chatVC = vc
        }
        self.chatVC?.playVideo(file)
    }
}
