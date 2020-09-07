//
//  SettingTableViewCell.m
//  TwitterFon
//
//  Created by apple on 11-6-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SettingTableViewCell.h"
#import <QuartzCore/QuartzCore.h> 

/*
static UIImage* sBackgroudImagefull = nil;
static UIImage* sBackgroudImageup = nil;
static UIImage* sBackgroudImagemiddle = nil;
static UIImage* sBackgroudImagedown = nil;
static UIImage* sBackgroudImagelogout= nil;

static UIImage* sSelectedImagefull = nil;
static UIImage* sSelectedImageup = nil;
static UIImage* sSelectedImagemiddle = nil;
static UIImage* sSelectedImagedown = nil;
static UIImage* sSelectedImagelogout = nil;
*/
@interface SettingTableViewCell(Private)
+ (UIImage*)backgroudImagefull;
+ (UIImage*)backgroudImagemiddle;
+ (UIImage*)backgroudImagedown;
+ (UIImage*)backgroudImageup;
+ (UIImage*)backgroudImagelogout;

+ (UIImage*)selectedImagefull;
+ (UIImage*)selectedImagemiddle;
+ (UIImage*)selectedImagedown;
+ (UIImage*)selectedImageup;
+ (UIImage*)selectedImagelogout;
@end

@implementation SettingTableViewCell
@synthesize rowType;
@synthesize customImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = UIColorFromRGB(0xfafafa);
        
        self.detailTextLabel.backgroundColor=[UIColor clearColor];
        self.detailTextLabel.font=[UIFont systemFontOfSize:14.0f];
        self.detailTextLabel.textColor = UIColorFromRGB(0x808080);
        
        self.textLabel.backgroundColor=[UIColor clearColor];
        self.textLabel.font=[UIFont boldSystemFontOfSize:16.f];

        self.customImageView=[[UIImageView alloc]initWithImage:nil];//autorelease];
        [self.contentView addSubview:self.customImageView];
        
        narrowImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_img_vector.png"]];
        [narrowImageView_ sizeToFit];
        narrowImageView_.highlightedImage = [UIImage imageNamed:@"common_img_vector.png"];
        [self.contentView addSubview:narrowImageView_];
        
        UIView *selectBgView = [[UIView alloc] initWithFrame:self.bounds] ;//autorelease];
        selectBgView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        selectBgView.backgroundColor = UIColorFromRGB(0xdddddd);
        self.selectedBackgroundView = selectBgView;
        
        [self setupLines];
        
    }

    return self;
}

- (void)setupLines
{
    topLine_ = [self genLine];
    leftLine_ = [self genLine];
    bottomLine_ = [self genLine];
    rightLine_ = [self genLine];
    
    [self.layer addSublayer:topLine_];
    [self.layer addSublayer:leftLine_];
    [self.layer addSublayer:bottomLine_];
    [self.layer addSublayer:rightLine_];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    
    narrowImageView_.frame = CGRectMake(CGRectGetWidth(self.contentView.frame) - 15.0f, (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(narrowImageView_.bounds)) * 0.5f, CGRectGetWidth(narrowImageView_.bounds), CGRectGetHeight(narrowImageView_.bounds));
    
    topLine_.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.layer.frame), 0.5f);
    leftLine_.frame = CGRectMake(0, 0, 0.5f, CGRectGetHeight(self.layer.frame));
    bottomLine_.frame = CGRectMake(0.0f, CGRectGetHeight(self.layer.frame) - 0.5f, CGRectGetWidth(self.layer.frame), 0.5f);
    rightLine_.frame = CGRectMake(CGRectGetWidth(self.layer.frame) - 0.5f, 0.0f, 0.5f, CGRectGetHeight(self.layer.frame));
}

- (CALayer *)genLine
{
    CALayer *line = [CALayer layer];
    line.backgroundColor = UIColorFromRGB(0xdddddd).CGColor;
    
    return line;
}

- (void)setFrame:(CGRect)frame {
    float inset = 7.0f;
    
    frame.origin.x += inset;
    frame.size.width -= 2 * inset;
    
    [super setFrame:frame];
}


- (void)dealloc
{
    //KD_RELEASE_SAFELY(customImageView);
    //KD_RELEASE_SAFELY(narrowImageView_);
    //[super dealloc];
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    if(rowType==User_Image)
    {
         self.imageView.frame=CGRectMake(10, 9, 30, 30);
    }
    else
    {        
        self.imageView.frame=CGRectMake(10, 9, 24, 21);
    }
    
    if(customImageView.image==nil)
    {
        customImageView.hidden=true;        
    }
    else
    {
        customImageView.hidden=false;
        CGRect rect = customImageView.frame;
        rect.origin.x = CGRectGetMaxX(self.textLabel.frame) +3;
        rect.origin.y = 9;
        rect.size = CGSizeMake(37, 20);
        customImageView.frame=rect;
    }
    
    CGRect frame = self.textLabel.frame;
    frame.origin.y = (CGRectGetHeight(self.frame) - CGRectGetHeight(self.textLabel.frame)) * 0.5;
    self.textLabel.frame = frame;
}

- (void)applyRowType
{
    switch (rowType) {
        case FirstRow:
            topLine_.hidden = NO;
            bottomLine_.hidden = YES;
            break;
        case MiddleRow:
            topLine_.hidden = NO;
            bottomLine_.hidden = NO;
            break;
        case LastRow:
            topLine_.hidden = YES;
            bottomLine_.hidden = NO;
            break;
        case FullRow:
            topLine_.hidden = NO;
            bottomLine_.hidden = NO;
            break;
        default:
            break;
    }
}

/*
- (void) applyRowType
{
    switch (rowType) 
    {
        
        case FirstRow:
        {
            self.backgroundView=[[[UIImageView alloc]initWithImage:[SettingTableViewCell  backgroudImageup]]autorelease];
            self.selectedBackgroundView=[[[UIImageView alloc]initWithImage:[SettingTableViewCell  selectedImageup]]autorelease];
        }
            break;
        case MiddleRow:
        {
            self.backgroundView=[[[UIImageView alloc]initWithImage:[SettingTableViewCell  backgrodImagemiddle]]autorelease];
            self.selectedBackgroundView=[[[UIImageView alloc]initWithImage:[SettingTableViewCell  selectedImagemiddle]]autorelease];
        }
            break;
        case LastRow:
        {
            self.backgroundView=[[[UIImageView alloc]initWithImage:[SettingTableViewCell  backgroudImagedown]]autorelease];
            self.selectedBackgroundView=[[[UIImageView alloc]initWithImage:[SettingTableViewCell  selectedImagedown]]autorelease];
        }
            break;
        case FullRow:
        case User_Image:
        {
            self.backgroundView=[[[UIImageView alloc]initWithImage:[SettingTableViewCell  backgroudImagefull]]autorelease];
            self.selectedBackgroundView=[[[UIImageView alloc]initWithImage:[SettingTableViewCell  selectedImagefull]]autorelease];
        }
            break;
        case Logout:
        {
            self.backgroundView=[[[UIImageView alloc]initWithImage:[SettingTableViewCell  backgroudImagelogout]]autorelease];
            self.selectedBackgroundView=[[[UIImageView alloc]initWithImage:[SettingTableViewCell  selectedImagelogout]]autorelease];
//            [self.textLabel setTextColor:[UIColor colorWithRed:0x45/255.0 green:0x55/255.0 blue:0x68/255.0 alpha:1.0]];
            //self.textLabel.font=UIFont
        }
            break;
            
        default:
            break;
    }
    self.textLabel.backgroundColor=[UIColor clearColor];
    [self setNeedsLayout];
    
}
*/
/*
+ (UIImage*)backgroudImagefull
{
    if (sBackgroudImagefull == nil) {
        UIImage *i = [UIImage imageNamed:@"personal_center_item_bg_v2.png"];
        sBackgroudImagefull =[[i stretchableImageWithLeftCapWidth:i.size.width * 0.5f topCapHeight:i.size.height * 0.5f] retain];
    }
    return sBackgroudImagefull;
}
+ (UIImage*)backgroudImageup
{
    if (sBackgroudImageup == nil) {
        UIImage *i = [UIImage imageNamed:@"cell_bg_top_v2.png"];
        sBackgroudImageup =[[i stretchableImageWithLeftCapWidth:9 topCapHeight:9] retain];
    }
    return sBackgroudImageup;
}
+ (UIImage*)backgrodImagemiddle
{
    if (sBackgroudImagemiddle== nil) {
        UIImage *i = [UIImage imageNamed:@"cell_bg_middle_v2.png"];
        sBackgroudImagemiddle =[[i stretchableImageWithLeftCapWidth:9 topCapHeight:9] retain];
    }
    return sBackgroudImagemiddle;
}
+ (UIImage*)backgroudImagedown
{
    if (sBackgroudImagedown == nil) {
        UIImage *i = [UIImage imageNamed:@"cell_bg_bottom_v2.png"];
        sBackgroudImagedown =[[i stretchableImageWithLeftCapWidth:9 topCapHeight:9] retain];
    }
    return sBackgroudImagedown;
}
+ (UIImage*)backgroudImagelogout
{
    if (sBackgroudImagelogout == nil) {
        UIImage *i = [UIImage imageNamed:@"personal_center_item_bg_v2.png"];
        sBackgroudImagelogout =[[i stretchableImageWithLeftCapWidth:9 topCapHeight:9] retain];
    }
    return sBackgroudImagelogout;
}

+ (UIImage*)selectedImagefull
{
    if (sSelectedImagefull == nil) {
        UIImage *i = [UIImage imageNamed:@"personal_center_item_bg_hl_v2.png"];
        sSelectedImagefull =[[i stretchableImageWithLeftCapWidth:i.size.width * 0.5f topCapHeight:i.size.height * 0.5f] retain];
    }
    return sSelectedImagefull;
}
+ (UIImage*)selectedImageup
{
    if (sSelectedImageup == nil) {
        UIImage *i = [UIImage imageNamed:@"personal_center_item_bg_hl_v2.png"];
        sSelectedImageup =[[i stretchableImageWithLeftCapWidth:9 topCapHeight:9] retain];
    }
    return sSelectedImageup;
}
+ (UIImage*)selectedImagemiddle
{
    if (sSelectedImagemiddle== nil) {
        UIImage *i = [UIImage imageNamed:@"personal_center_item_bg_hl_v2.png"];
        sSelectedImagemiddle =[[i stretchableImageWithLeftCapWidth:9 topCapHeight:9] retain];
    }
    return sSelectedImagemiddle;
}
+ (UIImage*)selectedImagedown
{
    if (sSelectedImagedown == nil) {
        UIImage *i = [UIImage imageNamed:@"personal_center_item_bg_hl_v2.png"];
        sSelectedImagedown =[[i stretchableImageWithLeftCapWidth:9 topCapHeight:9] retain];
    }
    return sSelectedImagedown;
}

+ (UIImage*)selectedImagelogout
{
    if (sSelectedImagelogout == nil) {     
        UIImage *i = [UIImage imageNamed:@"logout_down.png"];
        sSelectedImagelogout =[[i stretchableImageWithLeftCapWidth:9 topCapHeight:9] retain];
    }
    return sSelectedImagelogout;
}
*/
@end
