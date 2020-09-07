//
//  KWIWelcomeTrendV.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/9/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIWelcomeTrendV.h"

#import "KDTopic.h"

#import "KWITrendStreamVCtrl.h"

@implementation KWIWelcomeTrendV

@synthesize topic = topic_;

+ (KWIWelcomeTrendV *)viewForTrend:(KDTopic *)topic
{
    return [[[self alloc] initWithTrend:topic] autorelease];
}

- (id)initWithTrend:(KDTopic *)topic
{
    self = [super initWithFrame:CGRectMake(0, 0, 270, 25)];
    if (self) {
        self.topic = topic;
        
        UILabel *nameV = [[[UILabel alloc] initWithFrame:self.bounds] autorelease];
        nameV.textColor = [UIColor colorWithHexString:@"685545"];
        nameV.font = [UIFont systemFontOfSize:14];
        nameV.backgroundColor = [UIColor clearColor];
        nameV.text = topic.name;
        [self addSubview:nameV];
        
        UITapGestureRecognizer *tgr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onTapped:)] autorelease];
        [self addGestureRecognizer:tgr];
    }
    return self;
}

- (void)_onTapped:(UITapGestureRecognizer *)tgr
{
    KWITrendStreamVCtrl *vctrl = [KWITrendStreamVCtrl vctrlWithTopic:self.topic];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWITrendStreamVCtrl.show" object:self userInfo:inf];
}

@end
