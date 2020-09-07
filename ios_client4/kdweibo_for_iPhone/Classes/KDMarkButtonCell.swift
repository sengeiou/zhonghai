//
//  KDMarkButtonCell.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/12.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//


final class KDMarkButtonCell: UITableViewCell {
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = FC5
        label.font = FS3
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(label)
        label.mas_makeConstraints { make in
            make?.edges.equalTo()(self.label.superview!)?.with().insets()(UIEdgeInsets.zero)
            return()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
