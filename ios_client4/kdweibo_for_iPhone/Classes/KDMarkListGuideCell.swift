//
//  KDMarkListGuideCell.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/13.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

final class KDMarkListGuideCell: UITableViewCell {

    lazy var label0: UILabel = {
        let label = UILabel()
        label.font = FS6
        label.textColor = FC1
        label.numberOfLines = 0;
        label.text = ASLocalizedString("Mark_longPress")
        return label
    }()
    
    lazy var label1: UILabel = {
        let label = UILabel()
        label.font = FS6
        label.textColor = FC1
        label.numberOfLines = 0;
        label.text = ASLocalizedString("Mark_touchMark")
        return label
    }()
    
    lazy var imageView0: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"mark_tip_guide")
        return imageView
    }()
    
    lazy var imageView1: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"mark_tip_guide1")
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(label0)
        label0.mas_makeConstraints { make in
            make?.top.equalTo()(self.label0.superview!.top)?.with().offset()(25)
            make?.left.equalTo()(self.label0.superview!.left)?.with().offset()(20)
            make?.right.equalTo()(self.label0.superview!.right)?.with().offset()(-20)
            return()
        }
        
//        contentView.addSubview(imageView0)
//        imageView0.mas_makeConstraints { make in
//            make.top.equalTo()(self.label0.bottom).with().offset()(15)
//            make.left.equalTo()(self.imageView0.superview!.left).with().offset()(25)
//            make.right.equalTo()(self.imageView0.superview!.right).with().offset()(-25)
//            if let image = self.imageView0.image {
//                make.height.mas_equalTo()((KDFrame.screenWidth() - 25 * 2) * image.heightDivideWidthRatio)
//            }
//            return()
//        }

        contentView.addSubview(label1)
        label1.mas_makeConstraints { make in
            make?.top.equalTo()(self.label0.bottom)?.with().offset()(25)
            make?.left.equalTo()(self.label1.superview!.left)?.with().offset()(20)
            make?.right.equalTo()(self.label1.superview!.right)?.with().offset()(-20)
            return()
        }

//        contentView.addSubview(imageView1)
//        imageView1.mas_makeConstraints { make in
//            make.top.equalTo()(self.label1.bottom).with().offset()(15)
//            make.left.equalTo()(self.imageView1.superview!.left).with().offset()(25)
//            make.right.equalTo()(self.imageView1.superview!.right).with().offset()(-25)
//            if let image = self.imageView1.image {
//                make.height.mas_equalTo()((KDFrame.screenWidth() - 25 * 2) * image.heightDivideWidthRatio)
//            }
//            return()
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
