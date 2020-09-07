//
//  KDMarkBaseCell.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/10.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

class KDMarkBaseCell: SWTableViewCell {
    
    lazy var headImageView: KDRoundImageView = {
        let headImageView = KDRoundImageView()
        headImageView.image = XTImageUtil.headerDefaultImage()
        return headImageView
    }()
    
    lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = FS3
        nameLabel.textColor = FC1
        return nameLabel
    }()
    
    lazy var timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.font = FS6
        timeLabel.textColor = FC2
        return timeLabel
    }()
    
    var alarmClockOn: Bool = false {
        didSet {
            alarmClockButton.setImage(alarmClockOn ? UIImage(named:"mark_tip_remind") : nil, for: UIControlState())
        }
    }
    
    lazy var separatorLine: UIView = {
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor.kdBackgroundColor1()
        return separatorLine
    }()
    
    lazy var alarmClockButton: UIButton = {
        let alarmClockButton = UIButton()
        return alarmClockButton
    }()
    var separatorLineTop: MASConstraint?
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.kdBackgroundColor1()
        contentView.addSubview(headImageView)
        headImageView.mas_makeConstraints { make in
            make?.top.equalTo()(self.headImageView.superview!.top)?.with().offset()(12)
            make?.left.equalTo()(self.headImageView.superview!.left)?.with().offset()(12)
            make?.height.mas_equalTo()(44)
            make?.width.mas_equalTo()(44)
            return()
        }
        
        contentView.addSubview(alarmClockButton)
        alarmClockButton.mas_makeConstraints { make in
            make?.right.equalTo()(self.alarmClockButton.superview!.right)?.with().offset()(-0)
            make?.top.equalTo()(self.alarmClockButton.superview!.top)?.with().offset()(0)
            make?.height.mas_equalTo()(29)
            make?.width.mas_equalTo()(29)
            return()
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.mas_makeConstraints { make in
            make?.left.equalTo()(self.headImageView.right)?.with().offset()(12)
            make?.top.equalTo()(self.nameLabel.superview!.top)?.with().offset()(15)
            make?.right.equalTo()(self.alarmClockButton.left)?.with().offset()(-10)
            return()
        }
        
        contentView.addSubview(timeLabel)
        timeLabel.mas_makeConstraints { make in
            make?.top.equalTo()(self.nameLabel.bottom)?.with().offset()(2)
            make?.left.equalTo()(self.headImageView.right)?.with().offset()(12)
            make?.right.equalTo()(self.alarmClockButton.left)?.with().offset()(-10)
            return()
        }
        
        contentView.addSubview(separatorLine)
        separatorLine.mas_makeConstraints { make in
            make?.bottom.equalTo()(self.separatorLine.superview!.bottom)?.with().offset()(-0)
            make?.height.mas_equalTo()(8)
            make?.left.equalTo()(self.separatorLine.superview!.left)?.with().offset()(0)
            make?.right.equalTo()(self.separatorLine.superview!.right)?.with().offset()(-0)
//            self.separatorLineTop = make.top.equalTo()(self.timeLabel.bottom).with().offset()(12)
            return()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            separatorLine.backgroundColor = UIColor.kdBackgroundColor1()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            separatorLine.backgroundColor = UIColor.kdBackgroundColor1()
        }
    }
}
