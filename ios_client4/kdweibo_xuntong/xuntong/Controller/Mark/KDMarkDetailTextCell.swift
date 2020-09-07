//
//  KDMarkDetailTextCell.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/12.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

final class KDMarkDetailTextCell: KDMarkBaseCell {
    
    lazy var contentTextView: KDRichTextView = {
        let textView = KDRichTextView()
        return textView
    }()
 
    lazy var groupNameLabel: UILabel = {
        let label = UILabel()
        label.font = FS6
        label.textColor = FC2
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(contentTextView)
        contentTextView.mas_makeConstraints { make in
            make?.left.equalTo()(self.contentTextView.superview!.left)?.with().offset()(12)
            make?.right.equalTo()(self.contentTextView.superview!.right)?.with().offset()(-12)
            make?.top.equalTo()(self.timeLabel.bottom)?.with().offset()(24)
            return()
        }

        contentView.addSubview(groupNameLabel)
        groupNameLabel.mas_makeConstraints { make in
            make?.top.equalTo()(self.contentTextView.bottom)?.with().offset()(12)
            make?.left.equalTo()(self.contentTextView.left)?.with().offset()(0)
            make?.right.equalTo()(self.groupNameLabel.superview!.right)?.with().offset()(-12)
            make?.bottom.equalTo()(self.separatorLine.top)?.with().offset()(-12)?.priority()(MASLayoutPriorityDefaultLow)
            return()
        }
        
        separatorLine.updateConstraints { make in
            make?.height.mas_equalTo()(1)
        }
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
