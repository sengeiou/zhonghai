//
//  KDSignInFlexibleAttendanceCell.swift
//  kdweibo
//
//  Created by 张培增 on 2016/12/12.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

import UIKit

class KDSignInFlexibleAttendanceCell: KDTableViewCell {

    lazy var lateTimeBtn : UIButton = {
        let button = UIButton()
        button.setTitleColor(FC5, for: UIControlState())
        button.titleLabel?.font = FS3
        button.layer.cornerRadius = 14
        button.backgroundColor = UIColor.kdBackgroundColor1()
        button.setTitle(ASLocalizedString("30分钟"), for: UIControlState())
        button.addTarget(self, action: #selector(buttonDidpressed(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var workingHoursBtn : UIButton = {
        let button = UIButton()
        button.setTitleColor(FC5, for: UIControlState())
        button.titleLabel?.font = FS3
        button.layer.cornerRadius = 14
        button.backgroundColor = UIColor.kdBackgroundColor1()
        button.setTitle(ASLocalizedString("8小时"), for: UIControlState())
        button.addTarget(self, action: #selector(buttonDidpressed(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var leftLabel : UILabel = {
        let label = UILabel()
        label.font = FS5
        label.textColor = FC1
        label.text = ASLocalizedString("可以晚")
        return label
    }()
    
    lazy var midLabel : UILabel = {
        let label = UILabel()
        label.font = FS5
        label.textColor = FC1
        label.text = ASLocalizedString("上班,但必须满")
        return label
    }()
    
    lazy var rightLabel : UILabel = {
        let label = UILabel()
        label.font = FS5
        label.textColor = FC1
        label.text = ASLocalizedString("工时")
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(leftLabel)
        leftLabel.mas_makeConstraints { make in
            make?.left.mas_equalTo()(self.contentView)?.with().offset()(NSNumber.kdDistance1())
            make?.top.and().bottom().mas_equalTo()(self.contentView)
        }
        
        contentView.addSubview(lateTimeBtn)
        lateTimeBtn.mas_makeConstraints { make in
            make?.left.mas_equalTo()(self.leftLabel.right)?.with().offset()(2)
            make?.top.mas_equalTo()(self.contentView)?.with().offset()(8)
            make?.width.mas_equalTo()(60)
            make?.height.mas_equalTo()(28)
        }
        
        contentView.addSubview(midLabel)
        midLabel.mas_makeConstraints { make in
            make?.left.mas_equalTo()(self.lateTimeBtn.right)?.with().offset()(2)
            make?.top.and().bottom().mas_equalTo()(self.contentView)
        }
        
        contentView.addSubview(workingHoursBtn)
        workingHoursBtn.mas_makeConstraints { make in
            make?.left.mas_equalTo()(self.midLabel.right)?.with().offset()(2)
            make?.top.mas_equalTo()(self.contentView)?.with().offset()(8)
            make?.width.mas_equalTo()(60)
            make?.height.mas_equalTo()(28)
        }
        
        contentView.addSubview(rightLabel)
        rightLabel.mas_makeConstraints { make in
            make?.left.mas_equalTo()(self.workingHoursBtn.right)?.with().offset()(2)
            make?.top.and().bottom().mas_equalTo()(self.contentView)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func buttonDidpressed(_ sender: UIButton) {
        guard let block = buttonBlock else {
            return
        }
        
        if sender == lateTimeBtn {
            block(0)
        }
        else if sender == workingHoursBtn {
            block(1)
        }
    }
    
    var buttonBlock : ((_ index: NSInteger) -> ())? = nil

}
