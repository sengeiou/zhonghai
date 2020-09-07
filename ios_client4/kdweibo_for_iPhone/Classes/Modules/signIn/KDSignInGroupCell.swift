//
//  KDSignInGroupCell.swift
//  kdweibo
//
//  Created by 张培增 on 2016/12/2.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

import UIKit

final class KDSignInGroupCell: KDTableViewCell {
    
    lazy var groupIdLabel : UILabel = {
        let label = UILabel()
        label.font = FS5
        label.textColor = FC2
        return label
    }()
    
    lazy var groupNameLabel : UILabel = {
        let label = UILabel()
        label.font = FS2
        label.textColor = FC1
        return label
    }()
    
    lazy var departmentsOrPersonsLabel : UILabel = {
        let label = UILabel()
        label.font = FS4
        label.textColor = FC2
        return label
    }()
    
    lazy var detailLabel : UILabel = {
        let label = UILabel()
        label.font = FS4
        label.textColor = FC2
        return label
    }()
    
    lazy var locationLabel : UILabel = {
        let label = UILabel()
        label.font = FS4
        label.textColor = FC2
        return label
    }()
    
    lazy var departmentImage : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "signIn_setting_apartment")
        return imageView
    }()
    
    lazy var locationImage : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "signIn_setting_location")
        return imageView
    }()
    
    lazy var deleteButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "signIn_setting_delete_normal"), for: UIControlState())
        button.setImage(UIImage(named: "signIn_setting_delete_press"), for: UIControlState.highlighted)
        button.addTarget(self, action: #selector(buttonDidPressed(_:)), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        return button
    }()
    
    lazy var editButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "signIn_setting_edit_normal"), for: UIControlState())
        button.setImage(UIImage(named: "signIn_setting_edit_press"), for: UIControlState.highlighted)
        button.addTarget(self, action: #selector(buttonDidPressed(_:)), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        return button
    }()
    
    lazy var cornerView : KDSignInGroupCornerView = {
        let cornerView = KDSignInGroupCornerView()
        return cornerView
    }()
    
    lazy var gotoShiftWebsiteButton : KDV8Button = {
        let button = KDV8Button()
        button.addTarget(self, action: #selector(buttonDidPressed(_:)), for: .touchUpInside)
        let text = NSMutableAttributedString(string: "在web端修改排班制签到组")
        text.dz_setFont(FS4)
        text.dz_setTextColor(FC5)
        text.dz_setUnderline()
        button.setAttributedTitle(text, for: UIControlState())
        return button
    }()
    
    var signInGroupModel : KDSignInGroupLocalModel? {
        didSet {
            if let model = signInGroupModel {
                var size : CGSize = model.groupName.boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width - 24, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:FS2], context: nil).size
                groupNameLabel.numberOfLines = size.height > 21 ? 2 : 1
                groupNameLabel.text = model.groupName
                
                if model.departmentsArray.count > 0 && model.usersArray.count > 0 {
                    departmentsOrPersonsLabel.numberOfLines = 1
                    departmentsOrPersonsLabel.text = ASLocalizedString("签到部门：\(model.departmentsArray.count)个")
                    detailLabel.isHidden = false
                    detailLabel.text = ASLocalizedString("签到个人：\(model.usersArray.count)名")
                    departmentsOrPersonsLabel.remakeConstraints { make in
                        make?.left.mas_equalTo()(self.departmentImage.right)?.with().offset()(8)
                        make?.right.mas_lessThanOrEqualTo()(self.contentView)?.with().offset()(-NSNumber.kdDistance1())
                        make?.top.mas_equalTo()(self.departmentImage)?.with().offset()(0)
                    }
                }
                else {
                    size = model.deptsOrPersonsName.boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width - 48, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:FS4], context: nil).size
                    departmentsOrPersonsLabel.numberOfLines = size.height > 20 ? 2 : 1
                    departmentsOrPersonsLabel.text = model.deptsOrPersonsName
                    detailLabel.isHidden = true
                    departmentsOrPersonsLabel.remakeConstraints { make in
                        make?.left.mas_equalTo()(self.departmentImage.right)?.with().offset()(8)
                        make?.right.mas_equalTo()(self.contentView)?.with().offset()(-NSNumber.kdDistance1())
                        make?.top.mas_equalTo()(self.departmentImage)?.with().offset()(0)
                    }
                }
                
                size = model.locationName.boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width - 48, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:FS4], context: nil).size
                locationLabel.numberOfLines = size.height > 20 ? 2 : 1
                locationLabel.text = model.locationName
                
                cornerView.isShift = model.isShift
                if model.isShift {
                    deleteButton.isHidden = true
                    editButton.isHidden = true
                    gotoShiftWebsiteButton.isHidden = false
                }
                else {
                    deleteButton.isHidden = false
                    editButton.isHidden = false
                    gotoShiftWebsiteButton.isHidden = true
                }
            }
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(groupIdLabel)
        groupIdLabel.mas_makeConstraints { make in
            make?.left.mas_equalTo()(self.contentView)?.with().offset()(NSNumber.kdDistance1())
            make?.right.mas_equalTo()(self.contentView)?.with().offset()(-NSNumber.kdDistance1())
            make?.top.mas_equalTo()(self.contentView)?.with().offset()(18)
        }
        
        contentView.addSubview(groupNameLabel)
        groupNameLabel.mas_makeConstraints { make in
            make?.left.mas_equalTo()(self.contentView)?.with().offset()(NSNumber.kdDistance1())
            make?.right.mas_equalTo()(self.contentView)?.with().offset()(-NSNumber.kdDistance1())
            make?.top.mas_equalTo()(self.groupIdLabel.bottom)?.with().offset()(1)
        }
        
        contentView.addSubview(departmentImage)
        departmentImage.mas_makeConstraints { make in
            make?.left.mas_equalTo()(self.contentView)?.with().offset()(NSNumber.kdDistance1())
            make?.top.mas_equalTo()(self.groupNameLabel.bottom)?.with().offset()(27)
            make?.width.mas_equalTo()(16)
            make?.height.mas_equalTo()(16)
        }
        
        contentView.addSubview(departmentsOrPersonsLabel)
        departmentsOrPersonsLabel.mas_makeConstraints { make in
            make?.left.mas_equalTo()(self.departmentImage.right)?.with().offset()(8)
            make?.right.mas_lessThanOrEqualTo()(self.contentView)?.with().offset()(-NSNumber.kdDistance1())
            make?.top.mas_equalTo()(self.departmentImage)?.with().offset()(0)
        }
        
        contentView.addSubview(detailLabel)
        detailLabel.mas_makeConstraints { make in
            make?.top.mas_equalTo()(self.departmentImage)?.with().offset()(0)
            make?.left.mas_equalTo()(self.departmentsOrPersonsLabel.right)?.with().offset()(NSNumber.kdDistance1())
            make?.right.mas_lessThanOrEqualTo()(self.contentView)?.with().offset()(-NSNumber.kdDistance1())
        }
        
        contentView.addSubview(locationImage)
        locationImage.mas_makeConstraints { make in
            make?.left.mas_equalTo()(self.contentView)?.with().offset()(NSNumber.kdDistance1())
            make?.top.mas_equalTo()(self.departmentsOrPersonsLabel.bottom)?.with().offset()(NSNumber.kdDistance1())
            make?.width.mas_equalTo()(16)
            make?.height.mas_equalTo()(16)
        }
        
        contentView.addSubview(locationLabel)
        locationLabel.mas_makeConstraints { make in
            make?.left.mas_equalTo()(self.locationImage.right)?.with().offset()(8)
            make?.right.mas_equalTo()(self.contentView)?.with().offset()(-NSNumber.kdDistance1())
            make?.top.mas_equalTo()(self.locationImage)?.with().offset()(0)
        }
        
        contentView.addSubview(editButton)
        editButton.mas_makeConstraints { make in
            make?.top.mas_equalTo()(self.locationLabel.bottom)?.with().offset()(10)
            make?.right.mas_equalTo()(self.contentView)?.with().offset()(-10)
            make?.width.mas_equalTo()(44)
            make?.height.mas_equalTo()(44)
        }
        
        contentView.addSubview(deleteButton)
        deleteButton.mas_makeConstraints { make in
            make?.top.mas_equalTo()(self.editButton)
            make?.right.mas_equalTo()(self.editButton.left)?.with().offset()(-8)
            make?.width.mas_equalTo()(44)
            make?.height.mas_equalTo()(44)
        }
        
        contentView.addSubview(cornerView)
        cornerView.mas_makeConstraints { make in
            make?.top.mas_equalTo()(self.contentView)
            make?.right.mas_equalTo()(self.contentView)
            make?.width.mas_equalTo()(60)
            make?.height.mas_equalTo()(20)
        }
        
        contentView.addSubview(gotoShiftWebsiteButton)
        gotoShiftWebsiteButton.mas_makeConstraints { make in
            make?.bottom.mas_equalTo()(self.contentView)?.with().offset()(-12)
            make?.right.mas_equalTo()(self.contentView)?.with().offset()(-12)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
// MARK: - Method -
    func buttonDidPressed(_ sender: UIButton) {
        if sender == editButton {
            if let edit = edit {
                edit()
            }
        }
        else if sender == deleteButton {
            if let delete22 = delete22 {
                delete22()
            }
        }
        else if sender == gotoShiftWebsiteButton {
            if let gotoShiftWebsite = gotoShiftWebsite {
                gotoShiftWebsite()
            }
        }
    }
    
    var edit: (() -> ())? = nil
    var delete22: (() -> ())? = nil
    var gotoShiftWebsite: (() -> ())? = nil

}
