//
//  KDv8Cell.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/9/5.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

@objc enum KDListStyle: Int {
    
    // 只有分隔线
    case empty
    
    // 头像，标题，副标题，右侧时间
    case ls1
    
    // 头像，标题，副标题
    case ls2
    
    // 头像，标题
    case ls3
    
    // 上标题，下副标题
    case ls4
    
    // 小头像，标题
    case ls5
    
    // 左副标题，右标题
    case ls6
    
    // 左标题，右副标题
    case ls7
    
    // 小标题/分类
    case ls8
}

class KDV8CellContentView: NSObject {
    
    var kd_separatorLineLeft: NSLayoutConstraint?
    var currentConstraints = [NSLayoutConstraint]()
    var inView: UIView?
    
    func install(_ inView: UIView, style: KDListStyle) {
        self.inView = inView
        
        kd_imageView.layer.cornerRadius = kd_imageView.frame.width / 2

        switch style {
        case .empty:
            inView.addSubview(kd_separatorLine)
            currentConstraints += kd_setupVFL([
                "kd_separatorLine": self.kd_separatorLine,
                ], constraints: [
                    "H:|-12-[kd_separatorLine]|",
                    "V:[kd_separatorLine(0.5)]|"
                ])
            kd_separatorLineLeft = currentConstraints.first
        case .ls1:
            kd_textLabel.font = FS2
            kd_detailTextLabel.font = FS6
            kd_timeLabel.font = FS7
            labelBgView.addSubviews([kd_textLabel, kd_detailTextLabel, kd_timeLabel])
            currentConstraints += kd_setupVFL([
                "kd_textLabel": self.kd_textLabel,
                "kd_detailTextLabel": self.kd_detailTextLabel,
                "kd_timeLabel": self.kd_timeLabel,
                ], constraints: [
                    "H:|[kd_textLabel]-(>=0)-[kd_timeLabel]|",
                    "H:|[kd_detailTextLabel]-32-|",
                    "V:|-2-[kd_textLabel]-3-[kd_detailTextLabel(20)]|",
                    "V:|-2-[kd_timeLabel]",
                    ])
            kd_timeLabel.setContentCompressionResistancePriority(1000, for: UILayoutConstraintAxis.horizontal)
            inView.addSubviews([kd_imageView, labelBgView, kd_separatorLine])
            currentConstraints += kd_setupVFL([
                "kd_imageView": self.kd_imageView,
                "labelBgView": self.labelBgView,
                "kd_separatorLine": self.kd_separatorLine,
                ], constraints: [
                    "H:|-12-[kd_imageView(50)]-12-[labelBgView]-12-|",
                    "H:[kd_imageView]-12-[kd_separatorLine]|",
                    "V:[kd_imageView(50)]",
                    "V:[kd_separatorLine(0.5)]|"
                ])
            currentConstraints += [kd_imageView.kd_setCenterY()]
            currentConstraints += [labelBgView.kd_setCenterY()]
            
            unreadImageView = XTUnreadImageView(parentView: inView)
            unreadImageView?.isHidden = true

//            kd_imageView.personStatusLabel.font = FS7;
//            kd_imageView.personStatusLabel.remakeConstraints { make in
//                make.bottom.equalTo()(self.kd_imageView.bottom).with().offset()(0)
//                make.centerX.equalTo()(self.kd_imageView.centerX)
//                make.height.mas_equalTo()(20)
//                make.width.mas_equalTo()(self.kd_imageView.width)
//                return()
//            }
        case .ls2:
            kd_textLabel.font = FS3
            kd_detailTextLabel.font = FS6
            labelBgView.addSubviews([kd_textLabel, kd_detailTextLabel])
            currentConstraints += kd_setupVFL([
                "kd_textLabel": self.kd_textLabel,
                "kd_detailTextLabel": self.kd_detailTextLabel,
                ], constraints: [
                    "H:|[kd_textLabel]-(>=12)-|",
                    "H:|[kd_detailTextLabel]-(>=12)-|",
                    "V:|[kd_textLabel]-3-[kd_detailTextLabel]|",
                    ])
            
            inView.addSubviews([kd_imageView, labelBgView, kd_separatorLine])
            kd_imageView.layer.cornerRadius = 40.0/2
//            kd_imageView.personStatusLabel.font = FS10;
//            kd_imageView.personStatusLabel.remakeConstraints { make in
//                make.bottom.equalTo()(self.kd_imageView.bottom).with().offset()(0)
//                make.centerX.equalTo()(self.kd_imageView.centerX)
//                make.height.mas_equalTo()(14)
//                make.width.mas_equalTo()(self.kd_imageView.width)
//                return()
//            }

            currentConstraints += kd_setupVFL([
                "kd_imageView": self.kd_imageView,
                "labelBgView": self.labelBgView,
                "kd_separatorLine": self.kd_separatorLine,
                ], constraints: [
                    "H:|-12-[kd_imageView(40)]-12-[labelBgView]-12-|",
                    "H:[kd_imageView]-12-[kd_separatorLine]|",
                    "V:[kd_imageView(40)]",
                    "V:[kd_separatorLine(0.5)]|"
                ])
            currentConstraints += [kd_imageView.kd_setCenterY()]
            currentConstraints += [labelBgView.kd_setCenterY()]
        case .ls3:
            kd_textLabel.font = FS3
            inView.addSubviews([kd_imageView, kd_textLabel, kd_separatorLine])
            currentConstraints += kd_setupVFL([
                "kd_imageView": self.kd_imageView,
                "kd_textLabel": self.kd_textLabel,
                "kd_separatorLine": self.kd_separatorLine,
                ], constraints: [
                    "H:|-12-[kd_imageView(40)]-12-[kd_textLabel]-12-|",
                    "H:[kd_imageView]-12-[kd_separatorLine]|",
                    "V:[kd_imageView(40)]",
                    "V:[kd_separatorLine(0.5)]|"
                ])
            currentConstraints += [kd_imageView.kd_setCenterY()]
            currentConstraints += [kd_textLabel.kd_setCenterY()]
        case .ls4:
            kd_textLabel.font = FS3
            kd_detailTextLabel.font = FS6
            labelBgView.addSubviews([kd_textLabel, kd_detailTextLabel])
            currentConstraints += kd_setupVFL([
                "kd_textLabel": self.kd_textLabel,
                "kd_detailTextLabel": self.kd_detailTextLabel,
                ], constraints: [
                    "H:|[kd_textLabel]-(>=12)-|",
                    "H:|[kd_detailTextLabel]-(>=12)-|",
                    "V:|[kd_textLabel]-3-[kd_detailTextLabel]|",
                    ])
            inView.addSubviews([labelBgView, kd_separatorLine])
            currentConstraints += kd_setupVFL([
                "labelBgView": self.labelBgView,
                "kd_separatorLine": self.kd_separatorLine,
                ], constraints: [
                    "H:|-12-[labelBgView]-12-|",
                    "H:|-12-[kd_separatorLine]|",
                    "V:[kd_separatorLine(0.5)]|"
                ])
            currentConstraints += [labelBgView.kd_setCenterY()]
        case .ls5:
            kd_imageView.layer.cornerRadius = 0
            kd_textLabel.font = FS3
            inView.addSubviews([kd_imageView, kd_textLabel, kd_separatorLine])
            currentConstraints += kd_setupVFL([
                "kd_imageView": self.kd_imageView,
                "kd_textLabel": kd_textLabel,
                "kd_separatorLine": self.kd_separatorLine,
                ], constraints: [
                    "H:|-12-[kd_imageView(20)]-12-[kd_textLabel]-12-|",
                    "H:[kd_imageView]-12-[kd_separatorLine]|",
                    "V:[kd_imageView(20)]",
                    "V:[kd_separatorLine(0.5)]|"
                ])
            currentConstraints += [kd_imageView.kd_setCenterY()]
            currentConstraints += [kd_textLabel.kd_setCenterY()]
        case .ls6:
            kd_textLabel.font = FS3
            kd_detailTextLabel.font = FS3
            inView.addSubviews([kd_textLabel, kd_detailTextLabel, kd_separatorLine])
            currentConstraints += kd_setupVFL([
                "kd_detailTextLabel": self.kd_detailTextLabel,
                "kd_separatorLine": self.kd_separatorLine,
                "kd_textLabel": self.kd_textLabel,
                ], constraints: [
                    "H:|-12-[kd_detailTextLabel(<=100)]",
                    "H:|-12-[kd_separatorLine]|",
                    "V:[kd_separatorLine(0.5)]|"
                ])
            currentConstraints += [kd_textLabel.kd_setCenterY()]
            currentConstraints += [kd_textLabel.kd_setCenterX()]
            currentConstraints += [kd_detailTextLabel.kd_setCenterY()]
        case .ls7:
            kd_textLabel.font = FS3
            kd_detailTextLabel.font = FS3
            inView.addSubviews([kd_textLabel, kd_detailTextLabel, kd_separatorLine])
            currentConstraints += kd_setupVFL([
                "kd_textLabel": self.kd_textLabel,
                "kd_detailTextLabel": self.kd_detailTextLabel,
                "kd_separatorLine": self.kd_separatorLine,
                ], constraints: [
                    "H:|-12-[kd_textLabel]-(>=12)-[kd_detailTextLabel]-12-|",
                    "H:|-12-[kd_separatorLine]|",
                    "V:[kd_separatorLine(0.5)]|"
                ])
            kd_detailTextLabel.setContentCompressionResistancePriority(1000, for: UILayoutConstraintAxis.horizontal)
            currentConstraints += [kd_textLabel.kd_setCenterY()]
            currentConstraints += [kd_detailTextLabel.kd_setCenterY()]
            
        case .ls8:
            kd_textLabel.font = FS7
            kd_textLabel.textColor = FC2
            inView.addSubviews([kd_textLabel, kd_separatorLine])
            currentConstraints += kd_setupVFL([
                "kd_textLabel": self.kd_textLabel,
                "kd_separatorLine": self.kd_separatorLine,
                ], constraints: [
                    "H:|-12-[kd_textLabel]-12-|",
                    "H:|-12-[kd_separatorLine]|",
                    "V:[kd_separatorLine(0.5)]|"
                ])
            
            
            currentConstraints += [kd_textLabel.kd_setCenterY()]
        }
        
    }
    
    func uninstall() {
        inView?.removeConstraints(currentConstraints)
    }
    
    lazy var kd_imageView: XTPersonHeaderImageView = {
        let kd_imageView = XTPersonHeaderImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        kd_imageView.contentMode = .scaleAspectFit
        kd_imageView.checkStatus = true
        return kd_imageView
    }()
    
    lazy var kd_textLabel: UILabel = {
        let label = UILabel()
        label.font = FS4
        label.textColor = FC1
        return label
    }()
    
    lazy var kd_detailTextLabel: UILabel = {
        let label = UILabel()
        label.font = FS7
        label.textColor = FC2
        return label
    }()
    
    lazy var kd_timeLabel: UILabel = {
        let label = UILabel()
        label.font = FS8
        label.textColor = FC2
        return label
    }()
    
    lazy var kd_separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.kdDividingLine()
        return view
    }()
    
    lazy var labelBgView: UIView = {
        return UIView()
    }()

    var unreadImageView: XTUnreadImageView?
    var unreadCount: Int = 0 {
        didSet {
            if unreadCount > 0 {
                if unreadCount > 99 {
                    unreadImageView?.unreadCount = 0
                    unreadImageView?.frame = CGRect(x: KDFrame.screenWidth() - NSNumber.kdDistance1() - 9, y: 70 - NSNumber.kdDistance1() - 13, width: 9, height: 9)
                } else {
                    unreadImageView?.unreadCount = Int32(unreadCount)
                    unreadImageView?.frame.origin = CGPoint(x: KDFrame.screenWidth() - NSNumber.kdDistance1() - (unreadImageView?.frame.size.width ?? 0), y: 70 - 16 - 1 - NSNumber.kdDistance1())
                }
                unreadImageView?.isHidden = false
            } else {
                unreadImageView?.isHidden = true
            }
        }
    }
    var isGreyUnread = false {
        didSet {
//            unreadImageView?.bGrey = isGreyUnread
        }
    }
}
