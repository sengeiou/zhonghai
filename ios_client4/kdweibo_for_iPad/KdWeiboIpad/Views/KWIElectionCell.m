//
//  KWIElectionCell.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/28/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIElectionCell.h"

#import "NSDate+RelativeTime.h"
#import "NSError+KWIExt.h"

#import "KWIVoteOptionV.h"
#import "KWIPeopleVCtrl.h"
#import "KDVote.h"
#import "KDUser.h"
#import "KDVoteOption.h"
#import "NSDate+Additions.h"
#import "KDCommonHeader.h"

@interface KWIElectionCell () <DTAttributedTextContentViewDelegate, UIAlertViewDelegate>

@property (retain, nonatomic )KDVote *data;
@property (retain, nonatomic) IBOutlet DTAttributedTextContentView *nameV;
@property (retain, nonatomic) IBOutlet UIView *ctnV;
@property (retain, nonatomic) IBOutlet DTAttributedTextContentView *deadlineV;
@property (retain, nonatomic) NSMutableDictionary *optionId2View;
@property (retain, nonatomic) NSMutableArray *myOptionIds;
@property (retain, nonatomic) NSTimer *votingTimer;
//@property (retain, nonatomic) NSCache *optionBarCache;
 
@end

@implementation KWIElectionCell
{
    IBOutlet UIImageView *_bgV;
    IBOutlet UIImageView *_closedBgV;    
    IBOutlet UIImageView *_closedBannerV;
    IBOutlet UIButton *_submitBtn;
}

@synthesize data = _data;
@synthesize nameV = _nameV;
@synthesize ctnV = _ctnV;
@synthesize deadlineV = _deadlineV;
@synthesize optionId2View = _optionId2View;
@synthesize votingTimer = _votingTimer;
@synthesize myOptionIds = _myOptionIds;

//- (id)initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        ///
//        
//        self.nameV.delegate = self;
//        NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
//        [dnc removeObserver:self];
//        [dnc addObserver:self
//                selector:@selector(_onOptionSelected:)
//                    name:@"KWIVoteOptionV.selected"
//                  object:nil];
//        [dnc addObserver:self
//                selector:@selector(_onOptionDisselected:)
//                    name:@"KWIVoteOptionV.disselected"
//                  object:nil];
//        self.optionId2View = [NSMutableDictionary dictionaryWithCapacity:0];
//    }
//    return self;
//}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.nameV.delegate = self;
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    [dnc removeObserver:self];
    [dnc addObserver:self
    selector:@selector(_onOptionSelected:)
                        name:@"KWIVoteOptionV.selected"
                      object:nil];
    [dnc addObserver:self
                    selector:@selector(_onOptionDisselected:)
                        name:@"KWIVoteOptionV.disselected"
                      object:nil];
    self.optionId2View = [NSMutableDictionary dictionaryWithCapacity:0];
}
+ (KWIElectionCell *)cellForElection:(KDVote *)election
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:self.description owner:nil options:nil];
    KWIElectionCell *cell = (KWIElectionCell *)[nib objectAtIndex:0];
    cell.data = election;
    
    //return [cell initWithElection:election width:(NSUInteger)width];
    return cell;
}

- (KWIVoteOptionV *)voteOptionViewByOption:(KDVoteOption *)option {
    KWIVoteOptionV *view = [self.optionId2View objectForKey:option.optionId];
    if (view == nil) {
        view = [KWIVoteOptionV view];
        [self.ctnV addSubview:view];
        [self.optionId2View setObject:view forKey:option.optionId];
    }
    return view;

}
- (void)setData:(KDVote *)data {
    if (_data == data) {
        return;
    }
    [_data release];
    _data = [data retain];
    
     NSString *nameStr = [NSString stringWithFormat:@"<span style=\"font-family:'STHeitiSC-Light'; font-size:16px; line-height:1.3; color:#333;\"><a style=\"text-decoration:none; color:#198eb6;\" href=\"kwi://people/%@/\">%@</a>: %@ <span style=\"font-size:14px; color:#666;\">%@%@</span></span>", self.data.author.userId,self.data.author.username, self.data.name, self.data.isMultipleSelections?@"(多选)":@"(单选)", self.data.isCurUserParticipant?@"":@" [投票后查看结果]"];
    self.nameV.attributedString = [[[NSAttributedString alloc] initWithHTMLData:[nameStr dataUsingEncoding:NSUTF8StringEncoding] documentAttributes:nil] autorelease];
    
    
    unsigned int voteMinY = CGRectGetMaxY(self.nameV.frame) + 5;
    unsigned int voteMaxY = voteMinY;
    
    CGRect voteFrame = CGRectMake(20, 0, self.ctnV.frame.size.width - 40, 70);
    
    if (_data.isEnded) {
        _closedBgV.hidden = NO;
        _closedBannerV.hidden = NO;
    } else {
        _bgV.hidden = NO;
        if (_data.isOpen) {
            _submitBtn.hidden = NO;
            self.myOptionIds = [NSMutableArray arrayWithCapacity:_data.maxVoteItemCount];
        }else {
            _submitBtn.hidden = YES;
        }
    }
    
    for (KDVoteOption *option in self.data.voteOptions) {
        //voteFrame.origin.y = [KWIVoteOptionV height] * i + voteMinY;
        voteFrame.origin.y = voteMaxY + 5;
        option.vote = self.data;
        KWIVoteOptionV *optionV = [self voteOptionViewByOption:option];
        optionV.data = option;
        optionV.frame = voteFrame;
        
        voteMaxY = CGRectGetMaxY(optionV.frame);
    }
    
    /*self.myOptionIds = [NSMutableArray arrayWithCapacity:election.myOptions.count];
     for (KWOption *option in election.myOptions) {
     KWIVoteOptionV *optionV = [self.optionId2View objectForKey:option.id_];
     [optionV on];
     [self.myOptionIds addObject:option.id_];
     }*/
    
    /*if (NSOrderedDescending == [election.ended compare:[NSDate date]]) {
     NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
     [dnc addObserver:self
     selector:@selector(_onOptionSelected:)
     name:@"KWIVoteOptionV.selected"
     object:nil];
     [dnc addObserver:self
     selector:@selector(_onOptionDisselected:)
     name:@"KWIVoteOptionV.disselected"
     object:nil];
     } else {
     for (KWIVoteOptionV *optionV in self.optionId2View.objectEnumerator) {
     [optionV lock];
     }
     }*/
    
    CGRect deadlineFrm = self.deadlineV.frame;
    deadlineFrm.origin.y = voteMaxY + 5;
    self.deadlineV.frame = deadlineFrm;
    //    NSDateFormatter *fmt = [[[NSDateFormatter alloc] init] autorelease];
    //    fmt.dateFormat = @"YYYY/MM/dd HH:mm";
    NSString *participantInfStr = (self.data.participantCount >0)?[NSString stringWithFormat:@"共有%d人参与", self.data.participantCount]:@"还没有人投票";
    NSString *deadlineStr = [NSString stringWithFormat:@"<div style=\"font-family:'STHeitiSC-Light'; font-size:12px; color:#666; line-height:1.3;\">%@<br />截止时间：<span style=\"font-family:Helvetica\">%@</span></div>", participantInfStr, [NSDate formatMonthOrDaySince1970:self.data.closedTime]];
    self.deadlineV.attributedString = [[[NSAttributedString alloc] initWithHTMLData:[deadlineStr dataUsingEncoding:NSUTF8StringEncoding] documentAttributes:nil] autorelease];
    //deadlineFrm.size = [self.deadlineV suggestedFrameSizeToFitEntireStringConstraintedToWidth:CGRectGetWidth(self.deadlineV.frame)];
    //self.deadlineV.frame = deadlineFrm;
    //[self.deadlineV sizeToFit];
    
    CGRect ctnFrm = self.ctnV.frame;
    ctnFrm.size.height = CGRectGetMaxY(self.deadlineV.frame) + 15;
    self.ctnV.frame = ctnFrm;
    
    CGRect frame = self.frame;
    frame.size.height = CGRectGetMaxY(self.ctnV.frame);
    self.frame = frame;


    
}
//- (KWIVoteOptionV *)optionBarByOption:(KDVoteOption *)option {
//    KWIVoteOptionV *bar =[self.optionBarCache objectForKey:option.optionId];
//    if (bar == nil) {
//        static int i = 0;
//        CGRect voteFrame = CGRectMake(20, 0, self.ctnV.frame.size.width - 40, 62);
//        voteFrame.origin.y = voteMaxY + 5;
//        option.vote = self.data;
//        KWIVoteOptionV *optionV = [KWIVoteOptionV viewForOption:option frame:voteFrame];
//        [self.ctnV addSubview:optionV];
//        [self.optionId2View setObject:optionV forKey:option.optionId];
//        i++;
//        voteMaxY = CGRectGetMaxY(optionV.frame);
//    }
//    
//}

//- (NSCache *)optionBarCache {
//    if(optionBarCache_ == nil) {
//        optionBarCache_ = [[NSCache alloc] init];
//        optionBarCache_.name = @"optionBar";
//        optionBarCache_.totalCostLimit = 20;
//    }
//    return optionBarCache_;
//}
/*+ (NSUInteger)heightForElection:(KWElection *)election
{
    return [KWIVoteOptionV height] * election.options.count + 110;
}*/

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_nameV release];
    [_ctnV release];
    [_deadlineV release];
    
    [_data release];
    [_optionId2View release];
    [_myOptionIds release];
    [_votingTimer release];
    
    [_closedBgV release];
    [_bgV release];
    [_closedBannerV release];
    [_submitBtn release];
    //KD_RELEASE_SAFELY(optionBarCache_);
    [super dealloc];
}

- (void)_onOptionSelected:(NSNotification *)note {
    if (NSNotFound == [self.optionId2View.allValues indexOfObject:note.object]) {
        return;
    }
    
    KDVoteOption *option = [note.userInfo objectForKey:@"option"];
    
    if (![self.data isMultipleSelections]) {
        /*KWOption *oldOption = [self.data.myOptions lastObject];
        if (oldOption) {
            KWIVoteOptionV *oldOptionV = [self.optionId2View objectForKey:oldOption.id_];
            [oldOptionV off];
        }*/
        // there only one element in self.myOptionIds when 1 == self.data.maxSelection
        // but use for...in make no need to check if self.myOptionIds is empty
        for (NSString *oldOptionId in self.myOptionIds) {
            if ([oldOptionId isEqualToString:option.optionId]) {
                return;
            }
            
            KWIVoteOptionV *oldOptionV = [self.optionId2View objectForKey:oldOptionId];
            [oldOptionV off];
        }
        
        self.myOptionIds = [NSMutableArray arrayWithObject:option.optionId];
              
    } else {
        if (self.myOptionIds.count >= self.data.maxVoteItemCount) {
            return;
        }
        
        if (NSNotFound != [self.myOptionIds indexOfObject:option.optionId]) {
            return;
        }
        
        /* not necessary to do this check?
        for (NSString *existing in self.myOptions) {
            if ([existing isEqualToString:option.id_]) {
                return;
            }
        }*/
        
        [self.myOptionIds addObject:option.optionId];
    }
    
    //KWIVoteOptionV *newOptionV = [self.optionId2View objectForKey:option.id_];
    //[newOptionV on];  
    
    _submitBtn.enabled = (0 < self.myOptionIds.count);
    //[self _postOptions];
}

- (void)_onOptionDisselected:(NSNotification *)note
{
    if (NSNotFound == [self.optionId2View.allValues indexOfObject:note.object]) {
        return;
    }
    
    KDVoteOption *option = [note.userInfo objectForKey:@"option"];
    
    // avoid disselecting the last option, or api will response in error
    /*if (1 == self.myOptionIds.count) {
        return;
    }*/
    
    for (NSString *existing in self.myOptionIds) {
        if ([existing isEqualToString:option.optionId]) {
            //KWIVoteOptionV *optionV = [self.optionId2View objectForKey:option.id_];
            //[optionV off];
            
            [self.myOptionIds removeObject:existing];
            //[self _postOptions];
            break;
        }
    }
    
    _submitBtn.enabled = (0 < self.myOptionIds.count);
}

- (IBAction)_onSubmitBtnTapped:(id)sender 
{
    [self _postOptions];
}

/*- (void)_postOptions
{
    // delay seconds
    [self.votingTimer invalidate];
    self.votingTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                        target:self
                                                      selector:@selector(_postOptionsInternal)
                                                      userInfo:nil
                                                       repeats:NO];
}*/

- (void)_postOptions
{
    /*for (KWIVoteOptionV *optionV in self.optionId2View.objectEnumerator) {
        [optionV lock];
    }*/
    
//    KWEngine *api = [KWEngine sharedEngine];
//    [api post:@"vote/vote.json" 
//       params:[NSDictionary dictionaryWithObjectsAndKeys:self.data.id_, @"id", [self.myOptionIds componentsJoinedByString:@","], @"optionIds", nil] 
//    onSuccess:^(NSDictionary *dict) {
//        self.data = [KWElection electionFromDict:dict];
//        
//        // update percent bar for every option
//        for (KWOption *option in self.data.options) {
//            KWIVoteOptionV *optionV = [self.optionId2View objectForKey:option.id_];
//            optionV.data = option;
//            [optionV setNeedsDisplay];
//            
//            /*BOOL shouldTurnOn = NO;
//            for (NSString *existing in self.myOptions) {
//                if ([existing isEqualToString:optionV.data.id_]) {
//                    shouldTurnOn = YES;
//                    break;
//                }
//            }
//            
//            if (shouldTurnOn) {
//                [optionV on];
//            } else {
//                [optionV off];
//            }*/
//            
//            //[optionV unlock];
//            _submitBtn.hidden = YES;
//        }
//        
//        // I want to close block ASAP
//        [self performSelector:@selector(_attemptIfShare) withObject:nil afterDelay:0];
//    } 
//      onError:^(NSError *error) {
//          //NSLog(@"%@", error);
//          [error KWIGeneralProcess];
//          
//          for (KWIVoteOptionV *optionV in self.optionId2View.objectEnumerator) {
//              //[optionV unlock];
//          }
//      }];
    
    
    NSString *optionIds = [self.myOptionIds componentsJoinedByString:@","];
    
    KDQuery *query = [KDQuery query];
    [[query setParameter:@"id" stringValue:self.data.voteId]
     setParameter:@"optionIds" stringValue:optionIds];
    
    __block KWIElectionCell *cell = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if ([(NSNumber *)results boolValue]) {
//                vvc -> isVotedGetVoteResult_ = YES;
//                
//                [vvc getVoteInfo];
                [cell getVoteInfo];
            }
            
        } else {
            if (![response isCancelled]) {
                if (404 == [response statusCode]) {
                    [cell voteHadBeenDelectAction];
                    
                } else {
//                    UIAlertView *alterViewe = [[UIAlertView alloc] initWithTitle:nil
//                                                                         message:@"噢，出了点问题，投票不成功，稍后再试一下吧"
//                                                                        delegate:vvc cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                    [alterViewe show];
//                    [alterViewe release];
                }
            }
        }
        
        
        // release current view controller
        [cell release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/vote/:vote" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)getVoteInfo {
    KDQuery *query = [KDQuery queryWithName:@"id" value:self.data.voteId];
    [query setProperty:self.data.voteId forKey:@"voteId"];
    
    __block KWIElectionCell *cell = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if([response isValidResponse]) {
            if (results != nil) {
                NSDictionary *info = results;
                KDVote *vote = [info objectForKey:@"vote"];
                int code = [info intForKey:@"code"];
                
                if (code == 500) {
                    [cell voteHadBeenDelectAction];
                    
                } else {
                    cell.data = vote;
                    [self performSelector:@selector(_attemptIfShare) withObject:nil afterDelay:0];
                    
                    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb) {
                        id<KDVoteDAO> voteDAO = [[KDWeiboDAOManager globalWeiboDAOManager] voteDAO];
                        [voteDAO saveVote:vote database:fmdb];
                        
                        return nil;
                        
                    } completionBlock:nil];
                }
            }
            
        } else {
            if (![response isCancelled]) {
                if (404 == [response statusCode]) {
                   [cell voteHadBeenDelectAction];
                    
                } else {
//                    [KDErrorDisplayView showErrorMessage:[response.responseDiagnosis networkErrorMessage]
//                                                  inView:vvc.view.window];
                }
            }
        }
        
        
        // release current view controller
        [cell release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/vote/:resultById" query:query
                                 configBlock:nil completionBlock:completionBlock];
    
}

-  (void)postVoteDeleteNofication {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIElectionCell.voteDeleted" object:self userInfo:@{@"vote":self.data}];
}
- (void)voteHadBeenDelectAction {
    self.data.state = KDVoteStateDeleted;
    [self postVoteDeleteNofication];
    // update the state of vote
    [KDDatabaseHelper asyncInDatabase:(id)^(FMDatabase *fmdb) {
        id<KDVoteDAO> voteDAO = [[KDWeiboDAOManager globalWeiboDAOManager] voteDAO];
        [voteDAO saveVote:self.data database:fmdb];
        
        return nil;
        
    } completionBlock:nil];
}
- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)frame
{
    DTLinkButton *button = [[[DTLinkButton alloc] initWithFrame:frame] autorelease];
	button.URL = url;
	button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
	button.GUID = identifier;
    
	// use normal push action for opening URL
	[button addTarget:self action:@selector(_linkBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    
	return button;
}

- (void)_linkBtnTapped:(DTLinkButton *)button
{
    NSURL *url = button.URL;
    if ([url.scheme isEqualToString:@"kwi"] && [@"people" isEqualToString:url.host]) {
        KDUser *user = self.data.author;
        KWIPeopleVCtrl *vctrl = [KWIPeopleVCtrl vctrlWithUser:user];
        NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIPeopleVCtrl.show" object:self userInfo:inf];
    } 
}

- (void)_attemptIfShare{
    UIAlertView *shareAlert = [[[UIAlertView alloc] initWithTitle:@"投票成功"
                                                         message:@"是否分享投票结果?"
                                                        delegate:self
                                               cancelButtonTitle:@"不，谢谢"
                                               otherButtonTitles:@"分享", nil] autorelease];
    [shareAlert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {

    if (1 != buttonIndex) {
        return;
    }

    KDQuery *query = [KDQuery queryWithName:@"id" value:self.data.voteId];
    
    __block KWIElectionCell *cell = [self retain];
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if ([(NSNumber *)results boolValue]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIPostVCtrl.newStatus" object:nil];
        }
        
        [cell release];
    };
    
    [KDServiceActionInvoker invokeWithSender:nil actionPath:@"/vote/:share" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

@end
