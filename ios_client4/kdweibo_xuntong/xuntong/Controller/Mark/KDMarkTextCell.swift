//
//  KDMarkTextCell.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/11.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//


final class KDMarkTextCell: KDMarkListBaseCell {
    
    lazy var contentTextView: KDRichTextView = {
        let textView = KDRichTextView()
        textView.setNumberOflines(3)
        return textView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //        separatorLineTop?.uninstall()
        contentView.addSubview(contentTextView)
        contentTextView.mas_makeConstraints { make in
            make?.left.equalTo()(self.headImageView.right)?.with().offset()(12)
            make?.right.equalTo()(self.contentTextView.superview!.right)?.with().offset()(-12)
            make?.top.equalTo()(self.timeLabel.bottom)?.with().offset()(12)
            make?.bottom.equalTo()(self.slimSeparatorLine.top)?.with().offset()(-12)
            return()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
