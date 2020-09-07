//
//  KDDMChatInputView.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-2.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDDMChatInputView.h"

#import "KDProgressActionView.h"
#import "KDDefaultViewControllerContext.h"

#import "KDUtility.h"
#import "NSString+Additions.h"
#import "TwitterText.h"
#import "KDAudioController.h"

#import <QuartzCore/QuartzCore.h>
#import "UIView+Blur.h"


@interface KDDMChatInputLeftView : UIView {
@private
    UIButton *audioRecordButton_;
}
@property(nonatomic, retain) UIButton *audioRecordButton;

@end


@implementation KDDMChatInputLeftView

@synthesize audioRecordButton = audioRecordButton_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        audioRecordButton_ = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
        audioRecordButton_.clipsToBounds = YES;
        
        [self addSubview:audioRecordButton_];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGSize imageSize = audioRecordButton_.bounds.size;
    
    audioRecordButton_.frame = CGRectMake((CGRectGetWidth(self.bounds) - imageSize.width) / 2.f - 5.f, (CGRectGetHeight(self.bounds) - imageSize.height) / 2.f, imageSize.width, imageSize.height);
}

- (void)setAudioRecordMode:(BOOL)isRecord {
    if(isRecord) {
        [audioRecordButton_ setImage:[UIImage imageNamed:@"dm_keyboard_normal_v3"] forState:UIControlStateNormal];
        [audioRecordButton_ setImage:nil forState:UIControlStateHighlighted];
    }else {
        [audioRecordButton_ setImage:[UIImage imageNamed:@"dm_record_normal_v3"] forState:UIControlStateNormal];
        [audioRecordButton_ setImage:[UIImage imageNamed:@"dm_record_hl_v3"] forState:UIControlStateHighlighted];
    }
    [audioRecordButton_ sizeToFit];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(audioRecordButton_);
    //[super dealloc];
}

@end



//////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDDMChatInputView class

@interface KDDMChatInputView () <HPGrowingTextViewDelegate>

@property(nonatomic, retain) UIButton *recordBtn;
@property(nonatomic, retain) UIView   *recordBgView;
@property(nonatomic, retain) UIButton *pickerBtn;
@property(nonatomic, retain) UILabel  *wordLimitsLabel;
@property(nonatomic, retain) UIButton *expressionBtn;
@property(nonatomic, retain) UIActivityIndicatorView *activityView;

@property(nonatomic, retain) KDDMChatInputExtendView *extendView;
@property(nonatomic, retain) KDProgressActionView *progressActionView;
@property(nonatomic, retain) UIView *maskView;

@end

@implementation KDDMChatInputView

@dynamic delegate;

@synthesize hostViewController = hostViewController_;
@synthesize pickedImage = pickedImage_;

@synthesize recordBtn = recordBtn_;
@synthesize pickerBtn = pickerBtn_;
@synthesize wordLimitsLabel = wordLimitsLabel_;
@synthesize expressionBtn = expressionBtn_;
@synthesize activityView = activityView_;

@synthesize extendView = extendView_;
@synthesize progressActionView = progressActionView_;
@synthesize maskView = maskView_;
@synthesize inputImplView = inputImplView_;
- (void)setupDMChatInputView {

    self.backgroundColor = [UIColor kdBackgroundColor2];
    
    CGRect rect = CGRectMake(0.0, 0.0, 40, KD_DM_CHAT_INPUT_VIEW_HEIGHT);
    if (type_ == KDInputViewTypeDM) {
     
        // left view
        KDDMChatInputLeftView *leftView = [[KDDMChatInputLeftView alloc] initWithFrame:rect];
        [leftView.audioRecordButton addTarget:self action:@selector(audioRecordSwitch:) forControlEvents:UIControlEventTouchUpInside];
        [leftView setAudioRecordMode:NO];
        
        self.leftView = leftView;
//        [leftView release];

    }
    
    inputImplView_ = [[KDDefaultInputCenterView alloc] initWithFrame:CGRectZero];
    textView_ = inputImplView_.textView;
    
    inputImplView_.textView.growingDelegate = self;
    inputImplView_.backgroundColor = [UIColor clearColor];
    
    inputImplView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    [super.centerView addSubview:inputImplView_];
    //[inputImplView release];
    // right view
    rect = CGRectMake(0.0, 0.0, 75, KD_DM_CHAT_INPUT_VIEW_HEIGHT);
    UIView *rightView = [[UIView alloc] initWithFrame:rect];
    
    // word limits label
    rect = CGRectMake(CGRectGetWidth(rightView.bounds) - 40.f - 5.f, 2.0, 40.0, 24.0);
    wordLimitsLabel_ = [[UILabel alloc] initWithFrame:rect];
    wordLimitsLabel_.backgroundColor = [UIColor clearColor];
    wordLimitsLabel_.font = [UIFont systemFontOfSize:13.0];
    wordLimitsLabel_.textColor = [UIColor redColor];
    wordLimitsLabel_.textAlignment = NSTextAlignmentLeft;
    
    wordLimitsLabel_.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [rightView addSubview:wordLimitsLabel_];
    
    // send button
    UIImage *image = [UIImage imageNamed:@"dm_expression_normal_v3"];
    expressionBtn_ = [UIButton buttonWithType:UIButtonTypeCustom] ;//retain];
    expressionBtn_.frame = CGRectMake(10.0f,
                                (rightView.bounds.size.height - image.size.height) * 0.5,
                                image.size.width, image.size.height);
    
    [expressionBtn_ setImage:image forState:UIControlStateNormal];
     [expressionBtn_ setImage:[UIImage imageNamed:@"dm_expression_hl_v3"] forState:UIControlStateHighlighted];
    
    expressionBtn_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [expressionBtn_ addTarget:self action:@selector(switchExpressionView) forControlEvents:UIControlEventTouchUpInside];
    
    [rightView addSubview:expressionBtn_];
    
    pickerBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
    UIImage *pickerImage = [UIImage imageNamed:@"dm_more_normal_v3"];
    [pickerBtn_ setImage:pickerImage forState:UIControlStateNormal];
    [pickerBtn_ setImage:[UIImage imageNamed:@"dm_more_hl_v3"] forState:UIControlStateHighlighted];
    [pickerBtn_ addTarget:self action:@selector(switchFunctionView) forControlEvents:UIControlEventTouchUpInside];
    pickerBtn_.frame = CGRectMake(CGRectGetMaxX(expressionBtn_.frame) + 10.0f, expressionBtn_.frame.origin.y, pickerImage.size.width, pickerImage.size.height);
    pickerBtn_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [rightView addSubview:pickerBtn_];
    
    // activity view
    activityView_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView_.hidden = YES;
    rect = activityView_.bounds;
    rect.origin = CGPointMake(rightView.bounds.size.width - rect.size.width - 10.0, (rightView.bounds.size.height - rect.size.height) * 0.5);
    
    activityView_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    activityView_.frame = rect;
    
    [rightView addSubview:activityView_];
    
    super.rightView = rightView;
//    [rightView release];
    
    // mask view
    maskView_ = [[UIView alloc] initWithFrame:CGRectZero];
    maskView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    // tap gesture recognizer
    UITapGestureRecognizer *tapGesureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnMaskView:)];
    tapGesureRecognizer.delegate = self;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnMaskView:)];
    panGestureRecognizer.delegate = self;
    
    [maskView_ addGestureRecognizer:tapGesureRecognizer];
//    [tapGesureRecognizer release];
    [maskView_ addGestureRecognizer:panGestureRecognizer];
//    [panGestureRecognizer release];
    
    // swipe gesture recognizer
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_didSwipeOnMaskView:)];
    swipe.direction = UISwipeGestureRecognizerDirectionUp|UISwipeGestureRecognizerDirectionDown;
    
    [maskView_ addGestureRecognizer:swipe];
//    [swipe release];
    
    
    if (type_ == KDInputViewTypeDM) {
        
        // extend view
        extendView_ = [[KDDMChatInputExtendView alloc] initWithFrame:CGRectZero];
        extendView_.alpha = 0.0;
        extendView_.textLabel.text = NSLocalizedString(@"DM_SNED_MESSAGE_WITH_EMAIL", @"");
        [extendView_ renderLayerWithView:self withBorder:KDBorderPositionTop];
        [self.contentView addSubview:extendView_];
        
        recordBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
        [self setRecordBtnImage:NO];
        [recordBtn_ setTitle:NSLocalizedString(@"DM_PRESS_TO_RECORD", @"") forState:UIControlStateNormal];
        [recordBtn_ setTitleColor:RGBCOLOR(95.f, 95.f, 95.f) forState:UIControlStateNormal];
        [recordBtn_ addTarget:self action:@selector(recordTouchDown:) forControlEvents:UIControlEventTouchDown];
        [recordBtn_ addTarget:self action:@selector(recordTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        
        [recordBtn_ addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:NULL];
        [recordBtn_ addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:NULL];
        recordBtn_.enabled = [[KDAudioController sharedInstance] canRecordNow];
        
        recordBtn_.hidden = YES;
        
        [self addSubview:recordBtn_];
        
//        [self switchFirstPromptViewIfNeed];
    }
    
    [[KDAudioController sharedInstance] addObserver:self forKeyPath:@"canRecordNow" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (void)setRecordBtnImage:(BOOL)isSelected {
    UIImage *img = nil;
    if(!isSelected) {
        img = [UIImage imageNamed:@"dm_record_btn_v3"];
        img = [img stretchableImageWithLeftCapWidth:img.size.width * 0.5f topCapHeight:img.size.height * 0.5f];
        [recordBtn_ setBackgroundImage:img forState:UIControlStateNormal];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if(object == recordBtn_) {
        if([keyPath isEqualToString:@"selected"]) {
            BOOL isSelected = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
            [self setRecordBtnImage:isSelected];
            if(isSelected) {
                [recordBtn_ setTitle:NSLocalizedString(@"DM_RELEASE_TO_END", @"") forState:UIControlStateNormal];
            }else {
                [recordBtn_ setTitle:NSLocalizedString(@"DM_PRESS_TO_RECORD", @"") forState:UIControlStateNormal];
            }
        }else if([keyPath isEqualToString:@"hidden"]) {
            BOOL isHidden = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
            textView_.hidden = !isHidden;
        }
    }else if([keyPath isEqualToString:@"canRecordNow"]) {
        BOOL canRecordNow = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        recordBtn_.enabled = canRecordNow;
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)switchFirstPromptViewIfNeed {
    if(firstPromptView_.superview != nil) {
        //已经显示了，现在需要移除;
        [firstPromptView_ removeFromSuperview];
        //KD_RELEASE_SAFELY(firstPromptView_);
    }else {
        //未显示，判断是否需要显示;
        //BOOL didShown = [[[KDSession globalSession] propertyForKey:@"KDDMConversationFirstPromptViewDidShow"] boolValue];
        BOOL didShown = [[KDSession globalSession] getPropertyForKey:@"KDDMConversationFirstPromptViewDidShow" fromMemoryCache:YES];
        if(!didShown) {
            [[KDSession globalSession] saveProperty:@(YES) forKey:@"KDDMConversationFirstPromptViewDidShow" storeToMemoryCache:YES];
            [self setupFirstPromptView];
            [self addSubview:firstPromptView_];
        }
    }
}

- (void)setupFirstPromptView {
    if(!firstPromptView_) {
        firstPromptView_ = [[UIView alloc] initWithFrame:CGRectMake(5.0f, - 60.0f, 300.0f, 60.0f)];
        [firstPromptView_ setBackgroundColor:[UIColor clearColor]];
        
        //bgimage
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:firstPromptView_.bounds];
        bgImageView.image = [UIImage imageNamed:@"dm_first_in_prompt_view_v2"];
        
        [firstPromptView_ addSubview:bgImageView];
//        [bgImageView release];
        
        //label
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:15.0f];
//        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.text = ASLocalizedString(@"KDDMChatInputView_tips");
        
        [label sizeToFit];
        label.frame = CGRectMake(10.0f, (52 - label.bounds.size.height) * 0.5f, label.bounds.size.width, label.bounds.size.height);
        [firstPromptView_ addSubview:label];
//        [label release];
        
        
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"close_btn_v3.png"];
        [closeBtn setImage:image forState:UIControlStateNormal];
        closeBtn.frame = CGRectMake(firstPromptView_.bounds.size.width - 50.0f, 0.0f, 50.0f, 50.0f);
        [closeBtn addTarget:self action:@selector(switchFirstPromptViewIfNeed) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage *divImage = [UIImage imageNamed:@"seperator_v3.png"];
        divImage = [divImage stretchableImageWithLeftCapWidth:divImage.size.width * 0.5f topCapHeight:divImage.size.height * 0.5f];
        
        UIImageView *divImageView = [[UIImageView alloc] initWithImage:divImage];
        divImageView.frame = CGRectMake(CGRectGetMinX(closeBtn.frame) - 2.0f, 0.0f, 2.0f, 50.0f);
        
        [firstPromptView_ addSubview:divImageView];
//        [divImageView release];
        
        [firstPromptView_ addSubview:closeBtn];
    }
}

- (UIView *)functionView {
    if(!functionView_) {
        functionView_ = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.bounds.size.height, self.bounds.size.width, 103.0f)];
        
        [functionView_ setBackgroundColor:RGBACOLOR(247.f, 247.f, 247.f, 1.0)];
        
        int functuonCount = 0;
        if (type_ == KDInputViewTypeTK)
            functuonCount = 2;
        else if(type_ == KDInputViewTypeDM)
            functuonCount = 3;
        
        NSArray *normalImageNames = @[@"dm_picture_normal_v3", @"dm_take_picture_normal_v3", @"dm_location_normal_v3"];
        NSArray *hlImageNames = @[@"dm_picture_hl_v3", @"dm_take_picture_hl_v3", @"dm_location_hl_v3"];
        NSArray *texts = @[ASLocalizedString(@"KDEvent_Picture"), ASLocalizedString(@"KDDMChatInputView_tak_photo"), ASLocalizedString(@"KDDMChatInputView_location")];
        CGSize  imageSize = [UIImage imageNamed:normalImageNames[0]].size;
        CGFloat padding = (functionView_.bounds.size.width - functuonCount * imageSize.width) / (functuonCount + 1);
        for(NSUInteger index = 0; index < functuonCount; index++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake((index + 1) * padding + index * imageSize.width, 12.5, imageSize.width, imageSize.height);
            [btn setImage:[UIImage imageNamed:normalImageNames[index]] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:hlImageNames[index]] forState:UIControlStateHighlighted];
            
            SEL selector;
            switch (index) {
                case 0:
                    selector = @selector(pickImage:);
                    break;
                case 1:
                    selector = @selector(takePicture:);
                    break;
                case 2:
                    selector = @selector(location:);
                default:
                    break;
            }
            
            [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
            
            UILabel *label = [[UILabel alloc] init];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = RGBCOLOR(95.f, 95.f, 95.f);
            label.text = texts[index];
            label.font = [UIFont systemFontOfSize:14.0f];
            [label sizeToFit];
            label.textAlignment = NSTextAlignmentCenter;
            label.frame = CGRectMake(CGRectGetMinX(btn.frame), CGRectGetMaxY(btn.frame) + 5.0f, btn.frame.size.width, label.bounds.size.height);
            
            [functionView_ addSubview:btn];
            [functionView_ addSubview:label];
//            [label release];
        }
    }
    
    if(functionView_.superview != self) {
        [functionView_ removeFromSuperview];
        [self addSubview:functionView_];
    }
    
    return functionView_;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        hostViewController_ = nil;
        
        previousTextViewContentHeight_ = 0.0;
        keyboardHeight_ = 0.0;
        
        super.orientationEnabled = NO;
    }
     
    return self;
}

- (id)initWithFrame:(CGRect)frame delegate:(id<KDDMChatInputViewDelegate>)delegate hostViewController:(UIViewController *)hostViewController {
    self = [self initWithFrame:frame delegate:delegate hostViewController:hostViewController inputType:KDInputViewTypeDM];
    if (self) {
        
    }
    
    return self;
}
- (id)initWithFrame:(CGRect)frame delegate:(id<KDDMChatInputViewDelegate>)delegate hostViewController:(UIViewController *)hostViewController inputType:(KDInputViewType)type
{
    if (self = [self initWithFrame:frame]) {
        
        self.delegate = delegate;
        type_ = type;
        hostViewController_ = hostViewController;
        
        [self setupDMChatInputView];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutExtendViewFrame];
    
    recordBtn_.frame = CGRectMake(CGRectGetMaxX(self.leftView.frame), (CGRectGetHeight(self.leftView.frame) - 33.f) / 2.f, 186.f, 33.0f);
    
    if(functionView_) {
        functionView_.frame = CGRectMake(0.0f, self.bounds.size.height, self.bounds.size.width, 103);
    }
}



- (void)layoutExtendViewFrame {
    CGRect rect = CGRectMake(0.0, -39.0, super.contentView.bounds.size.width, 39.0);
    extendView_.frame = rect;
}

- (void)layoutFunctionView {
    if(functionView_) {
        functionView_.frame = CGRectMake(0.0f, self.bounds.size.height, self.bounds.size.width, 103);
    }
}

- (void)layoutExpressionView {
    if(expressionInputView_) {
        expressionInputView_.frame = CGRectMake(0.0f, self.bounds.size.height, self.bounds.size.width, 216.0f);
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *v = [super hitTest:point withEvent:event];
    if (v == nil) {
        // Because the extend view bounds is beyond it's parent view.
        // Generally speaking, The subviews can not receive event if these bounds beyond parent view.
        
        CGPoint tp = [extendView_.checkBoxButton convertPoint:point fromView:self];
        if (CGRectContainsPoint(extendView_.checkBoxButton.bounds, tp)) {
            v = extendView_.checkBoxButton;
        }
        
        if(functionView_.hidden == NO) {
            tp = [functionView_ convertPoint:point fromView:self];
            if(CGRectContainsPoint(functionView_.bounds, tp)) {
                v = [functionView_ hitTest:tp withEvent:event];
            }
        }
        
        if(expressionInputView_.hidden == NO) {
            tp = [expressionInputView_ convertPoint:point fromView:self];
            if(CGRectContainsPoint(expressionInputView_.bounds, tp)) {
                v = [expressionInputView_ hitTest:tp withEvent:event];
            }
        }
        
        if(firstPromptView_ && firstPromptView_.superview == self) {
            tp = [firstPromptView_ convertPoint:point fromView:self];
            
            if(CGRectContainsPoint(firstPromptView_.bounds, tp)) {
                v = [firstPromptView_ hitTest:tp withEvent:event];
            }
        }
    }
    
    return v;
}

- (void)setDelegate:(id<KDDMChatInputViewDelegate>)delegate {
    super.delegate = delegate;
}

- (id<KDDMChatInputViewDelegate>)delegate {
    return (id<KDDMChatInputViewDelegate>)super.delegate;
}

- (BOOL)hasAttachments {
    return (pickedImage_ != nil && pickedImage_.cachePath != nil) ? YES : NO;
}

#define KD_PROGRESS_ACTION_MASK_VIEW_TAG   0xc8

- (void)progressActionViewVisible:(BOOL)visible {
    if(visible){
        if(progressActionView_ == nil){
            // mask view
            CGRect rect = hostViewController_.view.bounds;
            UIView *maskView = [[UIView alloc] initWithFrame:rect];
            maskView.tag = KD_PROGRESS_ACTION_MASK_VIEW_TAG;
            
            maskView.backgroundColor = RGBCOLOR(30.0, 30.0, 30.0);
            maskView.alpha = 0.6;
            maskView.exclusiveTouch = YES;
            
            maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            [hostViewController_.view addSubview:maskView];
//            [maskView release];
            
            // progress action view
            rect = CGRectMake((rect.size.width - 240.0)*0.5, (rect.size.height - 120.0)*0.5, 240.0, 110.0);
            progressActionView_ = [[KDProgressActionView alloc] initWithFrame:rect];
            progressActionView_.titleLabel.text = NSLocalizedString(@"DM_SENDING_DIRECT_MESSAGE", @"");
            
            [progressActionView_ activeActivityView:YES];
            [hostViewController_.view addSubview:progressActionView_];
        }
        
    }else {
        UIView *maskView = [hostViewController_.view viewWithTag:KD_PROGRESS_ACTION_MASK_VIEW_TAG];
        if(maskView != nil){
            [maskView removeFromSuperview];
        }
        
        if(progressActionView_ != nil){
            if(progressActionView_.superview != nil){
                [progressActionView_ removeFromSuperview];
            }
            
            //KD_RELEASE_SAFELY(progressActionView_)
        }
    }
}

- (void)setProgress:(float)progress info:(NSString *)info {
    progressActionView_.progressLabel.text = info;
    progressActionView_.progressView.progress = progress;
}

- (void)showProcessIndicatorVisible:(BOOL)visible {
    BOOL hasAttachments = [self hasAttachments];
    if(visible){
        if(hasAttachments) {
            [self progressActionViewVisible:YES];
        }else {
            activityView_.hidden = NO;
            [activityView_ startAnimating];
        }
    }else {
        if(hasAttachments) {
            [self progressActionViewVisible:NO];
            
        }else {
            activityView_.hidden = YES;
            [activityView_ stopAnimating];
        }
    }
}

- (CGFloat)extendViewHeight {
    return (extendView_.alpha > 0.001) ? extendView_.bounds.size.height : 0.0;
}

- (NSString *)text {
    // If only picked a photo, 
    return [textView_ hasText] ? [textView_ text] : NSLocalizedString(@"SHARING_PHOTOS", @"");
}

- (BOOL)hasContent {
   return ([textView_ hasText] || [self hasAttachments]) ? YES : NO;
}

- (BOOL)checkedMail {
    return [extendView_ checked];
}

- (void)setPickedPhoto:(UIImage *)image {
    KDPickedImage *pickedImage = [[KDPickedImage alloc] initWithImage:image];
    pickedImage.delegate = self;
    pickedImage.optimalSize = [KDImageSize imageSize:CGSizeMake(800.0f, 600.0f)];
    
    CGSize thumbnailSize = [[KDUtility defaultUtility] isHighResolutionDevice] ? CGSizeMake(60.0, 48.0) : CGSizeMake(30.0, 24.0);
    pickedImage.thumbnailSize = [KDImageSize imageSize:thumbnailSize];
    
    self.pickedImage = pickedImage;
//    [pickedImage release];
    
    [pickedImage_ optimal];
}

- (void)audioRecordSwitch:(UIButton *)btn {
    recordBtn_.hidden = !recordBtn_.hidden;
    
    if(recordBtn_.hidden) {
        viewFlags_.isExpressionViewShown = 0;
        viewFlags_.isKeyBoardShown = 1;
        viewFlags_.isFunctionViewShown = 0;
        [(KDDMChatInputLeftView *)self.leftView setAudioRecordMode:NO];
    }else {
        viewFlags_.isExpressionViewShown = 0;
        viewFlags_.isKeyBoardShown = 0;
        viewFlags_.isFunctionViewShown = 0;
        [(KDDMChatInputLeftView *)self.leftView setAudioRecordMode:YES];
    }
    
    [self processFrameOfSelf];
}

- (void)switchFunctionView {
    [self functionView];
    
    viewFlags_.isExpressionViewShown = 0;
    if(viewFlags_.isFunctionViewShown == 1){
        viewFlags_.isFunctionViewShown = 0;
        viewFlags_.isKeyBoardShown = 1;
    }else {
        viewFlags_.isFunctionViewShown = 1;
        viewFlags_.isKeyBoardShown = 0;
    }
        
    [self processFrameOfSelf];
}

- (void)pickImage:(id)sender {
    [self showImagePicker:NO];
}

- (void)takePicture:(id)sender {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self showImagePicker:YES];
    }
}

- (void)location:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(presentLocationSelectView:)]) {
        [self.delegate presentLocationSelectView:self];
    }
}

- (void)recordTouchDown:(UIButton *)btn {
    //start recording
    if(self.delegate && [self.delegate respondsToSelector:@selector(dmChatInputViewBeginRecord:)]) {
        [self.delegate dmChatInputViewBeginRecord:self];
    }
}

- (void)recordTouchUp:(UIButton *)btn {
    //stop recording
    if(self.delegate && [self.delegate respondsToSelector:@selector(dmChatInputViewEndRecord:)]) {
        [self.delegate dmChatInputViewEndRecord:self];
    }
}
/**
 *  修改，发送完短邮后，键盘布局保持前一状态
 *  王松 2013-11-21
 */
- (void)send{    
    if((textView_.text != nil && ![textView_.text isEqualToString:@""]) || (self.pickedImage.cachePath && ![self.pickedImage.cachePath isEqualToString:@""])) {
//        viewFlags_.isExpressionViewShown = 0;
//        viewFlags_.isFunctionViewShown = 0;
//        viewFlags_.isKeyBoardShown = 0;
        [self processFrameOfSelf];
    
        if(self.delegate && [self.delegate respondsToSelector:@selector(sendContentsInDMChatInputView:)]) {
            [self.delegate sendContentsInDMChatInputView:self];
        }
    }
}
/**
 *  修改，发送完短邮后，键盘布局保持前一状态
 *  王松 2013-11-21
 */
- (void)reset:(BOOL)needClearText {
    
    if(needClearText) {
        textView_.text = @"";
        caret = textView_.selectedRange;
        previousTextViewContentHeight_ = 0.0;
        [self growingTextViewDidChange:textView_];
    }
    
//    viewFlags_.isKeyBoardShown = 0;
//    viewFlags_.isFunctionViewShown = 0;
//    viewFlags_.isExpressionViewShown = 0;
    [self processFrameOfSelf];
    
    self.pickedImage = nil;
    
    [extendView_ setChecked:NO];
}

- (void)resignFirstResponderIfNeed {
    if ([textView_ isFirstResponder] && [textView_ canResignFirstResponder]) {
        [textView_ resignFirstResponder];
        
        [self didTapOnMaskView:nil];
    }
}

- (BOOL)isFirstResponder {
    return [textView_ isFirstResponder];
}
- (BOOL)isActive
{
    if ([self isFirstResponder] || viewFlags_.isExpressionViewShown || viewFlags_.isFunctionViewShown || viewFlags_.isKeyBoardShown)
        return YES;
    return NO;
}
- (void)addKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)removeKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didTapOnMaskView:(UITapGestureRecognizer *)tapGestureRecognizer {
    viewFlags_.isFunctionViewShown = NO;
    viewFlags_.isExpressionViewShown = NO;
    viewFlags_.isKeyBoardShown = NO;
    
    [self processFrameOfSelf];
}

- (void)_didSwipeOnMaskView:(UISwipeGestureRecognizer *)gestureRecognizer {
    viewFlags_.isFunctionViewShown = 0;
    viewFlags_.isExpressionViewShown = 0;
    viewFlags_.isKeyBoardShown = 0;
    
    [self processFrameOfSelf];
}

- (void)_resignFirstResponderForTextView {
    if([textView_ canResignFirstResponder]){
        [textView_ resignFirstResponder];
    }
}

- (void)showImagePicker:(BOOL)takePhoto {
    if(self.delegate != nil && [super.delegate respondsToSelector:@selector(presentImagePickerForDMChatInputView:takePhoto:)]){
        [self.delegate presentImagePickerForDMChatInputView:self takePhoto:takePhoto];
    }
}

- (void)switchExpressionView {
    if(!expressionInputView_) {
        expressionInputView_ = [[KDExpressionInputView alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height, self.frame.size.width, 216.0f)];
        expressionInputView_.delegate = self;
        [expressionInputView_ setSendButtonShown:YES];
        
        [self addSubview:expressionInputView_];
    }
    
    if(viewFlags_.isExpressionViewShown == 1) {
        viewFlags_.isExpressionViewShown = 0;
        viewFlags_.isKeyBoardShown = 1;
        viewFlags_.isFunctionViewShown = 0;
    }else {
        viewFlags_.isExpressionViewShown = 1;
        viewFlags_.isKeyBoardShown = 0;
        viewFlags_.isFunctionViewShown = 0;
    }
    
    [self processFrameOfSelf];
}

- (void)setExpressionBtnImageType:(BOOL)isKeyBoard {
    if(isKeyBoard) {
        [expressionBtn_ setImage:[UIImage imageNamed:@"dm_keyboard_normal_v3"] forState:UIControlStateNormal];
    }else {
        [expressionBtn_ setImage:[UIImage imageNamed:@"dm_expression_normal_v3"] forState:UIControlStateNormal];
        [expressionBtn_ setImage:[UIImage imageNamed:@"dm_expression_hl_v3"] forState:UIControlStateHighlighted];
    }
}

//////////////////////////////////////////////////////////////////////

- (void)didChangeDMInputViewVisibleHeight {
    if(self.delegate != nil && [super.delegate respondsToSelector:@selector(didChangeDMChatInputViewVisibleHeight:)]){
        [self.delegate didChangeDMChatInputViewVisibleHeight:self];
    }
}

- (void)processFrameOfSelf {
    //3.0版本去掉  王松  2013-12-11
//    if (type_ == KDInputViewTypeDM)
//        [self switchFirstPromptViewIfNeed];
    
    CGRect newFrame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    if(viewFlags_.isKeyBoardShown) {
        [textView_ becomeFirstResponder];
    }else {
        [textView_ resignFirstResponder];
    }
    if(viewFlags_.isFunctionViewShown) {
        newFrame.origin.y = hostViewController_.view.bounds.size.height - functionView_.bounds.size.height - newFrame.size.height;
    }else if(viewFlags_.isKeyBoardShown) {
        newFrame.origin.y = hostViewController_.view.bounds.size.height - keyboardHeight_ - newFrame.size.height;
    }else if(viewFlags_.isExpressionViewShown) {
        newFrame.origin.y = hostViewController_.view.bounds.size.height - expressionInputView_.bounds.size.height - newFrame.size.height;
    }else {
        newFrame.origin.y = hostViewController_.view.bounds.size.height - newFrame.size.height;
    }
    
    [self setExpressionBtnImageType:(viewFlags_.isExpressionViewShown == 1)];
    
    if(viewFlags_.isExpressionViewShown == 1)
        expressionInputView_.hidden = NO;
    else if(viewFlags_.isFunctionViewShown == 1)
        expressionInputView_.hidden = YES;
    
    if(viewFlags_.isFunctionViewShown == 1)
        functionView_.hidden = NO;
    else if(viewFlags_.isExpressionViewShown == 1)
        functionView_.hidden = YES;
    
    if(viewFlags_.isFunctionViewShown | viewFlags_.isExpressionViewShown | viewFlags_.isKeyBoardShown) {
        if(recordBgView_.hidden == NO) {
            recordBgView_.hidden = YES;
            recordBtn_.hidden = YES;
           [(KDDMChatInputLeftView *)self.leftView setAudioRecordMode:NO];
        }
    }
    
    [UIView animateWithDuration:0.25f animations:^(void){
        self.frame = newFrame;
        
        if(viewFlags_.isFunctionViewShown == 1) {
            functionView_.hidden = NO;
        }
        
        if(viewFlags_.isExpressionViewShown == 1) {
            expressionInputView_.hidden = NO;
        }
        
        if(viewFlags_.isKeyBoardShown == 1) {
            extendView_.alpha = 1.0f;
        }else {
            extendView_.alpha = 0.0f;
        }
        
    }completion:^(BOOL finished) {
        if(finished) {
            if(viewFlags_.isFunctionViewShown || viewFlags_.isKeyBoardShown || viewFlags_.isExpressionViewShown) {
                maskView_.frame = hostViewController_.view.bounds;
                if(maskView_.superview != hostViewController_.view) {
                    [hostViewController_.view insertSubview:maskView_ belowSubview:self];
                }
            }else {
                if(maskView_.superview != nil) {
                    [maskView_ removeFromSuperview];
                }
            }
            [self didChangeDMInputViewVisibleHeight];
        }
    }];
}


- (void)keyboardWillShow:(NSNotification *)notification {
    
    [self growingTextViewDidChange:textView_];
    
    NSDictionary *userInfo = [notification userInfo];
    CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    rect = [self convertRect:rect toView:nil];
    
    keyboardHeight_ = rect.size.height;
    
    viewFlags_.isKeyBoardShown = 1;
    viewFlags_.isFunctionViewShown = 0;
    viewFlags_.isExpressionViewShown = 0;
    [self processFrameOfSelf];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    keyboardHeight_ = 0.0f;
}


////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDPickedImageDelegate delegate method

- (void)didFinishOptimalPickedImage:(KDPickedImage *)pickedImage {
    // save image to local file system
    [pickedImage_ store];
    
    // clear original picked image
    pickedImage_.pickedImage = nil;
    
    [self send];
}

//////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UITextView delegate methods

- (BOOL)_deviceVersionLessThaniOS5 {
    static int versionMask = 0x00;
    if (versionMask == 0x00) {
        versionMask |= 0xf0;
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (version < 5.0) {
            versionMask |= 0x0f;
        }
    }
    
    return versionMask == 0xff;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [self send];
        return NO;
    }
    
    if([text isEqualToString:@""]) {
        if(!textView_.text || textView_.text.length == 0 || caret.location == 0) return YES;
        
        caret = textView_.selectedRange;
        
        NSRegularExpression *topicExpression = [NSRegularExpression regularExpressionWithPattern:@"\\[[^\\[\\]]+\\]" options:NSRegularExpressionAnchorsMatchLines error:NULL];
        NSArray *matches = [topicExpression matchesInString:textView_.text options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, textView_.text.length)];
        
        if(caret.location != NSNotFound) {
            for(NSTextCheckingResult *result in matches) {
                NSRange range = result.range;
                if(range.location + range.length == caret.location) {
                    textView_.text = [textView_.text stringByReplacingCharactersInRange:range withString:@""];
                    caret.location = range.location;
                    textView_.selectedRange = caret;
                    return NO;
                }
            }
        
            return YES;
        }else {
            NSTextCheckingResult *lastMatch = [matches lastObject];
            if(lastMatch.range.location + lastMatch.range.length == textView_.text.length) {
                textView_.text = [textView_.text stringByReplacingCharactersInRange:lastMatch.range withString:@""];
                return NO;
            }else {
                textView_.text = [textView_.text substringToIndex:textView_.text.length - 1];
            }
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    caret = textView_.selectedRange;
    
    return YES;
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)textView {
    BOOL hasText = [textView hasText];
    //修正iOS6下文字堆叠问题 王松 2013-12-17
    if (hasText) {
        int length = [TwitterText tweetLength:textView.text];
        
        int limit = KD_MAX_DM_TEXT_LENTH;
        if (type_ == KDInputViewTypeTK)
            limit = 140;
        
        if (CGRectGetHeight(textView.frame) >= 45.f) {
            wordLimitsLabel_.textColor = (length > limit) ? [UIColor redColor] : [UIColor colorWithRed:26/255.f green:133/255.f blue:1.0 alpha:1.0];
        }else {
            wordLimitsLabel_.textColor = [UIColor clearColor];
        }
        
        wordLimitsLabel_.text = [NSString stringWithFormat:@"%d", limit - length];
        
        [self enableReturnKey:(limit - length >= 0 && length > 0)];
        
        if(pickerBtn_.autoresizingMask != UIViewAutoresizingFlexibleTopMargin){
            pickerBtn_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        }
    }else {
        wordLimitsLabel_.text = @"";
        [self enableReturnKey:NO];
    }
}

- (void)resetReturnKeyStatus
{
    if (viewFlags_.isKeyBoardShown) {
        [textView_ becomeFirstResponder];
    }
}

- (void)enableReturnKey:(BOOL)enable
{
   
//    UIView *foundKeyboard = nil;
//    NSArray *windows = [UIApplication sharedApplication].windows;
//    for (UIWindow *window in [windows reverseObjectEnumerator])
//    {
//        for (UIView *possibleKeyboard in [window subviews])
//        {
//            if ([[possibleKeyboard description] hasPrefix:@"<UIPeripheralHostView"]) {
//                possibleKeyboard = [[possibleKeyboard subviews] lastObject];
//            }
//            
//            if ([[possibleKeyboard description] hasPrefix:@"<UIKeyboard"]) {
//                foundKeyboard = possibleKeyboard;
//                goto next;
//            }
//        }
//    }
//    next:
//    if ([foundKeyboard respondsToSelector:@selector(setReturnKeyEnabled:)]) {
//        [foundKeyboard performSelector:@selector(setReturnKeyEnabled:) withObject:enable];
//    }
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        [self send];
        return NO;
    }
    
    if([text isEqualToString:@""]) {
        if(!textView_.text || textView_.text.length == 0 || caret.location == 0) return YES;
        
        caret = textView_.selectedRange;
        
        NSRegularExpression *topicExpression = [NSRegularExpression regularExpressionWithPattern:@"\\[[^\\[\\]]+\\]" options:NSRegularExpressionAnchorsMatchLines error:NULL];
        NSArray *matches = [topicExpression matchesInString:textView_.text options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, textView_.text.length)];
        
        if(caret.location != NSNotFound) {
            for(NSTextCheckingResult *result in matches) {
                NSRange range = result.range;
                if(range.location + range.length == caret.location) {
                    textView_.text = [textView_.text stringByReplacingCharactersInRange:range withString:@""];
                    caret.location = range.location;
                    textView_.selectedRange = caret;
                    return NO;
                }
            }
            
            return YES;
        }else {
            NSTextCheckingResult *lastMatch = [matches lastObject];
            if(lastMatch.range.location + lastMatch.range.length == textView_.text.length) {
                textView_.text = [textView_.text stringByReplacingCharactersInRange:lastMatch.range withString:@""];
                return NO;
            }else {
                textView_.text = [textView_.text substringToIndex:textView_.text.length - 1];
            }
            return NO;
        }
    }
    
    return YES;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height
{
    //修正iOS7 下 复制超长文本时，无法滚动bug 王松 2013-12-27
    if (self.frame.size.height < height && height >= growingTextView.maxHeight && (height - self.frame.size.height) > growingTextView.maxHeight / 6.f) {
        [growingTextView.internalTextView resignFirstResponder];
        [growingTextView.internalTextView becomeFirstResponder];
    }
    CGRect rect = self.frame;
    if (growingTextView.frame.size.height >= growingTextView.maxHeight) {
        rect.size.height = height + 8.0f;
    }else {
        rect.size.height = height + 8.f;
    }
    if (rect.size.height <= 36.f) {
        rect.size.height = KD_DM_CHAT_INPUT_VIEW_HEIGHT;
    }
    
    CGFloat offsetY = (hostViewController_.view.bounds.size.height - keyboardHeight_) - rect.size.height;
    if(viewFlags_.isExpressionViewShown == 1) {
        offsetY -= expressionInputView_.bounds.size.height;
    }
    rect.origin.y = (offsetY > 0.0) ? offsetY : 0.0;
    
    self.frame = rect;
    [self layoutExtendViewFrame];
    [self layoutFunctionView];
    [self layoutExpressionView];

    [self didChangeDMInputViewVisibleHeight];
    [self growingTextViewDidChange:growingTextView];
}

- (BOOL)growingTextViewShouldEndEditing:(HPGrowingTextView *)growingTextView {
    caret = textView_.selectedRange;
    
    return YES;
}

- (BOOL)shouldScrollToResignToFirst:(HPGrowingTextView *)growingTextView
{
    return NO;
}

/////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UIGestureRecognizer delegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint tp = [touch locationInView:touch.view];
    
    if(functionView_) {
        tp = [self convertPoint:tp fromView:touch.view];
        
        if(CGRectContainsPoint(functionView_.frame, tp))
            return NO;
    }
    
    if(extendView_.alpha > 0) {
        tp = [extendView_ convertPoint:tp fromView:touch.view];
        
        // Make the tap gesture recogizer to ignore extend view
        return CGRectContainsPoint(extendView_.bounds, tp) ? NO : YES;
    }
    
    return YES;
}

#pragma mark - KDExpressionInputViewDelegate Methods
- (void)expressionInputView:(KDExpressionInputView *)inputView didTapExpression:(NSString *)expressionCode {
    if(caret.location != NSNotFound) {
        textView_.text = [textView_.text stringByReplacingCharactersInRange:caret withString:expressionCode];
        caret.location = caret.location + expressionCode.length;
    }else {
        textView_.text = [textView_.text stringByAppendingString:expressionCode];
    }
    [self growingTextViewDidChange:textView_];
}

- (void)didTapKeyBoardInExpressionInputView:(KDExpressionInputView *)inputView {
    [self switchExpressionView];
}

- (void)didTapSendInExpressionInputView:(KDExpressionInputView *)inputView {
    [self send];
}

- (void)didTapDeleteInExpressionInputView:(KDExpressionInputView *)inputView {
    if(!textView_.text || textView_.text.length == 0 || caret.location == 0) return;
    
    NSRegularExpression *topicExpression = [NSRegularExpression regularExpressionWithPattern:@"\\[[^\\[\\]]+\\]" options:NSRegularExpressionAnchorsMatchLines error:NULL];
    NSArray *matches = [topicExpression matchesInString:textView_.text options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, textView_.text.length)];
    
    if(caret.location != NSNotFound) {
        for(NSTextCheckingResult *result in matches) {
            NSRange range = result.range;
            if(range.location + range.length == caret.location) {
                textView_.text = [textView_.text stringByReplacingCharactersInRange:range withString:@""];
                caret.location = range.location;
                [self growingTextViewDidChange:textView_];
                return;
            }
        }
        
        textView_.text = [textView_.text stringByReplacingCharactersInRange:NSMakeRange(--caret.location, 1.0f) withString:@""];
        [self growingTextViewDidChange:textView_];
    }else {
        NSTextCheckingResult *lastMatch = [matches lastObject];
        if(lastMatch.range.location + lastMatch.range.length == textView_.text.length) {
            textView_.text = [textView_.text stringByReplacingCharactersInRange:lastMatch.range withString:@""];
            [self growingTextViewDidChange:textView_];
            return;
        }else {
            textView_.text = [textView_.text substringToIndex:textView_.text.length - 1];
            [self growingTextViewDidChange:textView_];
        }
    }
    
    
}

#pragma border delegate

- (CGFloat)borderWidth
{
    return 1.f;
}

- (UIColor *)borderColor
{
    return RGBCOLOR(174.f, 174.f, 174.f);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [recordBtn_ removeObserver:self forKeyPath:@"selected"];
    [recordBtn_ removeObserver:self forKeyPath:@"hidden"];
    [[KDAudioController sharedInstance] removeObserver:self forKeyPath:@"canRecordNow"];
    
    
    hostViewController_ = nil;
    textView_ = nil;
    textView_.delegate = nil;
    //KD_RELEASE_SAFELY(inputImplView_);
    //KD_RELEASE_SAFELY(pickedImage_);
    //KD_RELEASE_SAFELY(recordBtn_);
    //KD_RELEASE_SAFELY(recordBgView_);
    //KD_RELEASE_SAFELY(pickerBtn_);
    //KD_RELEASE_SAFELY(wordLimitsLabel_);
    //KD_RELEASE_SAFELY(expressionBtn_);
    //KD_RELEASE_SAFELY(activityView_);
    //KD_RELEASE_SAFELY(functionView_);
    //KD_RELEASE_SAFELY(firstPromptView_);
    
    //KD_RELEASE_SAFELY(extendView_);
    //KD_RELEASE_SAFELY(progressActionView_);
    //KD_RELEASE_SAFELY(maskView_);
     
    //[super dealloc];
} 

@end
