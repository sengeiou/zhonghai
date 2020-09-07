//
//  KDSignInDepartmentsCell.swift
//  kdweibo
//
//  Created by 张培增 on 2016/12/2.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

import UIKit

final class KDSignInDepartmentsCell: KDTableViewCell {
    
    fileprivate lazy var flowLayout: KDCollectionViewLeftAlignedLayout = {
        return $0
    }(KDCollectionViewLeftAlignedLayout())
    
    fileprivate lazy var departmentCollectionView: UICollectionView = {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = UIColor.white
        $0.isScrollEnabled = false
        $0.register(KDSignInDepartmentItem.self, forCellWithReuseIdentifier: "SignInDepartmentItem")
        return $0
    }(UICollectionView(frame: CGRect.zero, collectionViewLayout: self.flowLayout))
    
    fileprivate lazy var separatorLine : UIView = {
        $0.backgroundColor = UIColor.kdDividingLine()
        return $0
    }(UIView())

    var departmentsArray = [KDSignInDepartmentItemModel]() {
        didSet {
            self.departmentCollectionView.reloadData()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubviews([departmentCollectionView, separatorLine])
        kd_setupVFL([
            "departmentCollectionView" : departmentCollectionView,
            "separatorLine" : separatorLine
            ], constraints: [
                "H:|-12-[departmentCollectionView]-12-|",
                "H:|-12-[separatorLine]|",
                "V:|-15-[departmentCollectionView]-15-|",
                "V:[separatorLine(0.5)]|"
            ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var deleteItem: ((_ itemIndex: NSInteger) -> ())? = nil

}

extension KDSignInDepartmentsCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return departmentsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SignInDepartmentItem", for: indexPath) as! KDSignInDepartmentItem
        let model = departmentsArray[indexPath.row]
        cell.textLable.text = model.departmentName
        cell.close = {
            if let deleteItem = self.deleteItem {
                deleteItem(indexPath.row)
            }
        }
        return cell
    }
    
}

extension KDSignInDepartmentsCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = departmentsArray[indexPath.row]
        return CGSize(width: model.itemWidth, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return NSNumber.kdDistance1()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return NSNumber.kdDistance1()
    }
    
}
