//
//  KWIGroupCell.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/5/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIGroupCell.h"

#import <QuartzCore/QuartzCore.h>

#import "UIImageView+WebCache.h"


#import "KDGroup.h"

#import "KDCommonHeader.h"

@interface KWIGroupCell()<KDUnreadListener>
@property(nonatomic,assign)NSInteger unreadCount;
@end

@implementation KWIGroupCell
{
    IBOutlet UIImageView *_iconV;
    IBOutlet UILabel *_nameV;
    IBOutlet UILabel *_metaV;    
    IBOutlet UILabel *_unreadV;
}

@synthesize group = _group;

+ (KWIGroupCell *)cellWithGroup:(KDGroup *)group {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:self.description owner:nil options:nil];
    KWIGroupCell *cell = (KWIGroupCell *)[nib objectAtIndex:0];
    
    return [cell initWithGroup:group];
}

- (id)initWithGroup:(KDGroup *)group {
    self.group = group;
    
    [_iconV setImageWithURL:[NSURL URLWithString:group.profileImageURL]];
    
    _nameV.text = group.name;
    //_metaV.text = [self _buildMetaStr];
    
    _unreadV.layer.cornerRadius = 4;
    
    [group addObserver:self forKeyPath:@"messageCount" options:NSKeyValueObservingOptionNew context:nil];
    [group addObserver:self forKeyPath:@"memberCount" options:NSKeyValueObservingOptionNew context:nil];
    
    KDUnreadManager *manager = [[KDManagerContext globalManagerContext] unreadManager];
    [manager addUnreadListener:self];
    [self unreadManager:manager didChangeUnread:nil];
    return self;
}

- (void)dealloc {
    KDUnreadManager *manager = [[KDManagerContext globalManagerContext] unreadManager];
    [manager removeUnreadListener:self];
    [self.group removeObserver:self forKeyPath:@"messageCount"];
    [self.group removeObserver:self forKeyPath:@"memberCount"];
    
    [_group release];
    [_iconV release];
    [_nameV release];
    [_metaV release];
    [_unreadV release];
    [super dealloc];
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    if (selected) {
//        self.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"groupLiBgOn.png"]] autorelease];
//    } else {
//        self.backgroundView = nil;
//    }
//}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([@"messageCount" isEqualToString:keyPath]||[@"memberCount" isEqualToString:keyPath]) {
        _metaV.text = [self _buildMetaStr];
    } 
}

- (NSString *)_buildMetaStr {

    return [NSString stringWithFormat:@"成员 %d   微博 %d", self.group.memberCount, self.group.messageCount];
}
- (void)unreadManager:(KDUnreadManager *)unreadManager didChangeUnread:(KDUnread *)unread {
    KDUnread *theUnread = unreadManager.unread;
    NSInteger theUnreadCount = [theUnread unreadForGroupId:self.group.groupId];
    if (self.unreadCount == theUnreadCount) {
        return;
    }else {
        self.unreadCount = theUnreadCount;
        [self configUnreadCount:theUnreadCount];
    }
    
}
- (void)configUnreadCount:(NSInteger)count {
     _unreadV.hidden = (0 == count);
    if (100 > count) {
        _unreadV.text = [NSString stringWithFormat:@"%d",count];
    } else {
        _unreadV.text = @"99+";
    }
    [_unreadV sizeToFit];
    CGRect frame = _unreadV.frame;
    frame = CGRectInset(frame, -8, 0);
    frame.origin.x = 210;
    _unreadV.frame = frame;
}


@end
