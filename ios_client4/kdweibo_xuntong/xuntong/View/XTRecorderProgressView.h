//
//  SpeakProgressBar.h
//  ContactsLite
//
//  Created by kingdee eas on 13-3-4.
//  Copyright (c) 2013年 kingdee eas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface XTRecorderProgressView : UIView 

@property (nonatomic, strong) UIView *progressInnerView;
@property (nonatomic, strong) UIView *progressOutterView;

- (void)setProgress:(int)progress;

@end