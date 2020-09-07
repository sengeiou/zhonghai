//
//  KWIVoteOptionV.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/28/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDVoteOption;

@interface KWIVoteOptionV : UIView

+ (KWIVoteOptionV *)view;

//+ (NSUInteger)height;

@property (retain, nonatomic) KDVoteOption *data;

//- (void)on;
- (void)off;

//- (void)lock;
//- (void)unlock;

@end