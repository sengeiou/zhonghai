//
//  File.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/8/31.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

import UIKit

extension NSObject {
    
    @objc func kd_setupVFL(_ bindings: [String: AnyObject],
                           constraints: [String]?) -> [NSLayoutConstraint] {
        return kd_setupVFL(bindings, metrics: nil, constraints: constraints, delayInvoke: false)
    }
    
    @objc func kd_setupVFL(_ bindings: [String: AnyObject],
                           metrics: [String : AnyObject]?,
                           constraints: [String]?,
                           delayInvoke: Bool) -> [NSLayoutConstraint] {
        
        var superview: UIView?
        var variableBindings = bindings
        variableBindings.values.forEach {
            if let view = $0 as? UIView {
                view.translatesAutoresizingMaskIntoConstraints = false
                if view.superview != nil {
                    superview = view.superview
                }
            }
        }
        
        if let vc = self as? UIViewController {
            variableBindings["topLayoutGuide"] = vc.topLayoutGuide
            variableBindings["bottomLayoutGuide"] = vc.bottomLayoutGuide
        }
        
        var result = [NSLayoutConstraint]()
        constraints?.forEach {
            if let superview = superview {
                let constraints = NSLayoutConstraint.constraints(withVisualFormat: $0, options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: variableBindings)
                if !delayInvoke {
                    superview.addConstraints(constraints)
                }
                result += constraints
            }
        }
        return result
    }
    
    // delay invoke
    func kd_invokeVFL(inView superview: UIView, constraints: [NSLayoutConstraint], removeConstraints: [NSLayoutConstraint]? = nil) {
        if let removeConstraints = removeConstraints {
            superview.removeConstraints(removeConstraints)
        }
        superview.addConstraints(constraints)
    }
    
}

extension UIView {
    
    func kd_setCenterX(toItem: UIView?, immediately: Bool = true) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: toItem, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        if immediately {
            superview?.addConstraint(constraint)
        }
        return constraint
    }

    func kd_setCenterX(immediately: Bool = true) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        if immediately {
            superview?.addConstraint(constraint)
        }
        return constraint
    }
    
    func kd_setCenterY(toItem: UIView?, immediately: Bool = true) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: toItem, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        if immediately {
            superview?.addConstraint(constraint)
        }
        return constraint
    }
    
    func kd_setCenterY(immediately: Bool = true) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        if immediately {
            superview?.addConstraint(constraint)
        }
        return constraint
    }
    
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach{ self.addSubview($0) }
    }
}
