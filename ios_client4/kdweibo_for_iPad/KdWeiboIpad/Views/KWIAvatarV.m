//
//  KWIAvatarV.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/10/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIAvatarV.h"

#import <QuartzCore/QuartzCore.h>

#import "UIImageView+WebCache.h"

@implementation KWIAvatarV
{
    UIImageView *_imgV;
    UIImageView *_maskV;
}
@synthesize imageView = _imgV;

+ (KWIAvatarV *)viewForUrl:(NSString *)url size:(NSUInteger)size
{
    if (!(35 == size || 40 == size || 48 == size)) {
        @throw [NSException exceptionWithName:@"KWIAvatarVSizeError" 
                                       reason:[NSString stringWithFormat:@"only size 35, 40, 48 are available, requested %d", size] 
                                     userInfo:nil];
    }
    
    return [[[self alloc] initWithUrl:url size:size] autorelease];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self = [self initWithFrame:CGRectMake(0, 0, 48, 48)];
    }
    return self;
    
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        ///
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingNone;
        
        UIImageView * theImageView = [[UIImageView alloc] initWithFrame:frame];
        theImageView.layer.cornerRadius = 4.5;
        theImageView.clipsToBounds = YES;
        self.imageView = theImageView;
        [theImageView release];
        
        //[_imgV setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"avatarPH-160.png"]];
        [self addSubview:_imgV];
        
        _maskV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"avatarMask-%d.png", 48]]];
        [self addSubview:_maskV];
    }
    return self;
}
- (id) initWithFrame:(CGRect)frame size:(NSUInteger)size url:(NSString *)url {
    self = [self initWithFrame:frame];
    if (self) {
        [self downloadImageWithUrl:url];
        [_maskV setImage:[UIImage imageNamed:[NSString stringWithFormat:@"avatarMask-%d.png", size]]];
        [_maskV sizeToFit];
    }
    return self;
}


- (void)downloadImageWithUrl:(NSString *)url {

    [self.imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"avatarPH-160.png"]];
    
}

- (id)initWithUrl:(NSString *)url size:(NSUInteger)size
{
    CGRect viewFrame = CGRectZero;
    CGRect imgFrame = CGRectMake(0, 0, size, size);
    switch (size) {
        case 35:
            viewFrame.size = CGSizeMake(37, 37);
            imgFrame.origin = CGPointMake(1, 1);
//            borderRadius = 3;
            break;
            
        case 40:
            viewFrame.size = CGSizeMake(43, 43);
            imgFrame.origin = CGPointMake(1, 1);
            break;
            
        case 48:
            viewFrame.size = CGSizeMake(50, 50);
            imgFrame.origin = CGPointMake(1, 1);
            break;
    }
    return [self initWithFrame:imgFrame size:size url:url];
    
}

- (void)dealloc
{
    [_imgV release];
    [_maskV release];
    [super dealloc];
}

- (void)replacePlaceHolder:(UIView *)placeHolder
{
    CGRect frame = self.frame;
    frame.origin = placeHolder.frame.origin;
    self.frame = frame;
    
    [placeHolder.superview insertSubview:self aboveSubview:placeHolder];
    [placeHolder removeFromSuperview];
}

/*- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    _maskV.userInteractionEnabled = userInteractionEnabled;
    _imgV.userInteractionEnabled = userInteractionEnabled;
    [super setUserInteractionEnabled:userInteractionEnabled];
}*/

@end
