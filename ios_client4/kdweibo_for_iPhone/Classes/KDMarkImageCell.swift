//
//  KDMarkImageCell.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/11.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//


final class KDMarkImageCell: KDMarkListBaseCell {
    
    lazy var contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
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
            make?.top.equalTo()(self.headImageView.bottom)?.with().offset()(12)
            return()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
