//
//  KDMarkGuideVC.swift
//  DZFoundation
//
//  Created by Darren Zheng on 16/4/29.
//  Copyright © 2016年 Darren Zheng. All rights reserved.
//


final class KDMarkGuideVC: UIViewController {
    var calendar = KDCalendar()

    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        title = ASLocalizedString("Mark_setAlert")

        view.addSubview(label0)
        label0.mas_makeConstraints { make in
            make?.centerX.equalTo()(self.label0.superview!.centerX)
            make?.top.equalTo()(self.label0.superview!.top)?.with().offset()(150)
            return()
        }
        
        view.addSubview(imageView0)
        imageView0.mas_makeConstraints { make in
            make?.top.equalTo()(self.label0.bottom)?.with().offset()(25)
            make?.centerX.equalTo()(self.imageView0.superview!.centerX)
            make?.width.mas_equalTo()(KDFrame.screenWidth() - 40 * 2)
            make?.height.mas_equalTo()(self.imageView0.image!.heightDivideWidthRatio * (KDFrame.screenWidth() - 40 * 2))
            return()
        }
        
        if #available(iOS 8.0, *) {
            view.addSubview(button0)
            button0.mas_makeConstraints { make in
                make?.top.equalTo()(self.imageView0.bottom)?.with().offset()(40)
                make?.height.mas_equalTo()(44)
                make?.centerX.equalTo()(self.button0.superview!.centerX)
                make?.width.mas_equalTo()(KDFrame.screenWidth() - 40 * 2)
                return()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 用户去系统设置开启了日历权限的防御
        calendar.requestAccess { succ in
            if succ {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    lazy var label0: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 0
        
        let str0 = "请进入系统“设置>隐私>日历”"
        let str1 = "\n允许“\(KD_APPNAME)”访问你的日历"
        
        let mStr = NSMutableAttributedString(string: str0 + str1)
        mStr.dz_setFont(FS5, range: NSMakeRange(0, str0.characters.count))
        mStr.dz_setTextColor(FC2, range: NSMakeRange(0, str0.characters.count))
        
        mStr.dz_setFont(FS5, range: NSMakeRange(str0.characters.count, str1.characters.count))
        mStr.dz_setTextColor(FC1, range: NSMakeRange(str0.characters.count, str1.characters.count))
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.lineSpacing = 10
        mStr.dz_setParagraphStyle(style)
        
        label.attributedText = mStr
        
        return label
    }()
    
    lazy var imageView0: UIImageView = {
        let imageView = UIImageView()
        // TODO: change image
        imageView.image = UIImage(named:"mark_tip_calendar")
        return imageView
    }()
    
    lazy var button0: KDWideButton = {
        let button = KDWideButton()
        button.setTitle("去设置", for: UIControlState())
        button.titleLabel!.font = FS2
        button.setTitleColor(FC6, for: UIControlState())
        button.addTarget(self, action: #selector(KDMarkGuideVC.button0Pressed), for: .touchUpInside)
        return button
    }()
    
    func button0Pressed() {
        if #available(iOS 8.0, *) {
            let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
}
