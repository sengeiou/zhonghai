//
//  KDMarkDetailImageCell.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/12.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

final class KDMarkDetailImageCell: KDMarkBaseCell {
    
    var onTapContentImageView: (() -> Void)?
    
    lazy var contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.image = XTImageUtil.cellThumbnailImage(withType: 2)
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var groupNameLabel: UILabel = {
        let label = UILabel()
        label.font = FS6
        label.textColor = FC2
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(contentImageView)

        contentImageView.mas_makeConstraints { make in
            make?.left.equalTo()(self.contentImageView.superview!.left)?.with().offset()(12)
            make?.right.equalTo()(self.contentImageView.superview!.right)?.with().offset()(-12)
            make?.top.equalTo()(self.headImageView.bottom)?.with().offset()(24)
            return()
        }
        
        contentView.addSubview(groupNameLabel)
        groupNameLabel.mas_makeConstraints { make in
            make?.top.equalTo()(self.contentImageView.bottom)?.with().offset()(12)
            make?.left.equalTo()(self.contentImageView.left)?.with().offset()(0)
            make?.right.equalTo()(self.groupNameLabel.superview!.right)?.with().offset()(-12)
            make?.bottom.equalTo()(self.separatorLine.top)?.with().offset()(-12)?.priority()(MASLayoutPriorityDefaultLow)
            return()
        }


        separatorLine.updateConstraints { make in
            make?.height.mas_equalTo()(1)
        }
        contentImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(KDMarkDetailImageCell.tapContentImageView)))
    }
    
    func tapContentImageView() {
        onTapContentImageView?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
