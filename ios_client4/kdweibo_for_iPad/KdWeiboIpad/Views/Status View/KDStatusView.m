//
//  KDStatusView.m
//  kdweibo
//
//  Created by Tan yingqi on 10/26/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDStatusView.h"
#import "UIImageView+WebCache.h"
#import "KDDocumentListView.h"

@implementation KDStatusView
//@dynamic layouter;
//@synthesize currentBounds = currentBounds_;
@synthesize userInfo = userInfo_;
- (id)initWithFrame:(CGRect)frame  {
    self =[super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
    
}
- (void)dealloc {
    KD_RELEASE_SAFELY(userInfo_);
    [super dealloc];
    
}
- (void)update{

}

@end

       
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma - mark KDLayouterTextView

@implementation KDLayouterTextView
@synthesize textLabel = textLabel_;
- (id)initWithFrame:(CGRect)frame  {
    self =[super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
        self.textLabel = label;
        [label release];
        textLabel_.backgroundColor = [UIColor clearColor];
        textLabel_.textColor = UIColorFromRGB(0x1c232a);
        textLabel_.numberOfLines = 0;
        textLabel_.lineBreakMode = UILineBreakModeCharacterWrap;
        [self addSubview:textLabel_];
        
    }
    return self;
    
}
- (void)dealloc {
    KD_RELEASE_SAFELY(textLabel_);
    [super dealloc];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    if (layouter_) {
//        KDTextLayouter *textLayouter = (KDTextLayouter *)layouter_;
//        self.frame = textLayouter.frame;
//        self.textLabel.frame= self.bounds;
//       
//    }
  
    
}

@end

#pragma - mark

@implementation KDLayouterCoreTextView
@synthesize textView = textView_;
- (id)init{
    self = [super init];
    if (self) {
        ///
        textView_ = [[DTAttributedTextContentView alloc] initWithFrame:CGRectZero ];
        textView_.backgroundColor = [UIColor clearColor];
        //textView_.numberOfLines = 0;
        textView_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:textView_];
        
    }
    return self;
}

- (void)update {
    if (self.userInfo) {
        NSAttributedString *attrStr = [self.userInfo objectForKey:@"text"];
        textView_.attributedString = attrStr;
            }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.bounds;
    CGSize suggestedSize =  [textView_ suggestedFrameSizeToFitEntireStringConstraintedToWidth:self.bounds.size.width];
    frame.size = suggestedSize;
    textView_.frame = frame;
    //[textView_ sizeToFit];

}
- (void)dealloc {
    KD_RELEASE_SAFELY(textView_);
    [super dealloc];
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma - mark KDLayouterImageView
@implementation KDLayouterImageView
@synthesize imageView = imageView_;
- (id)initWithFrame:(CGRect)frame  {
    self =[super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imageView = imageView;
        [self addSubview:imageView];
        [imageView release];
    }
    return self;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    if (layouter_) {
//        KDImageLayouter *imageLayouter = (KDImageLayouter *)layouter_;
//        self.frame = layouter_.frame;
//        self.imageView.image =[UIImage imageNamed:imageLayouter.imageName];
//        [self.imageView setFrame:self.bounds];
//    }
    
}

- (void)dealloc {
    KD_RELEASE_SAFELY(imageView_);
    [super dealloc];
}
@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma - mark KDStatusFooterAttributeView
@implementation KDStatusFooterAttributeView

@synthesize typeImageView=typeImageView_;
@synthesize textLabel=textLabel_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupFooterAttributeView];
    }
    
    return self;
}

- (void)setupFooterAttributeView {
    // type image view
    typeImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:typeImageView_];
    
    // text label
    textLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    textLabel_.backgroundColor = [UIColor clearColor];
    textLabel_.textColor = UIColorFromRGB(0x5d6772);
    textLabel_.font = [UIFont systemFontOfSize:12.0];
    
    [self addSubview:textLabel_];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = textLabel_.bounds;
    CGFloat offsetX = self.bounds.size.width - rect.size.width;
    CGFloat offsetY = (self.bounds.size.height - rect.size.height) * 0.5;
    rect.origin = CGPointMake(offsetX, offsetY);
    textLabel_.frame = rect;
    
    rect = typeImageView_.bounds;
    rect.origin = CGPointMake(0.0, (self.bounds.size.height - rect.size.height) * 0.5);
    typeImageView_.frame = rect;
}

- (void)setTypeImage:(UIImage *)image {
    typeImageView_.image = image;
    [typeImageView_ sizeToFit];
}

- (void)setText:(NSString *)text {
    textLabel_.text = text;
    [textLabel_ sizeToFit];
}

- (CGSize)optimalDisplaySize {
    CGFloat width = typeImageView_.bounds.size.width + textLabel_.bounds.size.width + 3.0; // spacing is 3.0
    CGFloat height = MAX(typeImageView_.bounds.size.height , textLabel_.bounds.size.height);
    
    return CGSizeMake(width, height);
}

- (void)dealloc {
    
    KD_RELEASE_SAFELY(typeImageView_);
    KD_RELEASE_SAFELY(textLabel_);
    [super dealloc];
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma - mark KDLayouterFooterView
@implementation KDLayouterFooterView
@synthesize sourceLabel = sourceLabel_;
@synthesize commentAttrView = commentAttrView_;
@synthesize forwardAttrView = forwardAttrView_;
@synthesize isUsingNormalCommentsIcon = isUsingNormalCommentsIcon_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isUsingNormalCommentsIcon = YES;
        
        [self setupFooterView];
    }
    
    return self;
}

- (void)setupFooterView {
    // source label
    sourceLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    sourceLabel_.backgroundColor = [UIColor clearColor];
    sourceLabel_.textColor = UIColorFromRGB(0x5d6772);
    sourceLabel_.font = [UIFont systemFontOfSize:12.0];
    
    [self addSubview:sourceLabel_];
    
    // comment attribute view
    commentAttrView_ = [[KDStatusFooterAttributeView alloc] initWithFrame:CGRectZero];
    [commentAttrView_ setTypeImage:[UIImage imageNamed:@"icon_comment.png"]];
    [self addSubview:commentAttrView_];
    
    // forward attribute view
    forwardAttrView_ = [[KDStatusFooterAttributeView alloc] initWithFrame:CGRectZero];
    [forwardAttrView_ setTypeImage:[UIImage imageNamed:@"icon_repost.png"]];
    [self addSubview:forwardAttrView_];
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    if (layouter_) {
//        self.frame = layouter_.frame;
//        
//        CGFloat width =  self.bounds.size.width;
//        CGFloat height = self.bounds.size.height;
//        NSLog(@"width = %f",width);
//        NSLog(@"height = %f",height);
//        CGFloat pw = width * 0.5;
//        
//        CGFloat offsetX = 0.0;
//        CGRect rect = CGRectZero;
//        CGSize size = CGSizeZero;
//        if (!forwardAttrView_.hidden) {
//            size = [forwardAttrView_ optimalDisplaySize];
//            offsetX = width - size.width;
//            rect.origin = CGPointMake(offsetX, (height - size.height) * 0.5);
//            rect.size = size;
//            forwardAttrView_.frame = rect;
//            width = offsetX - 5.0;
//        }
//        
//        if (!commentAttrView_.hidden) {
//            size = [commentAttrView_ optimalDisplaySize];
//            offsetX = width - size.width;
//            rect.origin = CGPointMake(offsetX, (height - size.height) * 0.5);
//            rect.size = size;
//            commentAttrView_.frame = rect;
//        }
//        
//        sourceLabel_.frame = CGRectMake(0.0, 0.0, pw, height);
//        NSLog(@"father = %@",sourceLabel_.superview);
//
//    }
}

- (NSString *)formatAttributeCount:(NSUInteger)count {
    return (count > 10000) ? @"10000+" : [NSString stringWithFormat:@"%d", count];
}

//- (void)setLayouter:(KDLayouter *)layouter {
//    [super setLayouter:layouter];
////    KDFooterLayoutr *footerLayouter = (KDFooterLayoutr *)layouter_;
////    NSString *source = (footerLayouter.isGroup) ? footerLayouter.source : footerLayouter.groupName;
////    sourceLabel_.text = [NSString stringWithFormat:NSLocalizedString(@"FROM_%@", @""), source];
////    
////    // comments count
////    BOOL visible = footerLayouter.commentCount >0;
////    if (visible) {
////        if (footerLayouter.isGroup) {
////            BOOL previous = self.isUsingNormalCommentsIcon;
////            self.isUsingNormalCommentsIcon = !footerLayouter.isUnread;
////            [self updateCommentsAttrView:previous now:isUsingNormalCommentsIcon_];
////        }
////        
////        NSString *commentsText = [self formatAttributeCount:footerLayouter.commentCount];
////        [commentAttrView_ setText:commentsText];
////    }
////    
////    commentAttrView_.hidden = !visible;
////    
////    // forward count
////    visible = footerLayouter.fowardedCount > 0;
////    if (visible) {
////        NSString *forwardsText = [self formatAttributeCount:footerLayouter.fowardedCount];
////        [forwardAttrView_ setText:forwardsText];
////    }
//    
//    //forwardAttrView_.hidden = !visible;
//
//}

#pragma mark - for group status

- (BOOL)isGroupStatus:(KDStatus *)status {
   // return [status isKindOfClass:[GroupStatus class]];
    return NO;
}

- (void)updateCommentsAttrView:(BOOL)prevUsingNormal now:(BOOL)nowUsingNormal {
    if (prevUsingNormal == nowUsingNormal) return;
    
    UIColor *color = nowUsingNormal ? UIColorFromRGB(0x5d6772) : UIColorFromRGB(0xfd7903);
    UIImage *image = [UIImage imageNamed:(nowUsingNormal ? @"icon_comment.png" : @"icon_comment_new.png")];
    
    commentAttrView_.textLabel.textColor = color;
    [commentAttrView_ setTypeImage:image];
}

+ (CGFloat)optimalStatusFooterHeight {
    return 12.0;
}

- (void)dealloc {
    KD_RELEASE_SAFELY(sourceLabel_);
    KD_RELEASE_SAFELY(commentAttrView_);
    KD_RELEASE_SAFELY(forwardAttrView_);
    
    [super dealloc];
}
@end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma - mark KDLayouterHeaderView

@implementation KDLayouterHeaderView
@synthesize screenNameLabel = screenNameLabel_;

- (id)init  {
    self =[super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        screenNameLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
        screenNameLabel_.numberOfLines = 0;
        screenNameLabel_.backgroundColor = [UIColor clearColor];
        screenNameLabel_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:screenNameLabel_];
        
    }
    return self;
    
}

- (void)update {
    if (self.userInfo) {
        NSString *text = [self.userInfo objectForKey:@"text"];
        UIColor *textColor = [self.userInfo objectForKey:@"textColor"];
        UIFont *font = [self.userInfo objectForKey:@"font"];
        id obj = [self.userInfo objectForKey:@"alignment"];
        if (obj) {
            screenNameLabel_.textAlignment = [obj integerValue];
        }
        screenNameLabel_.text = text;
        screenNameLabel_.textColor = textColor;
        screenNameLabel_.font = font;
    }
}

- (void)dealloc {
    KD_RELEASE_SAFELY(screenNameLabel_);
    [super dealloc];
}
@end



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma - mark KDLayouterThumbnailsView

@interface KDLayouterThumbnailsView ()

@property(nonatomic,retain)UIImageView *markImageView;
@end
@implementation KDLayouterThumbnailsView
@synthesize imageView = imageView_;
@synthesize markImageView = markImageView_;

- (id)initWithFrame:(CGRect)frame  {
    self =[super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [imageView setUserInteractionEnabled:YES];
        imageView.clipsToBounds = YES;
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        self.imageView = imageView;
        [imageView release];
        [self addSubview:imageView];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapped:)];
        [imageView  addGestureRecognizer:tapGestureRecognizer];
        [tapGestureRecognizer release];
        
    }
    return self;
    
}

- (void)onTapped:(UIGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
       KDCompositeImageSource * imageSource = [self.userInfo objectForKey:@"imageSource"];
        
         NSDictionary *userInfo = [NSDictionary dictionaryWithObject:imageSource forKey:@"compoisteImageSource"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIShowPhotos" object:nil userInfo:userInfo];
    }
}

- (void)update {
    if (self.userInfo) {
        KDCompositeImageSource * imageSource = [self.userInfo objectForKey:@"imageSource"];
        if (imageSource) {
            NSURL *url = [NSURL URLWithString:[imageSource firstThumbnailURL]];
            [self.imageView setImageWithURL:url];
            if ([imageSource.imageSources count]>1) {
                UIImageView *mark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"havemore.png"]];
                [self addSubview:mark];
                self.markImageView = mark;
            }
        }
       
    }
    
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    if (markImageView_) {
        CGRect frame = markImageView_.frame;
        frame.origin.x = CGRectGetMaxX(self.bounds)+10;
        frame.origin.y = CGRectGetMaxY(self.bounds) - frame.size.height;
        markImageView_.frame = frame;
    }
    
}

- (void)dealloc {
    KD_RELEASE_SAFELY(markImageView_);
    KD_RELEASE_SAFELY(imageView_);
    [super dealloc];
}
@end




//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma - mark KDLayouterExtraStatusView
@implementation KDLayouterExtraStatusView
@synthesize backgroudImageView = backgroudImageView_;
@synthesize accessoryImageView = accessoryImageView_;
@synthesize forwardedTextView = forwardedTextView_;
@synthesize contentTextView = contentTextView_;
@synthesize seperatorView = seperatorView_;
@synthesize thumnailView = thumnailView_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.backgroudImageView = backgroundView;
        [backgroundView release];
        [self addSubview:backgroundView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:imageView];
        self.accessoryImageView = imageView;
        [imageView release];
        
        KDLayouterTextView *contentTextView = [[KDLayouterTextView alloc] initWithFrame:CGRectZero];
        [self addSubview:contentTextView];
        self.contentTextView = contentTextView;
        [contentTextView release];
        
        KDLayouterTextView *fwdTextView = [[KDLayouterTextView alloc] initWithFrame:CGRectZero];
        [self addSubview:fwdTextView];
        self.forwardedTextView = fwdTextView;
        [fwdTextView release];
        
        KDLayouterThumbnailsView *thumbnailsView = [[KDLayouterThumbnailsView alloc] initWithFrame:CGRectZero];
        [self addSubview:thumbnailsView];
        self.thumnailView = thumbnailsView;
        [thumbnailsView release];
    
        KDLayouterImageView *separatorimageView = [[KDLayouterImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:separatorimageView];
        self.seperatorView = separatorimageView;
        [separatorimageView release];
        
    }
    return self;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    if(layouter_) {
//        self.frame = layouter_.frame;
//        self.backgroudImageView.frame = self.bounds;
//        KDExtendStatusLayouter *fatherLayouter = (KDExtendStatusLayouter *)layouter_;
//        UIImage *image = [UIImage imageNamed:fatherLayouter.backgroundImageName];
//        image= [image stretchableImageWithLeftCapWidth:image.size.width *0.5 topCapHeight:image.size.height*0.5];
//        self.backgroudImageView.image = image;
//        self.backgroudImageView.hidden = NO;
//        image = [UIImage imageNamed:fatherLayouter.accessoryImageName];
//        self.accessoryImageView.image = image;
//        self.accessoryImageView.bounds = CGRectMake(0, 0,image.size.width*0.6 , image.size.height*0.6);
//        self.accessoryImageView.hidden = NO;
//        CGRect bounds = self.accessoryImageView.bounds;
//        bounds.origin.x = self.bounds.size.width - bounds.size.width - 1;
//        bounds.origin.y = self.bounds.size.height - bounds.size.height - 1;
//        [self.accessoryImageView setFrame:bounds];
//        NSLog(@"accddsf = %@",NSStringFromCGRect (self.accessoryImageView.frame));
//        
//    }
}

//- (void)setLayouter:(KDLayouter *)layouter {
//    [super setLayouter:layouter];
////    for (KDLayouter *alayouter in layouter_.subLayouters) {
////        if ([alayouter isKindOfClass:[KDTextLayouter class]]) {
////            if (alayouter.tag == 100) {
////                //
////                [self.forwardedTextView setLayouter:alayouter];
////            }else if(alayouter.tag == 200) {
////                [self.contentTextView setLayouter:alayouter];
////            }
////        }
////      
////            // [self.textView setNeedsLayout];
////       else if ([alayouter isKindOfClass:[KDThumbnailsLayouter class]]) {
////            [self.thumnailView setLayouter:alayouter];
////      
////        }else if([alayouter isKindOfClass:[KDImageLayouter class]]) {
////            [self.seperatorView setLayouter:alayouter];
////        }
////    }
//}

//- (void)reset {
//    
//    [super reset];
//    self.backgroudImageView.hidden = YES;
//    self.accessoryImageView.hidden = YES;
//    self.forwardedTextView.hidden = YES;
//    self.contentTextView.hidden = YES;
//    self.seperatorView.hidden = YES;
//    [self.thumnailView reset];
//    
//}

- (void)dealloc {
    
    KD_RELEASE_SAFELY(backgroudImageView_);
    KD_RELEASE_SAFELY(accessoryImageView_);
    KD_RELEASE_SAFELY(forwardedTextView_);
    KD_RELEASE_SAFELY(contentTextView_);
    KD_RELEASE_SAFELY(seperatorView_);
    KD_RELEASE_SAFELY(thumnailView_);
    [super dealloc];
}
@end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma - mark KDLayouterFatherView
@implementation KDLayouterFatherView
@synthesize backgroudImageView = backgroundImageView_;
@synthesize fatherView = fatherView_;
@synthesize headerView = headerView_;
@synthesize textView = textVeiw_;
@synthesize contentView = contentView_;
@synthesize thumnailsView = thumnailsView_;
@synthesize footerView = footerView_;
@synthesize extraStatusView = extraStatusView_;

- (id)initWithFrame:(CGRect)frame  {
    self =[super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        self.backgroudImageView = imageView;
        [imageView release];
        [self addSubview:imageView];
        
        
        
        KDLayouterHeaderView *header = [[KDLayouterHeaderView alloc] initWithFrame:CGRectZero];
        self.headerView = header;
        //header.hidden = YES;
        [self  addSubview:header];
        [header release];
        
        KDLayouterTextView *textView = [[KDLayouterTextView alloc] initWithFrame:CGRectZero];
        // textView.hidden = YES;
        [self addSubview:textView];
        self.textView = textView;
        [textView release];
        
        KDLayouterExtraStatusView *extraView = [[KDLayouterExtraStatusView alloc] initWithFrame:CGRectZero];
        [self addSubview:extraView];
        self.extraStatusView = extraView;
        [extraView release];
        
        KDLayouterThumbnailsView *thumbnails = [[KDLayouterThumbnailsView alloc] initWithFrame:CGRectZero];
        //thumbnails.hidden = YES;
        [self  addSubview:thumbnails];
        self.thumnailsView = thumbnails;
        [thumbnails release];
        
        KDLayouterFooterView *footer = [[KDLayouterFooterView alloc] initWithFrame:CGRectZero];
        // footer.hidden = YES;
        [self  addSubview:footer];
        self.footerView = footer;
        [footer release];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapped:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        [tapGestureRecognizer release];
        
        
    }
    return self;
    
}
- (void)onTapped:(UIGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"tapped");
        
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];

}


- (void)dealloc {
    
    KD_RELEASE_SAFELY(backgroundImageView_);
    KD_RELEASE_SAFELY(fatherView_);
    KD_RELEASE_SAFELY(headerView_);
    KD_RELEASE_SAFELY(textVeiw_);
    KD_RELEASE_SAFELY(contentView_);
    KD_RELEASE_SAFELY(thumnailsView_);
    KD_RELEASE_SAFELY(footerView_);
    KD_RELEASE_SAFELY(extraStatusView_);
    
    [super dealloc];
}

@end


@interface KDLayouterDocumentListView ()
@property(nonatomic,retain)KDDocumentListView *listView;
@end
@implementation KDLayouterDocumentListView : KDStatusView
@synthesize listView = listView_;

- (id)initWithFrame:(CGRect)frame  {
    self = [super initWithFrame:frame];
    if (self) {
        listView_ = [[KDDocumentListView alloc] initWithFrame:CGRectZero];
        listView_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:listView_];
    }
    return self;

}

- (void)update {
    if(self.userInfo) {
        id dataSource = [self.userInfo objectForKey:@"dataSource"];
        [listView_ setDocumentDataSource:dataSource];
    }
}

- (void)dealloc {
    KD_RELEASE_SAFELY(listView_);
    
    [super dealloc];
}

@end


@implementation KDQuotedStatusView
@synthesize backgroudImageView = backgroudImageView_ ;
- (id)init{
    self = [super init];
    if (self) {
        ///
        backgroudImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
        backgroudImageView_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:backgroudImageView_];

    }
    return self;
}
- (void)update {
    if (self.userInfo) {
        UIImage *image = [self.userInfo objectForKey:@"backgroundImage"];
        backgroudImageView_.image = image;
    }
 
}

- (void)dealloc {
    KD_RELEASE_SAFELY(backgroudImageView_);
    [super dealloc];
}
@end




@implementation KDLayouterMessageView
@synthesize backgroudImageView =backgroudImageView_;
@synthesize textView = textView_;
@synthesize thumbnailsView = thumbnailsView_;
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *image = [UIImage imageNamed:@"msgBg.png"];
        image = [image stretchableImageWithLeftCapWidth:10 topCapHeight:41];
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:image];
        backgroundView.frame = self.bounds;
        [backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth ];
        [self addSubview:backgroundView];
        self.backgroudImageView = backgroundView;
        [backgroundView release];
        
        KDLayouterTextView *theTextView= [[KDLayouterTextView alloc] initWithFrame:CGRectZero];
        [self addSubview:theTextView];
        self.textView = theTextView;
        [theTextView release];
    
        
        KDLayouterThumbnailsView *theThumbnailView = [[KDLayouterThumbnailsView alloc] initWithFrame:CGRectZero];
        [self addSubview:theThumbnailView];
        self.thumbnailsView = theThumbnailView;
        [theThumbnailView release];
    }
    return self;
}

- (void)dealloc {
    KD_RELEASE_SAFELY(backgroudImageView_);
    KD_RELEASE_SAFELY(textView_);
    KD_RELEASE_SAFELY(thumbnailsView_);
    [super dealloc];
}
@end