//
//  KDVoteView.h
//  kdweibo
//
//  Created by Guohuan Xu on 3/31/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommenMethod.h"
#import "KDVoteTitleView.h"
#import "KDVoteCell.h"

@interface KDVoteView : UIView<UITableViewDelegate,UITableViewDataSource>
{
    KDVoteTitleView * _voteTitleView;
    IBOutlet UITableView * _talbeView;
}
@property(retain,nonatomic)    KDVoteTitleView *voteTitleView;
@property(retain,nonatomic)    UITableView * talbeView;


@end
