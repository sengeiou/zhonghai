//
//  KWIMessageCell.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/18/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDDMMessage;

@interface KWIMessageCell : UITableViewCell

+ (KWIMessageCell *)cell;

+ (NSUInteger)calculateHeightWithMessage:(KDDMMessage *)message lastMessage:(KDDMMessage *)lastMessage;

- (void)setData:(KDDMMessage *)data lastMessage:(KDDMMessage *)lastMessage;

@end
