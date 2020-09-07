//
//  KDStatusHeaderView.m
//  kdweibo
//
//  Created by laijiandong on 12-9-26.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDStatusHeaderView.h"
#import "KDSession.h"
#import "KDManagerContext.h"
@interface KDHeaderViewIndicatorView ()
@property(nonatomic, retain) UIImageView *imageView;
@property(nonatomic, retain) UIImageView *backgroundView;
@property(nonatomic, retain) UILabel *textLabel;
@end
@implementation KDHeaderViewIndicatorView
@synthesize imageView = imageView_;
@synthesize backgroundView=backgroundView_;
@synthesize textLabel=textLabel_;


+(id)indicatorWithText:(NSString *)text imageName:(NSString*)imageName {
    KDHeaderViewIndicatorView *indicator = [[KDHeaderViewIndicatorView alloc] initWithText:text imageName:imageName];
    [indicator sizeToFit];
    return indicator;// autorelease];
}


- (id)initWithText:(NSString *)text imageName:(NSString*)imageName {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        textLabel_.text = text;
        [textLabel_ sizeToFit];
        //imageView_.image = image;
        UIImage *image = [UIImage imageNamed:imageName];
        imageView_.image = image;
        [imageView_ sizeToFit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.bounds;
    frame.origin.x =5;
    frame.origin.y =(frame.size.height-imageView_.frame.size.height)*0.5;
    frame.size = imageView_.frame.size;
    imageView_.frame = frame;
    
    frame.origin.x = CGRectGetMaxX(frame) +5;
    frame.origin.y = (self.bounds.size.height - textLabel_.frame.size.height)*0.5;
    frame.size = textLabel_.frame.size;
    textLabel_.frame = frame;
    backgroundView_.frame = self.bounds;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(textLabel_.frame.size.width + imageView_.frame.size.width+15, MAX(imageView_.frame.size.height, textLabel_.frame.size.height)+6);
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        backgroundView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
        UIImage *image = [UIImage imageNamed:@"status_cell_right_top_indicator_bg"];
        image = [image stretchableImageWithLeftCapWidth:image.size.width *0.5
                                           topCapHeight:image.size.height *0.5];
        backgroundView_.image = image;
        
        backgroundView_.autoresizingMask= UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:backgroundView_];
        
        // image indicator view
        
        imageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
        [backgroundView_ addSubview:imageView_];
        
        // create at label
        textLabel_ = [[UILabel alloc]initWithFrame:CGRectZero];
        textLabel_.backgroundColor = [UIColor clearColor];
        textLabel_.textColor = RGBCOLOR(135, 135, 135);
        textLabel_.font = [UIFont systemFontOfSize:12.0];
        [backgroundView_ addSubview:textLabel_];
    }
    
    return self;
}


-(void)dealloc {
    //KD_RELEASE_SAFELY(backgroundView_);
    //KD_RELEASE_SAFELY(imageView_);
    //KD_RELEASE_SAFELY(textLabel_);
    //[super dealloc];
}
@end




/////////////////////////////////////////////////////
@interface KDStatusHeaderView ()

@property(nonatomic, retain) UILabel *screenNameLabel;
@property(nonatomic, retain) UILabel *sourceLabel;
@property(nonatomic, retain) UILabel *timeLabel;

//@property(nonatomic,retain)KDHeaderViewIndicatorView *manyImagesIndicator;
//@property(nonatomic,retain)KDHeaderViewIndicatorView *imageIndicator;
//@property(nonatomic,retain)KDHeaderViewIndicatorView *documentIndicator;
//@property(nonatomic,retain)KDHeaderViewIndicatorView *voteIndicator;
//
//@property(nonatomic, retain) NSMutableArray *indicatorImageViews;
//@property(nonatomic, retain) NSMutableArray *choosenIndicators;

@end


@implementation KDStatusHeaderView

@synthesize screenNameLabel=screenNameLabel_;
@synthesize sourceLabel = sourceLabel_;
@synthesize timeLabel = timeLabel_;
//@synthesize manyImagesIndicator = manyImagesIndicator_;
//@synthesize imageIndicator = imageIndicator_;
//@synthesize documentIndicator = documentIndicator_;
//@synthesize voteIndicator = voteIndicator_;
//@synthesize indicatorImageViews = indicatorImageViews_;
//@synthesize choosenIndicators = choosenIndicators_;
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupHeaderView];
    }
    
    return self;
}

- (void)setupHeaderView {
    // screen name label
    screenNameLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    screenNameLabel_.backgroundColor = [UIColor clearColor];
    screenNameLabel_.textColor = UIColorFromRGB(0x2e3640);
    screenNameLabel_.font = [UIFont boldSystemFontOfSize:15.0];
    
    [self addSubview:screenNameLabel_];
    
    // source label
    sourceLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    sourceLabel_.backgroundColor = [UIColor clearColor];
    sourceLabel_.textColor = RGBCOLOR(132, 132, 132);
    sourceLabel_.font = [UIFont systemFontOfSize:12.0];
    sourceLabel_.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    [self addSubview:sourceLabel_];
    
    timeLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    timeLabel_.backgroundColor = [UIColor clearColor];
    timeLabel_.textColor = RGBCOLOR(132, 132, 132);
    timeLabel_.font = [UIFont systemFontOfSize:12.0];
    //timeLabel_.lineBreakMode = UILineBreakModeHeadTruncation;
    [self addSubview:timeLabel_];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [screenNameLabel_ sizeToFit];
    CGRect frame = self.bounds;
    frame.size.width = MIN(frame.size.width *0.5, screenNameLabel_.bounds.size.width);
    screenNameLabel_.frame = frame;
//    frame = self.bounds;
    
    CGSize sourceSize = [sourceLabel_.text sizeWithFont:sourceLabel_.font];
    CGSize timeSize = [timeLabel_.text sizeWithFont:timeLabel_.font];
    
    timeLabel_.frame = CGRectMake(self.bounds.size.width - timeSize.width, 0.0f, timeSize.width, 20);
    CGFloat offsetXOfSourceLabel = MAX(CGRectGetMinX(timeLabel_.frame) - 3.0f - sourceSize.width, CGRectGetMaxX(screenNameLabel_.frame) + 3.0f);
    sourceLabel_.frame = CGRectMake(offsetXOfSourceLabel, 0.0f, MIN(CGRectGetMinX(timeLabel_.frame) - offsetXOfSourceLabel - 3.0f, sourceSize.width), 20);
    
//    CGFloat maxRigthOffset = 0;
//    CGRect theFrame;
//    for (UIView *view in indicatorImageViews_) {
//        if ([self.choosenIndicators containsObject:view]) {
//            view.hidden = NO;
//            theFrame = view.frame;
//            theFrame.origin.x = frame.size.width-maxRigthOffset-theFrame.size.width;
//            view.frame = theFrame;
//            maxRigthOffset +=  (theFrame.size.width + 5);
//        }else {
//            view.hidden = YES;
//        }
//    }
}

/*
- (KDHeaderViewIndicatorView *)manyImagesIndicator {
    if (manyImagesIndicator_ == nil) {
        manyImagesIndicator_ = [[KDHeaderViewIndicatorView indicatorWithText:ASLocalizedString(@"KDStatusHeaderView_manyImagesIndicator")imageName:@"phote_icon_s.png"] retain];
        [self.indicatorImageViews addObject:manyImagesIndicator_];
        [self addSubview:manyImagesIndicator_];
        
    }
    return manyImagesIndicator_;
}
- (KDHeaderViewIndicatorView *)imageIndicator {
    if (imageIndicator_ == nil) {
        imageIndicator_ = [[KDHeaderViewIndicatorView indicatorWithText:ASLocalizedString(@"图片")imageName:@"phote_icon.png"] retain];
        [self.indicatorImageViews addObject:imageIndicator_];
        [self addSubview:imageIndicator_];
    }
    return imageIndicator_;
}
- (KDHeaderViewIndicatorView *)documentIndicator {
    if (documentIndicator_ == nil) {
        documentIndicator_ = [[KDHeaderViewIndicatorView indicatorWithText:ASLocalizedString(@"文档")imageName:@"document_icon_v2"] retain];
        [self.indicatorImageViews addObject:documentIndicator_];
        [self addSubview:documentIndicator_];
    }
    return documentIndicator_;
}
- (KDHeaderViewIndicatorView *)voteIndicator {
    if (voteIndicator_ == nil) {
        voteIndicator_ = [[KDHeaderViewIndicatorView indicatorWithText:ASLocalizedString(@"KDStatusHeaderView_voteIndicator")imageName:@"vote_icon_v2"] retain];
        [self.indicatorImageViews addObject:voteIndicator_];
        [self addSubview:voteIndicator_];
    }
    return voteIndicator_;
}
- (NSMutableArray *)indicatorImageViews {
    if (indicatorImageViews_ == nil) {
        indicatorImageViews_ = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return indicatorImageViews_;
}

- (NSMutableArray *)choosenIndicators {
    if (choosenIndicators_ == nil) {
        choosenIndicators_ = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return choosenIndicators_;
}

*/

- (void)updateWithStatus:(KDStatus *)status {
    // screen name label
    NSString *displayName = nil;
    if ([[KDManagerContext globalManagerContext].userManager isCurrentUserId:status.author.userId]) {
        displayName = NSLocalizedString(@"KDMeVC_me", @"");
        
    } else {
        displayName = status.author.screenName;
    }
    
    screenNameLabel_.text = displayName;
    [screenNameLabel_ sizeToFit];
    
    NSString *source = status.source;
    NSString *text = [NSString stringWithFormat:ASLocalizedString(@"Wb_From"), source ? source : @""];
    sourceLabel_.text = text;
    [sourceLabel_ sizeToFit];
    timeLabel_.text =  status.createdAtDateAsString ? status.createdAtDateAsString : @"";
    [timeLabel_ sizeToFit];
    
//    [self.choosenIndicators removeAllObjects];
    
//    if(KDTimelinePresentationPatternImagePreview == [KDSession globalSession].timelinePresentationPattern) {
//        if (status.compositeImageSource||status.forwardedStatus.compositeImageSource) {
//            if ([[status.compositeImageSource imageSources] count] >1||
//                [[status.forwardedStatus.compositeImageSource imageSources] count] >1) {
//                [self.choosenIndicators addObject:[self manyImagesIndicator]];
//            }else {
//                [[self choosenIndicators] addObject:[self imageIndicator]];
//            }
//        }
//        if(status.hasAttachments||status.forwardedStatus.hasAttachments) {
//            [[self choosenIndicators] addObject:[self documentIndicator]];
//        }
//        if (status.extraMessage && status.extraMessage.isVote) {
//            [[self choosenIndicators] addObject:[self voteIndicator]];
//        }
//    }
    [self setNeedsLayout];
}


+ (CGFloat)optimalStatusHeaderHeight {
    return 20.0;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(screenNameLabel_);
    //KD_RELEASE_SAFELY(sourceLabel_);
    //KD_RELEASE_SAFELY(timeLabel_);
//    //KD_RELEASE_SAFELY(manyImagesIndicator_);
//    //KD_RELEASE_SAFELY(imageIndicator_);
//    //KD_RELEASE_SAFELY(documentIndicator_);
//    //KD_RELEASE_SAFELY(voteIndicator_);
//    //KD_RELEASE_SAFELY(choosenIndicators_);
//    //KD_RELEASE_SAFELY(indicatorImageViews_);
    //[super dealloc];
}

@end
