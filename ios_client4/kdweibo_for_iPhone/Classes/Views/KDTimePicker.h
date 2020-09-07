//
//  TimePicker.h
//  SignUp
//
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

typedef void (^buttonTappedEventHandler)(void);
@interface KDTimePicker :UIView
@property(nonatomic,copy)buttonTappedEventHandler leftEventHandler;
@property(nonatomic,copy)buttonTappedEventHandler rightEventHandler;
- (NSDate *)date;
- (void) setDate:(NSDate *)date ;
@end
