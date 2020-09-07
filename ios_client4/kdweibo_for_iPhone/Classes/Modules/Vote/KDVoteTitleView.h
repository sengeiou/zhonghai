//
//  KDVoteTitleView.h
//  kdweibo
//
//  Created by Guohuan Xu on 3/30/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommenMethod.h"
#import "KDUsersURLView.h"

@interface KDVoteTitleView : UIView<DSURLViewDelegate>
{
    IBOutlet UILabel * _voteCount;
    IBOutlet UILabel * _deadline;
    IBOutlet UILabel * _voteTpye;
    KDUsersURLView * _voteDetail;
}
@property(retain,nonatomic)UILabel * voteCount; 
@property(retain,nonatomic)UILabel * deadline; 
@property(retain,nonatomic)UILabel * voteTpye; 
@property(retain,nonatomic)KDUsersURLView * voteDetail;


@end
