
//
//  KDCustomPopover.swift
//  kdweibo
//
//  Created by Darren Zheng on 7/8/16.
//  Copyright © 2016 www.kingdee.com. All rights reserved.
//

@objc class KDCustomPopover: NSObject {
    
    fileprivate var showing: Bool = false

    lazy var dxPopover: DXPopover = {
        let dxPopover = DXPopover()
//        dxPopover.alpha = 0.9
        dxPopover.animationOut = 0
        dxPopover.cornerRadius = 15
        dxPopover.contentColor = UIColor.white
        return dxPopover
    }()
    
    @objc func hide() {
        if !dxPopover.isHidden {
            dxPopover.isHidden = true
            showing = false
        }
    }
    
    @objc func showAtView(_ view: UIView?, contentView: UIView?, inView: UIView?) {
        guard let view = view, let contentView = contentView, let inView = inView
            else { return }
        inView.clipsToBounds = false
        let location = view.frame.origin
        let targetFrame = view.frame
        let pos = DXPopoverPosition.up
        let point = CGPoint(
            x: location.x + targetFrame.size.width / 2,
            y: location.y
        )
        if !showing {
            dxPopover.isHidden = false
            dxPopover.show(at: point, popoverPostion: pos, withContentView: contentView, in: inView)
            showing = true
        }
    }
    
    @objc func showAtPoint(_ point: CGPoint, contentView: UIView?, inView: UIView?) {
        guard let contentView = contentView, let inView = inView
            else { return }
        if !showing {
            dxPopover.isHidden = false
            self.dxPopover.show(at: point, popoverPostion: .up, withContentView: contentView, in: inView)
            showing = true
        }
    }
    
}

