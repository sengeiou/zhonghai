//
//  KDVoteCell.h
//  kdweibo
//
//  Created by Guohuan Xu on 3/31/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommenMethod.h"

@interface KDVoteCell : UITableViewCell
{
    IBOutlet UIImageView * _selectStatue;
    IBOutlet UILabel *_voteDetail;
    IBOutlet UIImageView * _voteBarBg;
    IBOutlet UIImageView * _voteBar;
    IBOutlet UILabel * _voteCountPesent;
    IBOutlet UIImageView * _voteCountPesentBg;
}
@property(retain,nonatomic)UIImageView * selectStatue;
@property(retain,nonatomic)UILabel *voteDetail;
@property(retain,nonatomic)UIImageView * voteBarBg;
@property(retain,nonatomic)UIImageView * voteBar;
@property(retain,nonatomic)UILabel * voteCountPesent;
@property(retain,nonatomic)UIImageView * voteCountPesentBg;


@end
