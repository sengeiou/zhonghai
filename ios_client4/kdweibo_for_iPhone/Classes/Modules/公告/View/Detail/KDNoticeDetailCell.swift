//
//  KDNoticeDetailCell.swift
//  kdweibo
//
//  Created by Darren Zheng on 2017/2/15.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

class KDNoticeDetailCell: UITableViewCell {
    
    // MARK: - Properties -
    
    weak var dataSource: KDNoticeDetailVCDataSource? {
        didSet {
            update()
        }
    }
    
    lazy var titleLabel: UILabel = {
        $0.font = FS2
        $0.textColor = FC1
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    lazy var subTitleLabel: UILabel = {
        $0.font = FS7
        $0.textColor =  FC2
        return $0
    }(UILabel())
    
    lazy var contentLabel: UILabel = {
        $0.font = FS4
        $0.textColor =  FC1
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    lazy var seperatorLine: UIView = {
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
        "V:|-12-[titleLabel]-3-[subTitleLabel]-12-[seperatorLine(1)]-12-[contentLabel]",
        ]
    
    func setup() {
        contentView.addSubviews([titleLabel, subTitleLabel, contentLabel, seperatorLine])
        kd_setupVFL(bindings,
                    metrics: metrics,
                    constraints: vfls,
                    delayInvoke: false)
    }
    
    // MARK: - Update -
    
    func update() {
        
        guard let dataSource = dataSource
            else { return }
        
        titleLabel.text = dataSource.noticeDetailVCTitle
        subTitleLabel.text = dataSource.noticeDetailVCSubtitle
        contentLabel.text = dataSource.noticeDetailVCContent
    }
    

    
}

