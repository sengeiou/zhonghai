//
//  KDMarkListEmptyCell.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/20.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

final class KDMarkListEmptyCell: UITableViewCell {
    
    lazy var label0: UILabel = {
        let label = UILabel()
        label.font = FS4
        label.textColor = FC2
        label.text = ASLocalizedString("Mark_Congratulations")
        return label
    }()
    
    lazy var imageView0: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"app_img_noapp")
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.backgroundColor = UIColor.kdBackgroundColor1()
        contentView.addSubview(imageView0)
        imageView0.mas_makeConstraints { make in
            make?.top.equalTo()(self.imageView0.superview!.top)?.with().offset()(140)
            make?.centerX.equalTo()(self.imageView0.superview!.centerX)
            return()
        }
        
        contentView.addSubview(label0)
        label0.mas_makeConstraints { make in
            make?.top.equalTo()(self.imageView0.bottom)?.with().offset()(23)
            make?.centerX.equalTo()(self.label0.superview!.centerX)
            return()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
