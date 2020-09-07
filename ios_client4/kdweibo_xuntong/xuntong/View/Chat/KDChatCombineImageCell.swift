//
//  KDChatCombineImageCell.swift
//  kdweibo
//
//  Created by Darren Zheng on 7/25/16.
//  Copyright © 2016 www.kingdee.com. All rights reserved.
//

class KDChatCombineImageCell: KDChatCombineBaseCell {
    
    lazy var contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = XTImageUtil.cellThumbnailImage(withType: 2)
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(contentImageView)
        contentImageView.mas_makeConstraints { make in
            make?.height.mas_equalTo()(140)
            make?.left.equalTo()(self.contentImageView.superview!.left)?.with().offset()(12 + 44 + 12)
            make?.right.equalTo()(self.contentImageView.superview!.right)?.with().offset()(-12 - 44 - 12)
            make?.top.equalTo()(self.headView.bottom)?.with().offset()(12)
            make?.bottom.equalTo()(self.contentImageView.superview!.bottom)?.with().offset()(-12)
            return()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
