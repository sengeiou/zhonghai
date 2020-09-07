//
//  KDNoticeListCell.swift
//  kdweibo
//
//  Created by Darren Zheng on 2017/2/13.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import Foundation

// MARK: - Input -

@objc protocol KDNoticeListCellDataSource {
    var noticeListCellTitle: String? { get }
    var noticeListCellSubtitle: String? { get }
    var noticeListCellContent: String? { get }
}

// MARK: - Output -

@objc protocol KDNoticeListCellDelegate {
    
}

class KDNoticeListCell: UITableViewCell {
    
    // MARK: - Properties -
    
    weak var delegate: KDNoticeListCellDelegate?
    weak var dataSource: KDNoticeListCellDataSource? {
        didSet {
            update()
        }
    }
    
    lazy var titleLabel: UILabel = {
        $0.font = FS2
        $0.textColor = FC1
        return $0
    }(UILabel())
    
    lazy var subTitleLabel: UILabel = {
        $0.font = FS7
        $0.textColor =  FC2
        return $0
    }(UILabel())
    
    lazy var contentLabel: UILabel = {
        $0.font = FS4
        $0.textColor =  FC2
        $0.numberOfLines = 3
        return $0
    }(UILabel())
    
    lazy var seperatorLine: UIView = {
        $0.backgroundColor = UIColor.kdDividingLine()
        return $0
    }(UIView())
    
    lazy var bottomSeperatorLine: UIView = {
        $0.backgroundColor = UIColor.kdDividingLine()
        return $0
    }(UIView())

    
    // MARK: - Setup -
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var bindings: [String: AnyObject] = {
        return [
            "titleLabel" : self.titleLabel,
            "subTitleLabel" : self.subTitleLabel,
            "contentLabel" : self.contentLabel,
            "seperatorLine": self.seperatorLine,
            "bottomSeperatorLine": self.bottomSeperatorLine,
            ]
    }()
    
    var metrics: [String: AnyObject] {
        return [
            :
        ]
    }
    
    let vfls: [String] = [
        "H:|-12-[titleLabel]-12-|",
        "H:|-12-[subTitleLabel]-12-|",
        "H:|-12-[contentLabel]-12-|",
        "H:|-12-[seperatorLine]-12-|",
        "H:|[bottomSeperatorLine]|",
        "V:[bottomSeperatorLine(8)]|",
        "V:|-12-[titleLabel]-3-[subTitleLabel]-12-[seperatorLine(1)]-15-[contentLabel]",
        ]
    
    func setup() {
        contentView.addSubviews([titleLabel, subTitleLabel, contentLabel, seperatorLine, bottomSeperatorLine])
        kd_setupVFL(bindings,
                    metrics: metrics,
                    constraints: vfls,
                    delayInvoke: false)
    }
    
    // MARK: - Update -
    
    func update() {
        
        guard let dataSource = dataSource
            else { return }
        
        titleLabel.text = dataSource.noticeListCellTitle
        subTitleLabel.text = dataSource.noticeListCellSubtitle
        contentLabel.text = dataSource.noticeListCellContent
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            bottomSeperatorLine.backgroundColor = UIColor.kdBackgroundColor1()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            bottomSeperatorLine.backgroundColor = UIColor.kdBackgroundColor1()
        }
    }
    
}

