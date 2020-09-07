//
//  KDVFL.m
//  kdweibo
//
//  Created by Darren on 15/3/16.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

@implementation KDVFL

/*
// VFL配置代码
func setupVFL(#target: AnyObject, var #variableBindings: [String: AnyObject], #constraintStrings: [String],  #metrics: [String: CGFloat], #moreInfo: ()->()) {
    for view in variableBindings.values {
        if view is UIView {
            if target is UIViewController {
                if let parentView = target.view {
                    parentView!.addSubview(view as UIView)
                }
            } else if target is UIView {
                target.addSubview(view as UIView)
            }
        }
    }
    if target is UIViewController {
        variableBindings["topLayoutGuide"] = target.topLayoutGuide
        variableBindings["bottomLayoutGuide"] = target.bottomLayoutGuide
    }
    for constrantString in constraintStrings {
        if target is UIViewController {
            if let parentView = target.view {
                parentView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(constrantString, options: NSLayoutFormatOptions(0), metrics: metrics, views: variableBindings))
            }
        } else if target is UIView {
            target.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(constrantString, options: NSLayoutFormatOptions(0), metrics: metrics, views: variableBindings))
        }
    }
    moreInfo()
}

// Autolayout水平居中
func autolayoutSetCenterX(view: UIView!) {
    view.superview?.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view.superview?, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
}

// Autolayout垂直居中
func autolayoutSetCenterY(view: UIView!) {
    view.superview?.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view.superview?, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
}

// 屏幕宽
func screenWidth() -> CGFloat {
    return UIScreen.mainScreen().bounds.width;
}

// 屏幕高
func screenHeight() -> CGFloat {
    return UIScreen.mainScreen().bounds.height;
}
*/

void setupVFL(id target, NSDictionary *variableBindings, NSArray *constraintStrings, NSDictionary *metrics, void(^moreInfo)()) {

    if (![target isKindOfClass:[UIView class]] && ![target isKindOfClass:[UIViewController class]]) {
        return;
    }

    NSMutableDictionary *mVariableBindings = variableBindings.mutableCopy;

    NSMutableDictionary *mMetrics = metrics.mutableCopy;

    for (UIView *view in variableBindings.allValues) {
        if ([view isKindOfClass:[UIView class]]) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
    }

    for (NSString *constraintString in constraintStrings) {
        if ([target isKindOfClass:[UIViewController class]]) {
            UIViewController *c = (UIViewController *) target;
            [c.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintString
                                                                           options:0
                                                                           metrics:mMetrics
                                                                             views:mVariableBindings]];
        }

        if ([target isKindOfClass:[UIView class]]) {
            UIView *v = (UIView *) target;
            [v addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintString
                                                                      options:0
                                                                      metrics:mMetrics
                                                                        views:mVariableBindings]];

        }
    }

    if (moreInfo) {
        moreInfo();
    }
}

void autolayoutSetCenterX(UIView *view) {
    [view.superview addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:view.superview
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.f constant:0.f]];
}

void autolayoutSetCenterY(UIView *view) {
    [view.superview addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:view.superview
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1.f constant:0.f]];
}


@end
