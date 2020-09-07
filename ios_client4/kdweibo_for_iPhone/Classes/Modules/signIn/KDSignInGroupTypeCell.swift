//
//  KDSignInGroupTypeCell.swift
//  kdweibo
//
//  Created by 张培增 on 2017/3/24.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import UIKit

enum KDSignInGroupType {
    case fixedShift             //固定班制
    case shift                  //排班制
}

final class KDSignInGroupTypeCell: KDTableViewCell {
    
    var type: KDSignInGroupType = .fixedShift {
        didSet {
            switch type {
            case .fixedShift:
                self.titleLabel.text = ASLocalizedString("固定班制")
                self.subTitleLabel.text = ASLocalizedString("适用于IT、金融、政府/事业单位等行业")
                self.descriptionLabel.text = ASLocalizedString("固定工作时间")
                self.icon.image = UIImage(named: "signIn_group_fixedShift")
            case .shift:
                self.titleLabel.text = ASLocalizedString("排班制")
                self.subTitleLabel.text = ASLocalizedString("适用于餐饮、制造、医院等行业")
                self.descriptionLabel.text = ASLocalizedString("两个或多个班次")
                self.icon.image = UIImage(named: "signIn_group_shift")
            }
        }
    }
    
    lazy var containerView: UIView = {
        $0.clipsToBounds = true
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 6
        $0.backgroundColor = FC6
        return $0
    }(UIView())
    
    lazy var icon: UIImageView = {
        return $0
    }(UIImageView())
    
    lazy var titleView: UIView = {
        $0.backgroundColor = UIColor.clear
        $0.isUserInteractionEnabled = false
        return $0
    }(UIView())
    
    lazy var titleLabel: UILabel = {
        $0.font = FS1
        $0.textColor = FC1
        return $0
    }(UILabel())
    
    lazy var descriptionLabel: UILabel = {
        $0.font = FS6
        $0.textColor = FC2
        return $0
    }(UILabel())
    
    lazy var subTitleLabel: UILabel = {
        $0.font = FS5
        $0.textColor = FC2
        $0.numberOfLines = 0
        return $0
    }(UILabel())

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.kdBackgroundColor1()
        contentView.backgroundColor = UIColor.kdBackgroundColor1()
        
        titleView.addSubviews([titleLabel, subTitleLabel, descriptionLabel])
        kd_setupVFL([
            "titleLabel" : titleLabel,
            "subTitleLabel" : subTitleLabel,
            "descriptionLabel" : descriptionLabel
            ], constraints: [
                "H:|[titleLabel]-6-[descriptionLabel]",
                "H:|[subTitleLabel]|",
                "V:|[titleLabel]-6-[subTitleLabel]|",
                "V:[descriptionLabel]-6-[subTitleLabel]"
            ])
        
        containerView.addSubviews([icon, titleView])
        kd_setupVFL([
            "icon" : icon,
            "titleView" : titleView
            ], constraints: [
                "H:|-14-[icon(72)]-16-[titleView]-14-|",
                "V:[icon(60)]"
            ])
        icon.kd_setCenterY()
        titleView.kd_setCenterY()
        
        contentView.addSubviews([containerView])
        kd_setupVFL([
            "containerView" : containerView,
            ], constraints: [
                "H:|-12-[containerView]-12-|",
                "V:|[containerView]|"
            ])
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        selectedBackgroundView?.frame = CGRect(x: 12, y: 0, width: UIScreen.main.bounds.width - 24, height: contentView.bounds.size.height)
        selectedBackgroundView?.layer.cornerRadius = 6
        selectedBackgroundView?.layer.masksToBounds = true
        
    }
    
}
