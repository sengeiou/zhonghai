//
//  KDNoticeBoxView.swift
//  kdweibo
//
//  Created by Darren Zheng on 2017/2/13.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import UIKit

// MARK: - Input -

@objc protocol KDNoticeBoxViewContentDataSource {
    
    // 标题
    var boxViewTitle: String? { get }
    
    // 副标题
    var boxViewSubTitle: String? { get }
    
    // 内容
    var boxViewContent: String? { get }
    
}

enum KDNoticeBoxMode {
    
    // 加载过程
    case loading
    
    // 空页面
    // false: 普通用户不显示创建公告
    // true: 管理员可以创建公告
    case empty(isAdmin: Bool)
    
    // 正常显示内容
    case normal(dataSource: KDNoticeBoxViewContentDataSource?)
    
    
}

protocol KDNoticeBoxViewDataSource: class {
    var noticeBoxViewMode: KDNoticeBoxMode { get }
}

// MARK: - Output -

@objc protocol KDNoticeBoxViewDelegate {
    
    // 管理员快速创建公告
    @objc optional func boxViewCreateButtonPressed(_ boxView: KDNoticeBoxView)
    
    // 点击公告盒子
    @objc optional func boxViewPressed(_ boxView: KDNoticeBoxView)
    
}

class KDNoticeBoxView: UIView {
    
    // MARK: - Properties -
    
    weak var delegate: KDNoticeBoxViewDelegate?
    weak var dataSource: KDNoticeBoxViewDataSource? {
        didSet {
            update()
        }
    }
    
    lazy var emptyTextView: KDRichTextView = {
        $0.backgroundColor = UIColor.clear
        $0.isHidden = true
        $0.linkTextAttributes = NSMutableAttributedString.dz_linkAttribute(withLinkColor: FC5) as! [String: AnyObject]
        $0.onKeywordTap = { linkPrefix, keyword in
            if keyword == ASLocalizedString("Notice_Quick_Create") {
                KDEventAnalysis.event(event_dialog_group_announcement_create)
                KDEventAnalysis.eventCountly(event_dialog_group_announcement_create)
                self.delegate?.boxViewCreateButtonPressed?(self)
            }
        }
        return $0
    }(KDRichTextView())
    
    lazy var titleLabel: UILabel = {
        $0.font = FS3
        $0.textColor = FC1
        $0.isHidden = true
        return $0
    }(UILabel())
    
    lazy var contentLabel: UILabel = {
        $0.font = FS6
        $0.textColor = FC1
        $0.numberOfLines = 2
        $0.isHidden = true
        return $0
    }(UILabel())
    
    lazy var subTitleLabel: UILabel = {
        $0.font = FS7
        $0.textColor =  FC2
        return $0
    }(UILabel())
    
    lazy var boxButton: UIButton = {
        $0.addTarget(self, action: #selector(KDNoticeBoxView.boxButtonPressed), for: UIControlEvents.touchUpInside)
        $0.isHidden = true
        return $0
    }(UIButton())
    
    lazy var prefixLabel: UILabel = {
        $0.font = FS7
        $0.textColor =  UIColor.white
        $0.text = ASLocalizedString("Notice")
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 9
        $0.textAlignment = .center
        $0.backgroundColor = FC5
        return $0
    }(UILabel())
    
    func boxButtonPressed() {
        delegate?.boxViewPressed?(self)
    }
    
    lazy var topLine: UIView = {
        $0.backgroundColor = UIColor(hexRGB: "44BBFC", alpha: 0.1)
        return $0
    }(UIView())
    
    lazy var loadingView: UIActivityIndicatorView = {
        $0.isHidden = true
        return $0
    }(UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray))
    
    // MARK: - Setup -
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var bindings: [String: AnyObject] = {
        return [
            "emptyTextView" : self.emptyTextView,
            "titleLabel" : self.titleLabel,
            "contentLabel" : self.contentLabel,
            "boxButton" : self.boxButton,
            "topLine": self.topLine,
            "loadingView": self.loadingView,
            "subTitleLabel": self.subTitleLabel,
            "prefixLabel": self.prefixLabel,
            ]
    }()
    
    var metrics: [String: AnyObject] {
        return [
            :
        ]
    }
    
    let vflsEmpty: [String] = [
        "V:|-4-[topLine(1)]",
        "H:|[topLine]|",
        ]
    let vflsLoading: [String] = [
    ]
    let vflsNormal: [String] = [
        "H:|-12-[prefixLabel(33)]-5-[titleLabel]-12-|",
        "H:|-12-[contentLabel]-12-|",
        "H:|-12-[subTitleLabel]-12-|",
        "H:|[boxButton]|",
        "V:|[boxButton]|",
        "V:[prefixLabel(18)]",
        "V:|-4-[topLine(1)]-10-[titleLabel]-4-[subTitleLabel]-8-[contentLabel]",
        "V:|-4-[topLine(1)]-11-[prefixLabel]",
        "H:|[topLine]|",
        ]
    
    func setup() {
        addSubviews([loadingView, emptyTextView, prefixLabel, titleLabel, subTitleLabel, contentLabel, topLine, boxButton])
        
        backgroundColor = UIColor(hexRGB: "F9FAFB")
        
        layer.cornerRadius = 6
        
        layer.addShadow(shadowColor: UIColor(hexRGB: "D8DDE7"),
                        shadowOffset: CGSize(width: 0, height: 2),
                        shadowOpacity: 0.8,
                        shadowRadius: 5)
    }
    
    // MARK: - Update -
    var currentConstraints = [NSLayoutConstraint]()
    
    func update() {
        
        guard let dataSource = dataSource
            else { return }
        
        if currentConstraints.count > 0 {
            removeConstraints(currentConstraints)
        }
        
        loadingView.stopAnimating()
        
        switch dataSource.noticeBoxViewMode {
            
        case .empty(let isAdmin):
            
            currentConstraints += kd_setupVFL(bindings,
                                              metrics: metrics,
                                              constraints: vflsEmpty,
                                              delayInvoke: false)
            
            currentConstraints += [emptyTextView.kd_setCenterX()]
            currentConstraints += [emptyTextView.kd_setCenterY()]
            
            emptyTextView.isHidden = false
            if isAdmin {
                let mStr = NSMutableAttributedString(string: ASLocalizedString("Notice_No_And_Create"))
                mStr.dz_insertImage(withName: "notice_tip_default", location: 0, bounds: CGRect(x: 0, y: -3, width: (FS4?.lineHeight)!, height: (FS4?.lineHeight)!))
                mStr.dz_setFont(FS4)
                mStr.dz_setTextColor(FC2, range: NSMakeRange(3, 6))
                mStr.dz_setTextColor(FC5, range: NSMakeRange(9, 4))
                mStr.dz_setLink(with: NSMakeRange(9, 4), url: URL(fileURLWithPath: ASLocalizedString("Notice_Quick_Create")))
                emptyTextView.attributedText =  mStr  // [图片]暂无群公告，快速创建
            } else {
                let mStr = NSMutableAttributedString(string: ASLocalizedString("Notice_No"))
                mStr.dz_insertImage(withName: "notice_tip_default", location: 0, bounds: CGRect(x: 0, y: -3, width: (FS4?.lineHeight)!, height: (FS4?.lineHeight)!))
                mStr.dz_setFont(FS4)
                mStr.dz_setTextColor(FC2, range: NSMakeRange(3, 5))
                emptyTextView.attributedText =  mStr  // [图片]快速创建
            }
            boxButton.isHidden = true
            titleLabel.isHidden = true
            contentLabel.isHidden = true
            subTitleLabel.isHidden = true
            prefixLabel.isHidden = true
        case .normal(let contentDataSource):
            
            currentConstraints += kd_setupVFL(bindings,
                                              metrics: metrics,
                                              constraints: vflsNormal,
                                              delayInvoke: false)
            emptyTextView.isHidden = true
            boxButton.isHidden = false
            titleLabel.isHidden = false
            contentLabel.isHidden = false
            subTitleLabel.isHidden = false
            prefixLabel.isHidden = false
            titleLabel.text = contentDataSource?.boxViewTitle ?? " "
            contentLabel.text = contentDataSource?.boxViewContent ?? ""
            subTitleLabel.text = contentDataSource?.boxViewSubTitle ?? ""

        case .loading:
            currentConstraints += kd_setupVFL(bindings,
                                              metrics: metrics,
                                              constraints: vflsLoading,
                                              delayInvoke: false)
            currentConstraints += [loadingView.kd_setCenterX()]
            currentConstraints += [loadingView.kd_setCenterY()]
            loadingView.startAnimating()
            boxButton.isHidden = true
            titleLabel.isHidden = true
            contentLabel.isHidden = true
            emptyTextView.isHidden = true
            subTitleLabel.isHidden = true
            prefixLabel.isHidden = true
        }
        
    }
    
}
