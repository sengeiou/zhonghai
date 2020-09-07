//
//  KDSignInGroupManageDefaultView.swift
//  kdweibo
//
//  Created by 张培增 on 2016/12/7.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

import UIKit

final class KDSignInGroupManageDefaultView: UIView {
    
    lazy var defaultImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "signInGroup_defaultView")
        return imageView
    }()
    
    lazy var label1 : UILabel = {
        let label = UILabel()
        let str1 = NSMutableAttributedString(string: ASLocalizedString("  支持按照部门进行考勤"))
        str1.dz_insertImage(withName: "signInGroup_defaultView_department", location: 0, bounds: CGRect(x: 0, y: -2, width: 16, height: 16))
        str1.dz_setFont(FS4)
        str1.dz_setTextColor(FC2)
        str1.dz_setTextAlignment(.center)
        label.attributedText = str1
        return label
    }()
    
    lazy var label2 : UILabel = {
        let label = UILabel()
        let str2 = NSMutableAttributedString(string: ASLocalizedString("  新员工自动加入签到组"))
        str2.dz_insertImage(withName: "signInGroup_defaultView_newEmployee", location: 0, bounds: CGRect(x: 0, y: -2, width: 16, height: 16))
        str2.dz_setFont(FS4)
        str2.dz_setTextColor(FC2)
        str2.dz_setTextAlignment(.center)
        label.attributedText = str2
        return label
    }()
    
    lazy var label3 : UILabel = {
        let label = UILabel()
        let str3 = NSMutableAttributedString(string: ASLocalizedString("  支持设置弹性考勤规则"))
        str3.dz_insertImage(withName: "signInGroup_defaultView_attendance", location: 0, bounds: CGRect(x: 0, y: -2, width: 16, height: 16))
        str3.dz_setFont(FS4)
        str3.dz_setTextColor(FC2)
        str3.dz_setTextAlignment(.center)
        label.attributedText = str3
        return label
    }()
    
    lazy var createSignInGroupButton : UIButton = {
        let button = UIButton.blueBtn(withTitle: ASLocalizedString("新建签到组"))
        button?.titleLabel?.font = FS3
        button?.layer.cornerRadius = 22
        button?.addTarget(self, action: #selector(buttonDidPressed(_:)), for: .touchUpInside)
        return button!
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        addSubview(defaultImageView)
        addSubview(label1)
        addSubview(label2)
        addSubview(label3)
        addSubview(createSignInGroupButton)
        
        defaultImageView.mas_makeConstraints { make in
            make?.top.mas_equalTo()(self)?.with().offset()(110)
            make?.centerX.mas_equalTo()(self.mas_centerX)
        }
        
        label1.mas_makeConstraints { make in
            make?.top.mas_equalTo()(self.defaultImageView.bottom)?.with().offset()(38)
            make?.centerX.mas_equalTo()(self.mas_centerX)
        }
        
        label2.mas_makeConstraints { make in
            make?.top.mas_equalTo()(self.label1.bottom)?.with().offset()(11)
            make?.centerX.mas_equalTo()(self.mas_centerX)
        }
        
        label3.mas_makeConstraints { make in
            make?.top.mas_equalTo()(self.label2.bottom)?.with().offset()(11)
            make?.centerX.mas_equalTo()(self.mas_centerX)
        }
        
        createSignInGroupButton.mas_makeConstraints { make in
            make?.top.mas_equalTo()(self.label3.bottom)?.with().offset()(36)
            make?.left.mas_equalTo()(self)?.with().offset()(36)
            make?.right.mas_equalTo()(self)?.with().offset()(-36)
            make?.height.mas_equalTo()(44)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func buttonDidPressed(_ sender: UIButton) {
        if let createSignInGroup = createSignInGroup {
            createSignInGroup()
        }
    }
    
    var createSignInGroup: (() -> ())? = nil

}
