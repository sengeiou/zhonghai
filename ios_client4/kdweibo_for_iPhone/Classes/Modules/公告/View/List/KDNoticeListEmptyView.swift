//
//  KDNoticeListEmptyView.swift
//  kdweibo
//
//  Created by Darren Zheng on 2017/2/15.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//


@objc protocol KDNoticeEmptyViewDataSource {
    var isAdmin: Bool { get }
}

@objc protocol KDNoticeEmptyViewDelegate {
    func noticeEmptyViewCreateButtonPressed(_ noticeEmptyView: KDNoticeEmptyView)
}

class KDNoticeEmptyView: UIView {
    
    weak var delegate: KDNoticeEmptyViewDelegate?
    weak var dataSource: KDNoticeEmptyViewDataSource? {
        didSet {
            update()
        }
    }

    lazy var emptyView: UIImageView = {
        $0.image = UIImage(named: "icon_group_no_notice")
        return $0
    }(UIImageView())
    
    lazy var emptyTextView: KDRichTextView = {
        $0.backgroundColor = UIColor.clear
        $0.linkTextAttributes = NSMutableAttributedString.dz_linkAttribute(withLinkColor: FC5) as! [String: AnyObject]
        $0.onKeywordTap = { linkPrefix, keyword in
            if keyword == ASLocalizedString("Notice_Quick_Create") {
                KDEventAnalysis.event(event_group_manage_announcement_quick)
                KDEventAnalysis.eventCountly(event_group_manage_announcement_quick)
                self.delegate?.noticeEmptyViewCreateButtonPressed(self)
            }
        }
        return $0
    }(KDRichTextView())
    
    
    lazy var bindings: [String: AnyObject] = {
        return [
            "emptyView" : self.emptyView,
            "emptyTextView": self.emptyTextView,
            ]
    }()
    
    var metrics: [String: AnyObject] {
        return [
            :
        ]
    }
    
    
    let emptyVfls: [String] = [
        "V:|[emptyView]-25-[emptyTextView]",
        ]
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews([emptyView, emptyTextView])
        kd_setupVFL(bindings,
                    metrics: metrics,
                    constraints: emptyVfls,
                    delayInvoke: false)
        
        emptyView.kd_setCenterX()
        emptyTextView.kd_setCenterX()

    }
    
    func update() {
        guard let dataSource = dataSource
            else { return }
        
        if dataSource.isAdmin {
            let mStr = NSMutableAttributedString(string: ASLocalizedString("Notice_No_And_Create"))
            mStr.dz_setFont(FS4)
            mStr.dz_setTextColor(FC2, range: NSMakeRange(2, 6))
            mStr.dz_setTextColor(FC5, range: NSMakeRange(8, 4))
            mStr.dz_setLink(with: NSMakeRange(8, 4), url: URL(fileURLWithPath: ASLocalizedString("Notice_Quick_Create")))
            emptyTextView.attributedText =  mStr  // [图片]暂无群公告，快速创建
        } else {
            let mStr = NSMutableAttributedString(string: ASLocalizedString("Notice_No"))
            mStr.dz_setFont(FS4)
            mStr.dz_setTextColor(FC2, range: NSMakeRange(2, 5))
            emptyTextView.attributedText =  mStr
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
