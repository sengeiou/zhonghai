//
//  KDChatCombineTextCell.swift
//  kdweibo
//
//  Created by Darren Zheng on 7/25/16.
//  Copyright © 2016 www.kingdee.com. All rights reserved.
//

class KDChatCombineTextCell: KDChatCombineBaseCell {

    lazy var contentTextView: KDRichTextView = {
        let textView = KDRichTextView()
        return textView
    }()
        
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(contentTextView)
        contentTextView.mas_makeConstraints { make in
            make?.left.equalTo()(self.headView.right)?.with().offset()(12)
            make?.right.equalTo()(self.contentTextView.superview!.right)?.with().offset()(-12)
            make?.top.equalTo()(self.timeLabel.bottom)?.with().offset()(12)
            make?.bottom.equalTo()(self.contentTextView.superview!.bottom)?.with().offset()(-12)
            return()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
