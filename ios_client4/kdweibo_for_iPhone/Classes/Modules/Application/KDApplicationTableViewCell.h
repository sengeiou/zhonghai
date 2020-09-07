//
//  KDApplicationTableViewCell.h
//  kdweibo
//
//  Created by 郑学明 on 14-4-28.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDAppDataModel;
@protocol KDApplicationTableViewCellDelegate <NSObject>
- (void)viewDetail:(KDAppDataModel*)appDM;
- (void)openApp:(KDAppDataModel*)appDM;
@end

@interface KDApplicationTableViewCell : UITableViewCell
- (id)initWithStyleDetail:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (id)initWithStyleSimple:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@property (nonatomic,retain) KDAppDataModel *appInfo;
@property (nonatomic,assign) id<KDApplicationTableViewCellDelegate> delegate;
@property (nonatomic,assign) BOOL isExist;
@property (nonatomic,assign) CGFloat separatorLineSpace;

@end