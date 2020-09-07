//
//  KDTextEditView.h
//  kdweibo
//
//  Created by kingdee on 2017/8/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

// 高100+36

typedef void(^EditTextCompleteBlock)(UITextView *textView);

@interface KDTextEditView : UIView
@property (nonatomic, strong)UITextView *textView;
@property (nonatomic, strong)EditTextCompleteBlock editTextComplete;

@end
