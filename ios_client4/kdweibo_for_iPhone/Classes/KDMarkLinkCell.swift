//
//  KDMarkLinkCell.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/11.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

final class KDMarkLinkCell: KDMarkListBaseCell {
    
    lazy var contentHeadImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"mark_tip_link")
        return imageView
    }()
    
    lazy var contentTitleLabel: UILabel = {
        let label = UILabel()
        label.font = FS3
        label.textColor = FC1
        label.numberOfLines = 1
        return label
    }()
    
    lazy var contentSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = FS5
        label.textColor = FC2
        label.numberOfLines = 1
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(contentHeadImageView)
        contentHeadImageView.mas_makeConstraints { make in
            make?.top.equalTo()(self.headImageView.bottom)?.with().offset()(12)
            make?.height.mas_equalTo()(60)
            make?.width.mas_equalTo()(60)
            make?.left.equalTo()(self.headImageView.right)?.with().offset()(12)
            return()
        }
        contentView.addSubview(contentTitleLabel)
        contentTitleLabel.mas_makeConstraints { make in
            make?.left.equalTo()(self.contentHeadImageView.right)?.with().offset()(12)
            make?.right.equalTo()(self.contentTitleLabel.superview!.right)?.with().offset()(-12)
            make?.top.equalTo()(self.contentHeadImageView.top)?.with().offset()(8)
            return()
        }
        contentView.addSubview(contentSubtitleLabel)
        contentSubtitleLabel.mas_makeConstraints { make in
            make?.left.equalTo()(self.contentHeadImageView.right)?.with().offset()(12)
            make?.top.equalTo()(self.contentTitleLabel.bottom)?.with().offset()(5)
            make?.right.equalTo()(self.contentSubtitleLabel.superview!.right)?.with().offset()(-12)
            return()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
