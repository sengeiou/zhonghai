//
//  KDMarkBottomBanner.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/8/9.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//


@objc protocol KDMarkBottomBannerDelegate {
    func markBannerPressed()
}

class KDMarkBottomBanner: UIView {
    
    weak var delegate: KDMarkBottomBannerDelegate?
    
    lazy var leftLabel: UILabel = {
        let label = UILabel()
        label.font = FS4
        label.textColor = FC6
        label.text = ASLocalizedString("Marked")
        return label
    }()
    
    lazy var rightLabel: UILabel = {
        let label = UILabel()
        label.font = FS6
        label.textColor = UIColor(hexRGB: "0f89cc")
        label.text = ASLocalizedString("Mark_check")
        return label
    }()
    
    lazy var arrow: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "已标记提醒的角标")
        return imageView
    }()
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexRGB: "7ed1ff")
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear

        addSubview(backgroundView)
        backgroundView.mas_makeConstraints { make in
            make?.edges.equalTo()(self.backgroundView.superview!)?.with().insets()(UIEdgeInsets.zero)
            return()
        }

        addSubview(leftLabel)
        leftLabel.mas_makeConstraints { make in
            make?.left.equalTo()(self.leftLabel.superview!.left)?.with().offset()(12)
            make?.centerY.equalTo()(self.leftLabel.superview!.centerY)
            return()
        }
        
        addSubview(arrow)
        arrow.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.arrow.superview!.centerY)
            make?.right.equalTo()(self.arrow.superview!.right)?.with().offset()(-12)
            return()
        }
        
        addSubview(rightLabel)
        rightLabel.mas_makeConstraints { make in
            make?.right.equalTo()(self.arrow.left)?.with().offset()(-8)
            make?.centerY.equalTo()(self.rightLabel.superview!.centerY)
            return()
        }
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(KDMarkBottomBanner.onTap))
        backgroundView.addGestureRecognizer(tapGes)
        
    }
    
    func onTap() {
        delegate?.markBannerPressed()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
