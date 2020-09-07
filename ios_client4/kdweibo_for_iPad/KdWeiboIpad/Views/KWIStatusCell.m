//
//  KWIStatusCell.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 4/24/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIStatusCell.h"

#import <QuartzCore/QuartzCore.h>

#import "UIImageView+WebCache.h"

#import "NSDate+RelativeTime.h"
#import "UIDevice+KWIExt.h"


#import "KWIStatusContent.h"
#import "KWIPeopleVCtrl.h"
#import "KWIAvatarV.h"
#import "KWIStatusVCtrl.h"
#import "KDStatus.h"
@interface KWIStatusCell ()

@property (retain, nonatomic) IBOutlet UIImageView *avatarV;
@property (retain, nonatomic) IBOutlet UILabel *usernameV;
@property (retain, nonatomic) IBOutlet UIImageView *pollWatermarkV;
@property (retain, nonatomic) IBOutlet UIView *oprtV;
@property (retain, nonatomic) IBOutlet UIImageView *vLineV;
@property (retain, nonatomic) IBOutlet UIImageView *replyCountIco;
@property (retain, nonatomic) IBOutlet UILabel *replyCountV;
@property (retain, nonatomic) IBOutlet UIImageView *repostCntIco;
@property (retain, nonatomic) IBOutlet UILabel *repostCntV;
// inner content placeholder
@property (retain, nonatomic) IBOutlet UIView *inrCtnPh;
@property (retain, nonatomic) KWIStatusContent *inrCtn;
@property (retain, nonatomic) IBOutlet UIView *paperMV;
@property (retain, nonatomic) IBOutlet UIView *papgerEdgeV;

@end

@implementation KWIStatusCell
{
    BOOL _isForCard;
    IBOutlet UIView *_borderTopV;
    IBOutlet UIView *_borderBtmV;
    IBOutlet UIImageView *_cardBorderV;
}

@synthesize inrCtnPh = _inrCtnPh;
@synthesize inrCtn = _inrCtn;
@synthesize paperMV = _paperMV;
@synthesize papgerEdgeV = _papgerEdgeV;
@synthesize vLineV = _vLineV;
@synthesize replyCountIco = _replyCountIco;
@synthesize replyCountV = _replyCountV;
@synthesize repostCntIco = _repostCntIco;
@synthesize repostCntV = _repostCntV;
@synthesize contentV = _contentV;
@synthesize avatarV = _avatarV;
@synthesize usernameV = _usernameV;
@synthesize pollWatermarkV = _pollWatermarkV;
@synthesize oprtV = _oprtV;
@synthesize data = _data;

+ (KWIStatusCell *)cell
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"KWIStatusCell" owner:nil options:nil];
    KWIStatusCell *cell = (KWIStatusCell *)[nib objectAtIndex:0];
    
    [cell setSelected:NO animated:NO];
    
    return cell;
}

+ (KWIStatusCell *)cardCell
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"KWIStatusCell" owner:nil options:nil];
    KWIStatusCell *cell = (KWIStatusCell *)[nib objectAtIndex:0]; 
    
    [cell initForCard];
    
    return cell;
}

- (KWIStatusCell *)initForCard
{
    _isForCard = YES;
    
    _borderTopV.hidden = YES;
    _borderBtmV.hidden = YES;
    _cardBorderV.hidden = NO;
    
    [self setSelected:NO animated:NO];
    
    self.usernameV.font = [UIFont systemFontOfSize:17];
    
    CGRect frame = self.frame;
    frame.size.width = 420;
    self.frame = frame;
    
    return self;
}

- (void)dealloc {
    // [_data removeObserver:self forKeyPath:@"repost_count"];
    [_data removeObserver:self forKeyPath:@"forwardsCount"];
    [_data removeObserver:self forKeyPath:@"commentsCount"];
    [_data release];
    [_contentV release];
    [_avatarV release];
    [_usernameV release];
    [_pollWatermarkV release];
    [_inrCtnPh release];
    [_inrCtn release];
    [_oprtV release];
    [_vLineV release];
    [_replyCountV release];
    [_replyCountIco release];
    [_paperMV release];
    [_papgerEdgeV release];
    [_repostCntIco release];
    [_repostCntV release];
    [_borderTopV release];
    [_borderBtmV release];
    [_cardBorderV release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (_isForCard) {
        // nothing to do
    } else {
        if (selected) {
            static UIColor *sbg;
            if (nil == sbg) {
                UIImage *sbgimg = [UIImage imageNamed:@"mLiBgOn.png"];
                sbg = [[UIColor colorWithPatternImage:sbgimg] retain];
            }
            self.contentV.backgroundColor = sbg;
            if (5 > [UIDevice curSysVer]) {
                self.papgerEdgeV.opaque = YES;
                self.contentV.opaque = NO;
                self.contentV.layer.opaque = NO;
            }
//            self.papgerEdgeV.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mpStatusCellPaperMROn.png"]];        
            if (5 > [UIDevice curSysVer]) {
                self.papgerEdgeV.opaque = NO;
            }
            
        } else {
            //self.contentV.backgroundColor = [UIColor clearColor];
            self.contentV.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mpanelStatusCellBg.png"]];
            
            if (5 > [UIDevice curSysVer]) {
                self.papgerEdgeV.opaque = YES;
                self.contentV.opaque = YES;
                self.contentV.layer.opaque = YES;
            }
//            self.papgerEdgeV.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mpStatusCellPaperMR.png"]];        
            if (5 > [UIDevice curSysVer]) {
                self.papgerEdgeV.opaque = NO;
            }        
        }
    }
}


- (void)updateFowardAndCommontCountDisplay {
    
    if (_data.forwardsCount >0) {
        self.repostCntV.text =[NSString stringWithFormat:@"%d",_data.forwardsCount];
        self.repostCntIco.hidden = NO;
        if (_data.commentsCount >0) {
            self.replyCountV.text =[NSString stringWithFormat:@"%d",_data.commentsCount];
            self.replyCountIco.hidden = NO;
            CGFloat offset = (CGRectGetMaxX(self.repostCntV.frame) - CGRectGetMinX(self.repostCntIco.frame)+2);
            
            self.replyCountV.frame = CGRectOffset(self.repostCntV.frame, -offset, 0);
            self.replyCountIco.frame = CGRectOffset(self.repostCntIco.frame, -offset, 0);
            
        }
    }else {
        if (_data.commentsCount >0) {
            self.replyCountV.text =[NSString stringWithFormat:@"%d",_data.commentsCount];
            self.replyCountIco.hidden = NO;
        }
    }
    
}

- (void)setData:(KDStatus *)data
{
    if (_data == data) {
        return;
    } else {
        if (_data) {
            [_data removeObserver:self forKeyPath:@"forwardsCount"];
            [_data removeObserver:self forKeyPath:@"commentsCount"];
        }
        [_data release];
        _data = [data retain];
        [_data addObserver:self forKeyPath:@"forwardsCount" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
         [_data addObserver:self forKeyPath:@"commentsCount" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
        
        
//        if (_isForCard) {
//            _data.forwardedStatus = nil;
//        }
    }
    
    //[self.avatarV setImageWithURL:[NSURL URLWithString:data.author.profile_image_url]];    
    KWIAvatarV *avatarV = [KWIAvatarV viewForUrl:data.author.thumbnailImageURL size:48];
    avatarV.userInteractionEnabled = YES;
    [avatarV addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePeopleTapped)] autorelease]];
    [avatarV replacePlaceHolder:self.avatarV];
    self.avatarV = nil;
    
    if (_isForCard) {
        CGRect avatarFrm = avatarV.frame;
        avatarFrm.origin.x += 1;
        avatarFrm.origin.y += 1;
        avatarV.frame = avatarFrm;
        
        CGRect nameFrm = self.usernameV.frame;
        nameFrm.origin.x -= 5;
        self.usernameV.frame = nameFrm;
        
        CGRect ctnFrm = self.inrCtnPh.frame;
        ctnFrm.origin.x -= 5;
        self.inrCtnPh.frame = ctnFrm;
    }
    
   // self.usernameV.text = data.author.name;
    self.usernameV.text = data.author.screenName;
    [self.usernameV sizeToFit];
    
    if (_isForCard) {
        self.inrCtn = [KWIStatusContent viewForStatus:data frame:self.inrCtnPh.frame contentFontSize:14];
    } else {
        self.inrCtn = [KWIStatusContent viewForStatus:data frame:self.inrCtnPh.frame];
    }
    
    [self.contentV addSubview:self.inrCtn];
    [self.inrCtnPh removeFromSuperview];
    self.inrCtnPh = nil;    
    //[self updateFowardAndCommontCountDisplay];
    if (_data.extraMessage && [_data.extraMessage isVote]) {
         self.pollWatermarkV.hidden = NO;
    }
    
    CGRect frame = self.frame;
    frame.size.height  = CGRectGetMaxY(self.inrCtn.frame);
    self.frame = frame;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onQuotedStatuesTapped:) name:@"KWIStatusContent.retweetedStatusTapped" object:self.inrCtn];
}

- (void)layoutSubviews {
    [super layoutSubviews];
        CGRect frame = self.frame;
        frame.size.height  = CGRectGetMaxY(self.inrCtn.frame);
        self.frame = frame;
   
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( [@"forwardsCount" isEqualToString:keyPath]||[@"commentsCount" isEqualToString:keyPath]) {
        //[self _updateRepostCount:[change objectForKey:@"new"]];
        [self updateFowardAndCommontCountDisplay];
    }
}

- (void)_updateRepostCount:(NSNumber *)count
{
    if (0 >= count.intValue) {
        return;
    }
    
    self.repostCntV.text = [count stringValue];
    self.repostCntIco.hidden = NO;
    
    CGRect replyCntFrm = self.replyCountV.frame;
    replyCntFrm.origin.x = 393;
    self.replyCountV.frame = replyCntFrm;
    
    CGRect replyIcoFrm = self.replyCountIco.frame;
    replyIcoFrm.origin.x = 371;
    self.replyCountIco.frame = replyIcoFrm;
}
//
//+ (NSString *)makeRepostedText:(KWStatus *)status
//{
//    return [NSString stringWithFormat:@"%@: %@", status.retweeted_status.author.name, status.retweeted_status.text];
//}

/*- (void)drawRect:(CGRect)rect
{
    if ( !self.data ){
        return;
    }
    
    static NSMutableDictionary *sImageCache;
    if (nil == sImageCache) {
        sImageCache = [[NSMutableDictionary dictionary] retain];
    }
    
    UIImage* cached = [sImageCache objectForKey:self.data.id_];
    if (nil == cached)
    {
        CGRect    bounds = self.bounds;
        
        UIGraphicsBeginImageContext(CGSizeMake(bounds.size.width, bounds.size.height));
        
        // DRAW CONTENT HERE        
        cached = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [sImageCache setObject:cached forKey:self.data.id_];
    }
    
    [cached drawAtPoint:CGPointMake(0,0)];
}*/

/*- (void)handlePan:(UIPanGestureRecognizer *)pgr
{
    if (UIGestureRecognizerStateBegan == pgr.state) {
        NSLog(@"meow");
    }
}

- (void)handleSwipeRight:(UISwipeGestureRecognizer *)sgr
{
    [UIView animateWithDuration:0.2 
                          delay:0 
                        options:UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState 
                     animations:^{
                         CGRect frame = self.contentV.frame;
                         frame.origin.x = 50;
                         self.contentV.frame = frame;
                     }
                     completion:nil];
}

- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)sgr
{
    [UIView animateWithDuration:0.2 
                          delay:0 
                        options:UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState 
                     animations:^{
                         CGRect frame = self.contentV.frame;
                         frame.origin.x = 0;
                         self.contentV.frame = frame;
                     }
                     completion:nil];
}*/

- (void)_handleSwipeRight:(UISwipeGestureRecognizer *)sgr
{
    [self showOperations];
}

- (void)_handlePeopleTapped
{
    KWIPeopleVCtrl *vctrl = [KWIPeopleVCtrl vctrlWithUser:self.data.author];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIPeopleVCtrl.show" object:self userInfo:inf];
}

- (void)showOperations
{
    self.oprtV.hidden = NO;
    
    CGRect frame = self.bounds;
    frame.origin.x += self.oprtV.frame.size.width;
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.contentV.frame = frame;
                         self.vLineV.alpha = 0;
                     } 
                     completion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIStatusCell.showOperations" object:self userInfo:nil];
}

- (void)hideOperations
{    
    CGRect frame = self.bounds;
    
    [UIView animateWithDuration:0.2 
                          delay:0
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.contentV.frame = frame;
                         self.vLineV.alpha = 1;
                     } 
                     completion:^(BOOL finished){
                         self.oprtV.hidden = YES;                         
                     }];
}

- (IBAction)_handleReplyBtnTapped:(id)sender 
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWStatus.addComment" 
                                                        object:self 
                                                      userInfo:[NSDictionary dictionaryWithObject:self.data forKey:@"status"]];
}

- (IBAction)_repostBtnTapped:(id)sender 
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWStatus.repost" 
                                                        object:self 
                                                      userInfo:[NSDictionary dictionaryWithObject:self.data forKey:@"status"]];
}

- (void)_onQuotedStatuesTapped:(NSNotification *)note
{
    KWIStatusVCtrl *vctrl = [note.userInfo objectForKey:@"vctrl"];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIStatusVCtrl.show" object:self userInfo:inf]; 
}

@end
