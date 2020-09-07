//
//  KDSignInAdvancedSettingPickerView.swift
//  kdweibo
//
//  Created by 张培增 on 2016/12/16.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

import UIKit

class KDSignInAdvancedSettingPickerView: UIView {
    
    lazy var backgroundView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(rgb: 0x0C213F, alpha:0.3)
        return view
    }()
    
    lazy var pickerView : UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = FC6
        return pickerView
    }()
    
    lazy var toolBar : UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.backgroundColor = FC6
        toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolBar.clipsToBounds = true
        
        let leftItem : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))
        leftItem.setTitleTextAttributes([NSForegroundColorAttributeName: FC5, NSFontAttributeName: FS3], for: UIControlState())
        leftItem.setTitleTextAttributes([NSForegroundColorAttributeName: FC7, NSFontAttributeName: FS3], for: .highlighted)
        
        let rightItem : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(confirm(_:)))
        rightItem.setTitleTextAttributes([NSForegroundColorAttributeName: FC5, NSFontAttributeName: FS3], for: UIControlState())
        rightItem.setTitleTextAttributes([NSForegroundColorAttributeName: FC7, NSFontAttributeName: FS3], for: .highlighted)
        
        let flexibleSpaceItem : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolBar.items = [leftItem, flexibleSpaceItem, rightItem]
        return toolBar
    }()
    
    lazy var separatorLine : UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.kdDividingLine()
        return line
    }()
    
    var dataArray : NSMutableArray = NSMutableArray()
    
    var dataType : Int = 0 {
        didSet {
            switch dataType {
            // 0 ~ 120分钟
            case 1:
                if dataArray.count > 0 {
                    dataArray.removeAllObjects()
                }
                for index in 0 ..< 121 {
                    dataArray.add("\(index)")
                }
                pickerView.reloadAllComponents()
            // 30 ~ 600分钟
            case 2:
                if dataArray.count > 0 {
                    dataArray.removeAllObjects()
                }
                for index in 3 ..< 61 {
                    dataArray.add("\(index)0")
                }
                pickerView.reloadAllComponents()
            // 1 ~ 23小时
            case 3:
                if dataArray.count > 0 {
                    dataArray.removeAllObjects()
                }
                for index in 1 ..< 24 {
                    dataArray.add("\(index)")
                }
                pickerView.reloadAllComponents()
            default:
                break
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(backgroundView)
        backgroundView.mas_makeConstraints { make in
            make?.edges.mas_equalTo()(self)?.with().insets()(UIEdgeInsets.zero)
        }
        
        addSubview(pickerView)
        pickerView.mas_makeConstraints { make in
            make?.bottom.and().left().and().right().mas_equalTo()(self)
            make?.height.mas_equalTo()(216)
        }
        
        addSubview(toolBar)
        toolBar.mas_makeConstraints { make in
            make?.bottom.mas_equalTo()(self.pickerView.top)
            make?.left.and().right().mas_equalTo()(self)
            make?.height.mas_equalTo()(44)
        }
        
        addSubview(separatorLine)
        separatorLine.mas_makeConstraints { make in
            make?.left.and().right().mas_equalTo()(self)
            make?.bottom.mas_equalTo()(self.pickerView.top)
            make?.height.mas_equalTo()(1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

// MARK: - Method -
    func cancel(_ sender: AnyObject?) {
        self.isHidden = true
    }
    
    func confirm(_ sender: AnyObject?) {
        if let block = confirmBlock {
            let index = pickerView.selectedRow(inComponent: 0)
            if let title = dataArray.safeObjectAtIndex(index) as? String {
                block(title)
            }
        }
        self.isHidden = true
    }
    
    var confirmBlock : ((_ title: String?) -> ())? = nil
    
    func setTitle(_ title: String?) {
        guard let title = title, dataArray.contains(title) else {
            return
        }
        
        if let index : Int = dataArray.index(of: title) {
            pickerView.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
}

extension KDSignInAdvancedSettingPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let text = dataArray.safeObjectAtIndex(row) as? String {
            return text + (dataType == 3 ? ASLocalizedString("小时") : ASLocalizedString("分钟"))
        }
        else {
            return ""
        }
    }
}
