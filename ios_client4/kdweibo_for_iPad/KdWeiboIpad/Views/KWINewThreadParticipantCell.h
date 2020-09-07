//
//  KWINewThreadParticipantCell.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/10/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDUser;

@interface KWINewThreadParticipantCell : UITableViewCell

@property (retain, nonatomic) KDUser *user;

+ (KWINewThreadParticipantCell *)cellForUser:(KDUser *)user;

- (void)setFakeSelected;

@end
