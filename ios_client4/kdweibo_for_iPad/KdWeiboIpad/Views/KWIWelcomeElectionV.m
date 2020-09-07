//
//  KWIWelcomeElectionV.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 8/14/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIWelcomeElectionV.h"

#import "KDVote.h"

#import "KWIStatusVCtrl.h"

@implementation KWIWelcomeElectionV
{
    IBOutlet UILabel *_nameV;
    IBOutlet UILabel *_infV;
    IBOutlet UIButton *_btn;    
}

@synthesize vote = vote_;

+ (KWIWelcomeElectionV *)viewForElection:(KDVote *)vote
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:self.description owner:nil options:nil];
    KWIWelcomeElectionV *view = (KWIWelcomeElectionV *)[nib objectAtIndex:0];
    
    return [view initWithElection:vote];
}

- (id)initWithElection:(KDVote *)vote
{
    if (self) {
        self.vote = vote;
        _nameV.text = vote.name;
        
        if (vote.isEnded) {
            _infV.text = @"投票已结束，看看大家的选择";
            [_btn setTitle:@"查 看" forState:UIControlStateNormal];
        } else {
            _infV.text = @"投票进行中，看看大家的选择";
        }
    }
    return self;
}

- (void)dealloc {
    KD_RELEASE_SAFELY(vote_);
    [_nameV release];
    [_infV release];
    [_btn release];
    [super dealloc];
}

//- (void)_onViewBtnTapped:(UITapGestureRecognizer *)tgr
//{
//    KWITrendStreamVCtrl *vctrl = [KWITrendStreamVCtrl vctrlWithTrend:self.trend];
//    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWITrendStreamVCtrl.show" object:self userInfo:inf];
//}

- (IBAction)_onViewBtnTapped:(id)sender 
{
   KWIStatusVCtrl *vctrl = [KWIStatusVCtrl vctrlWithStatusId:self.vote.initStatusId];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIStatusVCtrl.show" object:self userInfo:inf];
}

@end
