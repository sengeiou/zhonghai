//
//  KDLoadingViewCell.h
//  kdweibo
//
//  Created by Jiandong Lai
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDLoadingCell.h"


////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDLoadingContentImplView class

@interface KDLoadingContentImplView : UIView {
@private
//    KDLoadingCell *_cell; // weak reference
    
    UILabel *_textLabel;
    UIActivityIndicatorView *_activityView;
}

@property (nonatomic, assign)  KDLoadingCell *cell;

@property (nonatomic, retain) UILabel *textLabel;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;

@end


@implementation KDLoadingContentImplView

@synthesize cell=_cell;

@synthesize textLabel=_textLabel;
@synthesize activityView=_activityView;

- (void) _setupLoadingContentView {
    // text label
    _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.textColor = [UIColor colorWithRed:0.195 green:0.309 blue:0.520 alpha:1.0];
    _textLabel.highlightedTextColor = [UIColor whiteColor];
    _textLabel.font = [UIFont systemFontOfSize:14];  
    _textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self addSubview:_textLabel];
    
    // activity indicator view
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:_activityView];
}

- (id) initWithFrame:(CGRect)frame cell:(KDLoadingCell *)cell {
    self = [super initWithFrame:frame];
    if(self){
        _cell = cell;
        
        [self _setupLoadingContentView];
    }
    
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGFloat offsetX = 0.0;
    if([_activityView isAnimating]){
        CGSize spinnerSize = _activityView.bounds.size;
        CGFloat spacing = 5.0;
        
        // calculate the text drawing size
        CGRect rect = CGRectMake(0.0, 0.0, self.bounds.size.width - (spinnerSize.width + spacing), self.bounds.size.height);
        CGSize textSize = [_textLabel.text sizeWithFont:_textLabel.font constrainedToSize:rect.size];
        
        offsetX = (self.bounds.size.width - textSize.width - spinnerSize.width - spacing)*0.5; 
        
        rect = _activityView.frame;
        rect.origin.x = offsetX;
        rect.origin.y = (self.bounds.size.height - rect.size.height)*0.5;
        _activityView.frame = rect;
        
        offsetX += rect.size.width + spacing;
    }
    
    _textLabel.frame = CGRectMake(offsetX, 0.0, self.bounds.size.width - offsetX, self.bounds.size.height);
}

- (void) dealloc {
    _cell = nil;
    
    //KD_RELEASE_SAFELY(_textLabel);
    //KD_RELEASE_SAFELY(_activityView);
    
    //[super dealloc];
}

@end


////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDLoadingCell class

@interface KDLoadingCell ()

@property (nonatomic, retain) UIView *loadingContentImplView;

@end


@implementation KDLoadingCell

@synthesize loadingContentImplView=_loadingContentImplView;

- (void) _setupLoadingCell {
    _loadingContentImplView = [[KDLoadingContentImplView alloc] initWithFrame:CGRectZero cell:self];
    _loadingContentImplView.backgroundColor = UIColorFromRGB(0xdadde0);
    
    [super.contentView addSubview:_loadingContentImplView];
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self _setupLoadingCell];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = super.contentView.bounds.size;
    _loadingContentImplView.frame = CGRectMake(0.0, 0.0, size.width, size.height);
}

- (void) toggleActivityAnimation:(BOOL)start {
    BOOL changed = NO;
    if(start){
        if(![_loadingContentImplView.activityView isAnimating]){
            [_loadingContentImplView.activityView startAnimating];
            changed = YES;
        }
        
    }else {
        if([_loadingContentImplView.activityView isAnimating]){
           [_loadingContentImplView.activityView stopAnimating];
            changed = YES;
        }    
    }
    
    if(changed){
        _loadingContentImplView.textLabel.textAlignment = start ? NSTextAlignmentLeft : NSTextAlignmentCenter;
        [_loadingContentImplView setNeedsLayout];
    }
}

- (void) setLoadingText:(NSString*)loadingText {
    _loadingContentImplView.textLabel.textAlignment = ([_loadingContentImplView.activityView isAnimating]) ? NSTextAlignmentLeft : NSTextAlignmentCenter;
    _loadingContentImplView.textLabel.text = loadingText;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(_loadingContentImplView);
    
	//[super dealloc];
}

@end
