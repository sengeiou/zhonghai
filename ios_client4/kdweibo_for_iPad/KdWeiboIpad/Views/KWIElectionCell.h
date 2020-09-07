//
//  KWIElectionCell.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/28/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDVote;

@interface KWIElectionCell : UITableViewCell

+ (KWIElectionCell *)cellForElection:(KDVote *)election;

//+ (NSUInteger)heightForElection:(KWElection *)election;

@end
