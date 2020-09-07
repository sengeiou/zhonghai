//
//  KDMarkListBaseCell.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/8/9.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

import UIKit

@objc protocol KDMarkListBaseCellDelegate  {
    func remindButtonPressedWithCell(_ cell: KDMarkListBaseCell)
    func deleteButtonPressedWithCell(_ cell: KDMarkListBaseCell)
}

class KDMarkListBaseCell: KDMarkBaseCell {
    
    var baseDelegate: KDMarkListBaseCellDelegate?
    
    lazy var slimSeparatorLine: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = UIColor.kdDividingLine()
        return view
    }()
    
    lazy var verticalSeparatorLine: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = UIColor.kdDividingLine()
        return view
    }()
    
    class KDMarkListCustomButton: UIButton {
        override var isHighlighted: Bool {
            didSet {
                if isHighlighted {
                    backgroundColor = UIColor(hexRGB: "e5e5e5")
                } else {
                    backgroundColor = UIColor.white
                }
            }
        }
    }
    lazy var remindButton: KDMarkListCustomButton = {
        let button = KDMarkListCustomButton()
        button.setImage(UIImage(named: "mark_btn_remind-1"), for: UIControlState())
        button.setTitleColor(FC1, for: UIControlState())
        button.titleLabel?.font = FS4
        button.setTitle(ASLocalizedString("Mark_tip"), for: UIControlState())
        button.addTarget(self, action: #selector(KDMarkListBaseCell.remindButtonPressed), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        return button
    }()
    
    func remindButtonPressed() {
        KDEventAnalysis.eventCountly(event_mark_notify)
        self.baseDelegate?.remindButtonPressedWithCell(self)
    }

    
    lazy var deleteButton: KDMarkListCustomButton = {
        let button = KDMarkListCustomButton()
        button.setImage(UIImage(named: "mark_btn_delete-1"), for: UIControlState())
        button.setTitleColor(FC1, for: UIControlState())
        button.titleLabel?.font = FS4
        
        button.setTitle(ASLocalizedString("Mark_delete"), for: UIControlState())
        button.addTarget(self, action: #selector(KDMarkListBaseCell.deleteButtonPressed), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        return button
    }()
    
    func deleteButtonPressed() {
        self.baseDelegate?.deleteButtonPressedWithCell(self)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(slimSeparatorLine)
        slimSeparatorLine.mas_makeConstraints { make in
            make?.height.mas_equalTo()(0.5)
            make?.bottom.equalTo()(self.separatorLine.top)?.with().offset()(-45)
            make?.left.equalTo()(self.slimSeparatorLine.superview!.left)?.with().offset()(0)
            make?.right.equalTo()(self.slimSeparatorLine.superview!.right)?.with().offset()(-0)
            return()
        }
        
        contentView.addSubview(verticalSeparatorLine)
        verticalSeparatorLine.mas_makeConstraints { make in
            make?.height.mas_equalTo()(14)
            make?.width.mas_equalTo()(0.5)
            make?.centerX.equalTo()(self.verticalSeparatorLine.superview!.centerX)
            make?.bottom.equalTo()(self.separatorLine.top)?.with().offset()(-15)
            return()
        }
        
        contentView.addSubview(remindButton)
        remindButton.mas_makeConstraints { make in
            make?.left.equalTo()(self.remindButton.superview!.left)?.with().offset()(0)
            make?.right.equalTo()(self.verticalSeparatorLine.left)?.with().offset()(-0)
            make?.bottom.equalTo()(self.separatorLine.top)?.with().offset()(-0)
            make?.top.equalTo()(self.slimSeparatorLine.bottom)?.with().offset()(0)
            return()
        }
        
        contentView.addSubview(deleteButton)
        deleteButton.mas_makeConstraints { make in
            make?.right.equalTo()(self.deleteButton.superview!.right)?.with().offset()(-0)
            make?.left.equalTo()(self.verticalSeparatorLine.right)?.with().offset()(0)
            make?.bottom.equalTo()(self.separatorLine.top)?.with().offset()(-0)
            make?.top.equalTo()(self.slimSeparatorLine.bottom)?.with().offset()(0)
            return()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
