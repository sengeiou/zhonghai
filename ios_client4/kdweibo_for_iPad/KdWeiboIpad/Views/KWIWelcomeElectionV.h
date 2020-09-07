//
//  KWIWelcomeElectionV.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 8/14/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDVote;

@interface KWIWelcomeElectionV : UIView

@property (retain, nonatomic) KDVote *vote;

+ (KWIWelcomeElectionV *)viewForElection:(KDVote *)vote;

@end
