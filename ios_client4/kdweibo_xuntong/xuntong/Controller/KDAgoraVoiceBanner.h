//
//  KDAgoraVoiceBanner.h
//  kdweibo
//
//  Created by lichao_liu on 10/27/15.
//  Copyright © 2015 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDAgoraVoiceBanner : UIView
@property (nonatomic, strong) UILabel *titleLabel;
- (void)makeMasory;
-(void)whenStartRecordBtnClicked:(id)sender;
- (void)whenFinishRecordBtnClicked:(id)sender;
@end
