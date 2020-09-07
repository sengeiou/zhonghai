//
//  KDChatCombineBaseCell.swift
//  kdweibo
//
//  Created by Darren Zheng on 7/25/16.
//  Copyright © 2016 www.kingdee.com. All rights reserved.
//

class KDChatCombineBaseCell: UITableViewCell {
    
    lazy var headView: KDRoundImageView = {
        let headView = KDRoundImageView()
        headView.image = XTImageUtil.headerDefaultImage()
        return headView
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = FS3
        titleLabel.textColor = FC1
        return titleLabel
    }()
    
    lazy var timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.font = FS6
        timeLabel.textColor = FC2
        return timeLabel
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = UIColor.clear
        contentView.addSubview(headView)
        headView.mas_makeConstraints { make in
            make?.top.equalTo()(self.headView.superview!.top)?.with().offset()(12)
            make?.left.equalTo()(self.headView.superview!.left)?.with().offset()(12)
            make?.height.mas_equalTo()(44)
            make?.width.mas_equalTo()(44)
            return()
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.mas_makeConstraints { make in
            make?.left.equalTo()(self.headView.right)?.with().offset()(12)
            make?.top.equalTo()(self.titleLabel.superview!.top)?.with().offset()(15)
            make?.right.equalTo()(self.titleLabel.superview!.right)?.with().offset()(-12)
            return()
        }
        
        contentView.addSubview(timeLabel)
        timeLabel.mas_makeConstraints { make in
            make?.top.equalTo()(self.titleLabel.bottom)?.with().offset()(2)
            make?.left.equalTo()(self.headView.right)?.with().offset()(12)
            make?.right.equalTo()(self.timeLabel.superview!.right)?.with().offset()(-12)
            return()
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
  
}
