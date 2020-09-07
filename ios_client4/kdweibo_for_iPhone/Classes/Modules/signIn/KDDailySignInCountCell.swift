//
//  KDDailySignInCountCell.swift
//  kdweibo
//
//  Created by 张培增 on 2017/4/11.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import UIKit

final class KDDailySignInCountCell: UITableViewCell {

    lazy var titleLabel: UILabel = {
        $0.text = ASLocalizedString("一天签到次数")
        $0.font = FS3
        $0.textColor = FC1
        return $0
    }(UILabel())
    
    lazy var tipsBtn: UIButton = {
        $0.addTarget(self, action: #selector(tipsBtnDidPressed(_:)), for: .touchUpInside)
        $0.setBackgroundImage(UIImage(named: "signIn_question"), for: UIControlState())
        return $0
    }(UIButton())
    
    lazy var doubleSignSelectStateView: KDSelectStateView = {
        $0.didTapped = {
            self.dailySignInCount = 2
        }
        return $0
    }(KDSelectStateView(frame: CGRect.zero))
    
    lazy var doubleSignLabel: UILabel = {
        $0.text = ASLocalizedString("2次")
        $0.font = FS3
        $0.textColor = FC2
        return $0
    }(UILabel())
    
    lazy var fourthSignSelectStateView: KDSelectStateView = {
        $0.didTapped = {
            self.dailySignInCount = 4
        }
        return $0
    }(KDSelectStateView(frame: CGRect.zero))
    
    lazy var fourthSignLabel: UILabel = {
        $0.text = ASLocalizedString("4次")
        $0.font = FS3
        $0.textColor = FC2
        return $0
    }(UILabel())
    
    lazy var helpDetailView: KDHelpDetailView = {
        $0.detailArray = [[ASLocalizedString("一天2次签到："), ASLocalizedString("上班签到及下班签到,报表显示2次签到记录")], [ASLocalizedString("一天4次签到："), ASLocalizedString("上午上班及下班签到,下午上班及下班签到"), ASLocalizedString("报表显示4次签到记录")]]
        $0.helpViewWidth = 232 + 24
        return $0
    }(KDHelpDetailView(frame: CGRect.zero))
    
    var dailySignInCount = 2 {
        didSet {
            if dailySignInCount == 4 {
                doubleSignSelectStateView.selected = false
                fourthSignSelectStateView.selected = true
            }
            else {
                doubleSignSelectStateView.selected = true
                fourthSignSelectStateView.selected = false
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubviews([titleLabel, tipsBtn, doubleSignSelectStateView, doubleSignLabel, fourthSignSelectStateView, fourthSignLabel])
        kd_setupVFL([
            "titleLabel" : titleLabel,
            "tipsBtn" : tipsBtn,
            "doubleSignSelectStateView" : doubleSignSelectStateView,
            "doubleSignLabel" : doubleSignLabel,
            "fourthSignSelectStateView" : fourthSignSelectStateView,
            "fourthSignLabel" : fourthSignLabel
            ], constraints: [
                "H:|-12-[titleLabel]-6-[tipsBtn(20)]",
                "H:[doubleSignSelectStateView(20)]-6-[doubleSignLabel]-12-[fourthSignSelectStateView(20)]-6-[fourthSignLabel]-12-|",
                "V:[tipsBtn(20)]",
                "V:[doubleSignSelectStateView(20)]",
                "V:[fourthSignSelectStateView(20)]"
            ])
        titleLabel.kd_setCenterY()
        tipsBtn.kd_setCenterY()
        doubleSignSelectStateView.kd_setCenterY()
        doubleSignLabel.kd_setCenterY()
        fourthSignSelectStateView.kd_setCenterY()
        fourthSignLabel.kd_setCenterY()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func tipsBtnDidPressed(_ sender: UIButton) {
        helpDetailView.showAtOrigin(CGPoint(x: 126, y: 250))
    }

}
