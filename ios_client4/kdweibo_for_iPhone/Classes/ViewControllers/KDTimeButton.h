//
//  KDAdsManager.h
//  kdweibo
//
//  Created by lichao_liu on 16/1/19.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KDTimeButton : UIButton

- (id)initWithTitle:(NSString *)title andTime:(NSInteger)num;
 
@property (nonatomic,assign)NSInteger timerNumber;  //time
@end
