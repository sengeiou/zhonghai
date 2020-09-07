//
//  KWIThreadCell.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/18/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIThreadCell.h"

#import <QuartzCore/QuartzCore.h>

#import "NSDate+RelativeTime.h"
#import "UIDevice+KWIExt.h"


#import "KDDMThread.h"
#import "NSDate+Additions.h"
#import "NSString+Additions.h"
#import "KDCommonHeader.h"
@interface KWIThreadCell ()

@property (retain, nonatomic) IBOutlet UILabel *participantsV;
@property (retain, nonatomic) IBOutlet UITextView *textV;
@property (retain, nonatomic) IBOutlet UILabel *dateV;
@property (retain, nonatomic) IBOutlet UILabel *unreadV;

@end

@implementation KWIThreadCell
{
    IBOutlet UILabel *_participantCount;    
}

@synthesize participantsV = _participantsV;
@synthesize textV = _textV;
@synthesize dateV = _dateV;
@synthesize unreadV = _unreadV;

@synthesize data = _data;



+ (KWIThreadCell *)cell
{
    UIViewController *tmpVCtrl = [[[UIViewController alloc] initWithNibName:@"KWIThreadCell" bundle:nil] autorelease];
    KWIThreadCell *cell = (KWIThreadCell *)tmpVCtrl.view; 
    //
    return cell;
}

- (void)dealloc {
    [_data removeObserver:self forKeyPath:@"unreadCount"];
    KD_RELEASE_SAFELY(_data);
    [_participantsV release];
    [_textV release];    
    
    [_dateV release];
    [_unreadV release];
    [_participantCount release];
    [super dealloc];
}

#pragma mark -
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (selected) {
        static UIColor *sbg;
        if (nil == sbg) {
            NSString *sbgpath = [[NSBundle mainBundle] pathForResource:@"threadCellBg" ofType:@"jpg"];     
            UIImage *sbgimg = [UIImage imageWithContentsOfFile:sbgpath];
            sbg = [[UIColor colorWithPatternImage:sbgimg] retain];
        }
        self.backgroundColor = sbg;
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark -
- (void)setData:(KDDMThread *)data {
    if (_data == data) {
        return;
    }
    
    if (_data) {
        [_data removeObserver:self forKeyPath:@"unreadCount"];
        
        [_data release];
    }
    _data = [data retain];
    [_data addObserver:self forKeyPath:@"unreadCount" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    self.participantsV.text = [_data.subject stringByRemovingDMSubjectPostfix];
    [self.participantsV sizeToFit];
    CGRect pFrm = self.participantsV.frame;
    pFrm.size.width = MIN(pFrm.size.width, self.frame.size.width - 80);
    self.participantsV.frame = pFrm;
    
    _participantCount.text = [NSString stringWithFormat:@"(%d人)", _data.participantsCount];
    CGRect pcFrm = _participantCount.frame;
    pcFrm.origin.x = CGRectGetMaxX(self.participantsV.frame) + 5;
    _participantCount.frame = pcFrm;
    
    self.textV.text = _data.latestDMText;
    //self.textV.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    
    if (5 > [UIDevice curSysVer]) {
        CGRect frame = self.textV.frame;
        frame.size.height -= 6;
        self.textV.frame = frame;
    }
    
    if (40 > self.textV.contentSize.height) {
        [self.textV sizeToFit];
        CGRect frame = self.textV.frame;
        frame.origin.y += 5;
        self.textV.frame = frame;
    }
    
    //self.dateV.text = [data.updated formatRelativeTime];
    self.dateV.text = [NSDate formatMonthOrDaySince1970:_data.updatedAt];
    
    self.unreadV.layer.cornerRadius = 4;

}

/*+ (NSUInteger)calculateHeightWithThread:(KWThread *)thread
{    
    UITextView *tv = [[[UITextView alloc] initWithFrame:CGRectMake(-1000, -1000, 460, 1)] autorelease];
    tv.font = [UIFont systemFontOfSize:16];
    tv.text = thread.lastMessage.text;
    [[[[[UIApplication sharedApplication] keyWindow] rootViewController] view] addSubview:tv];
    
    
    
    return tv.contentSize.height + 65;
}*/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ((object == self.data) && [@"unreadCount" isEqualToString:keyPath]) {
        [self _configUnreadV];
    }
}

- (void)_configUnreadV{
    self.unreadV.hidden = !self.data.unreadCount;
    self.unreadV.text = [NSString stringWithFormat:@"%d", self.data.unreadCount];
}

@end
