//
//  KWITrendCell.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/3/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWITrendCell.h"

#import <QuartzCore/QuartzCore.h>

#import "UIImageView+WebCache.h"

#import "NSDate+RelativeTime.h"


#import "KWIAvatarV.h"
#import "KDTopic.h"
#import "KDStatus.h"

@implementation KWITrendCell

@synthesize data = _data;

+ (KWITrendCell *)trendCellWithData:(KDTopic *)data
{
    return [[[self alloc] initWithData_:data] autorelease];
}

- (id)initWithData_:(KDTopic *)data
{
    self = [super initWithReuseIdentifier:nil accessoryType:UITableViewCellAccessoryNone];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.data = data;
        KDStatus *status = data.latestStatus;
        
        UILabel *nameV = [[[UILabel alloc] initWithFrame:CGRectMake(20, 10, 1000, 100)] autorelease];
        nameV.font = [UIFont systemFontOfSize:16];
        nameV.textColor = [UIColor blackColor];
        nameV.backgroundColor = [UIColor clearColor];
        nameV.text = [NSString stringWithFormat:@"#%@#", data.truncatedName];
        [nameV sizeToFit];
        [self.contentView addSubview:nameV];
        
        //UIImageView *avatarV = [[[UIImageView alloc] initWithFrame:CGRectMake(20, 40, 40, 40)] autorelease];
        //avatarV.layer.cornerRadius = 4;
        //avatarV.clipsToBounds = YES;
        //[avatarV setImageWithURL:[NSURL URLWithString:status.author.profile_image_url]];
        KWIAvatarV *avatarV = [KWIAvatarV viewForUrl:status.author.profileImageUrl size:40];
        avatarV.frame = CGRectMake(20, 40, 40, 40);
        [self.contentView addSubview:avatarV];
        
        UIImageView *bottomBorder = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"commentCellBorder.png"]] autorelease];
        bottomBorder.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        CGRect borderFrame = bottomBorder.frame;
        borderFrame.origin.x += 1;
        borderFrame.origin.y = self.frame.size.height - 1;
        bottomBorder.frame = borderFrame;
        [self.contentView addSubview:bottomBorder];
        
        UILabel *metaV = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 100)] autorelease];
        metaV.font = [UIFont systemFontOfSize:12];
        metaV.textColor = [UIColor colorWithHexString:@"666"];
        metaV.backgroundColor = [UIColor clearColor];
        metaV.text = [NSString stringWithFormat:@"%@  来自%@", [status createdAtDateAsString], [status source]];
        [metaV sizeToFit];
        CGRect metaFrame = metaV.frame;
        metaFrame.origin.x = self.frame.size.width - 30 - metaFrame.size.width;
        metaFrame.origin.y = self.frame.size.height - 10 - metaFrame.size.height;
        metaV.frame = metaFrame;
        metaV.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addSubview:metaV];
              
        DTAttributedTextContentView *atcv = self.attributedTextContextView;
		if (atcv) {
            atcv.backgroundColor = [UIColor clearColor];  
			atcv.edgeInsets = UIEdgeInsetsMake(32, 75, 30, 15);
		}        
        
        self.HTMLString = [NSString stringWithFormat:@"<p style=\"font-size:14px; line-height:22px\"><strong style=\"color:#000\">%@:</strong>&nbsp;<span style=\"color:#666\">%@</span></p>", status.author.username, status.text];
    }
    return self;
}

@end
