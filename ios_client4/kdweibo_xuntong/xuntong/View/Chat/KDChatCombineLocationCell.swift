//
//  KDChatCombineLocationCell.swift
//  kdweibo
//
//  Created by fang.jiaxin on 16/11/10.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

import UIKit

class KDChatCombineLocationCell: KDChatCombineBaseCell {
    
    lazy var contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = XTImageUtil.cellThumbnailImage(withType: 2)
        return imageView
    }()
    
    lazy var detailBgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage.init(named: "locationBg")
        return imageView
    }()
    
    lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.font = FS7
        label.textColor = FC6
        label.textAlignment = .left
        return label
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
        
        contentImageView.addSubview(detailBgImageView)
        detailBgImageView.mas_makeConstraints { make in
            make?.height.mas_equalTo()(30)
            make?.left.equalTo()(self.detailBgImageView.superview!.left)?.with().offset()(0)
            make?.right.equalTo()(self.detailBgImageView.superview!.right)?.with().offset()(0)
            make?.bottom.equalTo()(self.detailBgImageView.superview!.bottom)?.with().offset()(0)
            return()
        }
        
        contentImageView.addSubview(detailLabel)
        detailLabel.mas_makeConstraints { make in
            make?.height.mas_equalTo()(24)
            make?.left.equalTo()(self.detailLabel.superview!.left)?.with().offset()(3)
            make?.right.equalTo()(self.detailLabel.superview!.right)?.with().offset()(-3)
            make?.centerY.equalTo()(self.detailBgImageView.centerY)
            return()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
