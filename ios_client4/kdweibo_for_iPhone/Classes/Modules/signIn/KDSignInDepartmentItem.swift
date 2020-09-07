//
//  KDSignInDepartmentItem.swift
//  kdweibo
//
//  Created by 张培增 on 2016/12/5.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

import UIKit

class KDSignInDepartmentItem: UICollectionViewCell {
    
    lazy var textLable : UILabel = {
        let label = UILabel()
        label.font = FS4
        label.textColor = FC2
        return label
    }()
    
    fileprivate lazy var closeBtn : UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "app_enter_connect_close_icon"), for: UIControlState())
        button.addTarget(self, action: #selector(closeBtnPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    var close: (() -> ())? = nil
    
    func closeBtnPressed(_ sender: UIButton) {
        if let close = self.close {
            close()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.kdBackgroundColor1()
        layer.cornerRadius = 15
        layer.masksToBounds = true
        
        contentView.addSubview(closeBtn)
        closeBtn.mas_makeConstraints { make in
            make?.right.mas_equalTo()(self)?.with().offset()(-16)
            make?.centerY.mas_equalTo()(self.mas_centerY)
            make?.height.mas_equalTo()(16)
            make?.width.mas_equalTo()(16)
        }
        
        contentView.addSubview(textLable)
        textLable.mas_makeConstraints { make in
            make?.left.mas_equalTo()(self)?.with().offset()(16)
            make?.right.mas_equalTo()(self.closeBtn.left)?.with().offset()(-8)
            make?.centerY.mas_equalTo()(self.mas_centerY)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
