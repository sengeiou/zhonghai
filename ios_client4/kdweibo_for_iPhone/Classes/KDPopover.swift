//
//  KDPopover.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/5.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

/*
 |-DXPopover
 |--KDPopoverContentView
 |---KDPopoverItemView
 */

@objc protocol KDPopoverDataSource {
    // 每行几个元素
    func itemCountForRow() -> Int
    // 数据源
    func itemModels(_ popover: KDPopover) -> [KDItem]
}

@objc class KDPopover: NSObject {
    
    var dataSource: KDPopoverDataSource?
    var targetView: UIView?
    var containView: UIView?
    fileprivate lazy var dxPopover: DXPopover = {
        let dxPopover = DXPopover()
        dxPopover.alpha = 0.9
        dxPopover.animationOut = 0
        dxPopover.cornerRadius = 15
        dxPopover.contentColor = UIColor(hexRGB: "04142a")
        return dxPopover
    }()
    
    fileprivate let arrowHeight: CGFloat = 10
    
//    @objc func showAt(view: UIView?) {
//        guard let view = view
//            else { return }
//        targetView = view
//        showAt(location:view.convertRect(view.bounds, toView:nil).origin,targetFrame:view.frame, topMargin:64)
//    }
   
    @objc func showAt(_ view: UIView?,containView:UIView?) {
        guard let view = view
            else { return }
        targetView = view
        self.containView = containView;
        showAt(location:view.convert(view.bounds, to:containView).origin,targetFrame:view.frame, topMargin:64)
    }
    
    
    fileprivate func showAt(location: CGPoint, targetFrame: CGRect, topMargin: CGFloat) {
        
        guard dataSource != nil && dataSource?.itemModels(self) != nil && (dataSource?.itemModels(self).count)! > 0
            else { return }
        
        let popoverContentView = KDPopoverContentView(frame:CGRect.zero, popover: self)
        popoverContentView.dataSource = self.dataSource
        popoverContentView.frame = popoverContentView.calculateOutsideFrame()
        popoverContentView.targetView = targetView
        popoverContentView.onAnyButtonPress = {
            self.dxPopover.dismiss()
        }
        var pos = DXPopoverPosition.down
        var point = CGPoint.zero
        
        let topUnavailable = topMargin + arrowHeight + popoverContentView.frame.size.height >= location.y
        let bottomUnavailable = location.y + targetFrame.size.height + arrowHeight + popoverContentView.frame.size.height  >= UIScreen.main.bounds.height - 44
        if topUnavailable && bottomUnavailable {
            func showInMiddle() {
                pos = DXPopoverPosition.up
                point = CGPoint(
                    x: location.x + targetFrame.size.width / 2,
                    y: UIScreen.main.bounds.height / 2
                )
            }
            showInMiddle()
        } else if topUnavailable {
            func showInBottom() {
                pos = DXPopoverPosition.down
                point = CGPoint(
                    x: location.x + targetFrame.size.width / 2,
                    y: location.y + targetFrame.size.height
                )
            }
            showInBottom()
        } else {
            func showInTop() {
                pos = DXPopoverPosition.up
                point = CGPoint(
                    x: location.x + targetFrame.size.width / 2,
                    y: location.y
                )
            }
            showInTop()
        }
        
        if containView == nil
        {
            self.dxPopover.show(at: point, popoverPostion: pos, withContentView: popoverContentView, in: UIApplication.shared.keyWindow)
        }
        else
        {
            self.dxPopover.show(at: point, popoverPostion: pos, withContentView: popoverContentView, in:containView)
        }
    }
    
}

private class KDPopoverContentView: UIView {
    
    fileprivate let itemWidth: CGFloat = 59.0
    fileprivate let itemHeight: CGFloat = 58.0
    fileprivate let edgeMargin: CGFloat = 8 // 四周边距
    fileprivate let middleMargin: CGFloat = 3 // 元素两行夹缝距离
    fileprivate weak var popover: KDPopover?
    var targetView: UIView?

    var onAnyButtonPress: (() -> Void)?
    var dataSource: KDPopoverDataSource? {
        didSet {
            if let dataSource = dataSource, let popover = popover {
                for (index, model) in dataSource.itemModels(popover).enumerated() {
                    let itemCountForRow = dataSource.itemCountForRow()
                    let itemView = KDPopoverItemView()
                    itemView.titleLabel.text = model.title
                    itemView.imageView.image = model.image
                    itemView.onPress = {
                        self.onAnyButtonPress?()
                        model.onPress?(self.targetView)
                    }
                    itemView.frame = CGRect(
                        x: edgeMargin + CGFloat(index % itemCountForRow) * itemWidth,
                        y: edgeMargin + CGFloat(index / itemCountForRow) * (itemHeight + middleMargin),
                        width: itemWidth,
                        height: itemHeight)
                    addSubview(itemView)
                }
            }
        }
    }
    
    init(frame: CGRect, popover: KDPopover) {
        super.init(frame: frame)
        self.popover = popover
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func calculateOutsideFrame() -> CGRect {
        guard let dataSource = dataSource, let popover = popover
            else { return CGRect.zero }
        return CGRect(
            x: 0,
            y: 0,
            width: edgeMargin * 2 + (dataSource.itemModels(popover).count >= dataSource.itemCountForRow() ? CGFloat(dataSource.itemCountForRow())
                * itemWidth : CGFloat(dataSource.itemModels(popover).count % dataSource.itemCountForRow()) * itemWidth),
            height: edgeMargin * 2 + ceil(CGFloat(dataSource.itemModels(popover).count) / CGFloat(dataSource.itemCountForRow())) * (itemHeight + middleMargin)
        )
    }
    
}

private class KDPopoverItemView: UIView {
    
    fileprivate var onPress: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.mas_makeConstraints { make in
            make?.top.equalTo()(self.imageView.superview!.top)?.with().offset()(8)
            make?.centerX.equalTo()(self.imageView.superview!.centerX)
            make?.width.mas_equalTo()(25)
            make?.height.mas_equalTo()(25)
            return()
        }
        addSubview(titleLabel)
        titleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(self.imageView.bottom)?.with().offset()(6)
            make?.bottom.equalTo()(self.titleLabel.superview!.bottom)?.with().offset()(-8)
            make?.centerX.equalTo()(self.titleLabel.superview!.centerX)
            return()
        }
        
        addSubview(button)
        button.mas_makeConstraints { make in
            make?.edges.equalTo()(self.button.superview!)?.with().insets()(UIEdgeInsets.zero)
            return()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func buttonPressed() {
        onPress?()
    }
    
    fileprivate lazy var button: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(KDPopoverItemView.buttonPressed), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var imageView: UIImageView = {
        return UIImageView()
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kdFont7()
        label.textColor = UIColor.kdTextColor6()
        label.textAlignment = .center
        return label
    }()
}

