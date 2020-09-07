//
//  KDDistancePicker.h
//  kdweibo
//
//  Created by lichao_liu on 7/17/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TappedEventHandler)(NSInteger distance);
@interface KDDistancePicker : UIView

@property(nonatomic, copy) TappedEventHandler leftEventHandler;
@property(nonatomic, copy) TappedEventHandler rightEventHandler;

- (NSInteger)distance;

- (void)setDistance:(NSInteger)distance;
@end
