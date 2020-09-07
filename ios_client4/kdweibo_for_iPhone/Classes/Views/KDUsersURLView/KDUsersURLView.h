//
//  KDUsersURLView.h
//  kdweibo
//  someone's  statuse parse with urlView 
//  Created by Guohuan Xu on 3/31/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "DSURLView.h"

@interface KDUsersURLView : DSURLView

//init method for usersURLView
- (id)initWithFontSize:(CGFloat)fontSize
                 width:(CGFloat)width
              delegate:(id)delegate;
//set content and element ,then layout
-(void)layoutUsersUrlViewWith:(NSString *)replyStatusString
                     userName:(NSString *)useName
                       userId:(NSString *)userId;
@end
