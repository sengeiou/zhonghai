//
//  KDSignInAdvancedSettingCell.swift
//  kdweibo
//
//  Created by 张培增 on 2016/12/12.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

import UIKit

final class KDSignInAdvancedSettingCell: KDTableViewCell {

    lazy var kd_contentView : KDV8CellContentView = {
        let view = KDV8CellContentView()
        return view
    }()
    
    lazy var leftLabel : UILabel = {
        let label = UILabel()
        label.font = FS4
        label.textColor = FC1
        label.textAlignment = .right
        return label
    }()
    
    lazy var rightLabel : UILabel = {
        let label = UILabel()
        label.font = FS4
        label.textColor = FC1
        label.textAlignment = .right
        return label
    }()
    
    lazy var timeBtn : UIButton = {
        let button = UIButton()
        button.setTitleColor(FC5, for: UIControlState())
        button.titleLabel?.font = FS4
        button.addTarget(self, action: #selector(timeBtnDidPressed(_:)), for: .touchUpInside)
        return button
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        kd_contentView.install(self.contentView, style: .ls7)
        
        contentView.addSubview(rightLabel)
        rightLabel.mas_makeConstraints { make in
            make?.right.mas_equalTo()(self.contentView)?.with().offset()(-NSNumber.kdDistance1())
            make?.top.and().bottom().mas_equalTo()(self.contentView)
        }
        
        contentView.addSubview(timeBtn)
        timeBtn.mas_makeConstraints { make in
            make?.right.mas_equalTo()(self.rightLabel.left)?.with().offset()(-6)
            make?.top.mas_equalTo()(self.contentView)?.with().offset()(7)
            make?.height.mas_equalTo()(30)
        }
        
        contentView.addSubview(leftLabel)
        leftLabel.mas_makeConstraints { make in
            make?.right.mas_equalTo()(self.timeBtn.left)?.with().offset()(-6)
            make?.top.and().bottom().mas_equalTo()(self.contentView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func changeAlpha(_ isNormal: Bool) {
        if isNormal == true {
            self.kd_contentView.kd_textLabel.textColor = FC1
            self.alpha = 0
            self.leftLabel.textColor = FC1
            self.rightLabel.textColor = FC1
            self.timeBtn.setTitleColor(FC5, for: UIControlState())
        }
        else {
            self.kd_contentView.kd_textLabel.textColor = FC2
            self.alpha = 0.5
            self.leftLabel.textColor = FC2
            self.rightLabel.textColor = FC2
            self.timeBtn.setTitleColor(FC2, for: UIControlState())
        }
    }
    
    func timeBtnDidPressed(_ sender: UIButton) {
        if let block = btnBlock {
            block()
        }
    }
    
    var btnBlock : (()->())? = nil
    
}
