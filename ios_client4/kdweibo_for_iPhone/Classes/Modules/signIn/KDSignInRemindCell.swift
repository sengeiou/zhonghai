//
//  KDSignInRemindCell.swift
//  kdweibo
//
//  Created by 张培增 on 2017/3/9.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import UIKit

final class KDSignInRemindCell: KDTableViewCell {

    lazy var kd_contentView: KDV8CellContentView = {
        return $0
    }(KDV8CellContentView())
    
    lazy var openSwitch: UISwitch = {
        $0.onTintColor = FC5
        $0.setOn(false, animated: false)
        $0.addTarget(self, action: #selector(openSwitchDidClicked(_:)), for: .valueChanged)
        return $0
    }(UISwitch())
    
    var remind: KDSignInRemind? {
        didSet {
            
            kd_contentView.kd_textLabel.text = remind?.remindTime
            kd_contentView.kd_detailTextLabel.text = KDSignInUtil.getRepeatRepresention(with: remind?.repeatType ?? .none)
            openSwitch.setOn(remind?.isRemind ?? false, animated: false)
            
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        kd_contentView.install(self.contentView, style: .ls4)
        
        contentView.addSubviews([openSwitch])
        kd_setupVFL([
            "openSwitch": openSwitch,
            ], constraints: [
                "H:[openSwitch]-12-|",
                ])
        openSwitch.kd_setCenterY()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func openSwitchDidClicked(_ sender: UISwitch) {
        if let block = switchValueChangedBlock {
            block(sender.isOn)
        }
    }
    
    var switchValueChangedBlock : ((_ isOn: Bool)->())? = nil

}
