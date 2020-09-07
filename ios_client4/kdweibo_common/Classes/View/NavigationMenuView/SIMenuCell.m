//
//  SAMenuCell.m
//  NavigationMenu
//
//  Created by Ivan Sapozhnik on 2/19/13.
//  Copyright (c) 2013 Ivan Sapozhnik. All rights reserved.
//

#import "SIMenuCell.h"
#import "SIMenuConfiguration.h"
#import "UIColor+Extension.h"
#import "SICellSelection.h"
#import <QuartzCore/QuartzCore.h>

@interface SIMenuCell ()
@property (nonatomic, retain) SICellSelection *cellSelection;
@end

@implementation SIMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.contentView.backgroundColor = [UIColor color:[SIMenuConfiguration itemsColor] withAlpha:[SIMenuConfiguration menuAlpha]];
        self.textLabel.textColor = [SIMenuConfiguration itemTextColor];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.shadowColor = [UIColor darkGrayColor];
        self.textLabel.shadowOffset = CGSizeMake(0.0, -1.0);

        CGRect rect = self.contentView.frame;
        rect.size.height -= 1.0;

        UIView *contentView = [[UIView alloc] initWithFrame:rect];
        contentView.backgroundColor = [UIColor color:[SIMenuConfiguration itemsColor] withAlpha:[SIMenuConfiguration menuAlpha]];
        [self.contentView insertSubview:contentView belowSubview:self.textLabel];
//        [contentView release];
        
        self.selectionStyle = UITableViewCellEditingStyleNone;
        
        self.cellSelection = [[SICellSelection alloc] initWithFrame:rect andColor:[SIMenuConfiguration selectionColor]];// autorelease];
//        [self.cellSelection.layer setCornerRadius:6.0];
//        [self.cellSelection.layer setMasksToBounds:YES];
        
        self.cellSelection.alpha = 0.0;
        [self.contentView insertSubview:self.cellSelection belowSubview:self.textLabel];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 1.0f);
    
    CGContextSetRGBStrokeColor(ctx, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextMoveToPoint(ctx, 0, self.contentView.bounds.size.height-0.5f);
    CGContextAddLineToPoint(ctx, self.contentView.bounds.size.width, self.contentView.bounds.size.height-0.5f);
    CGContextStrokePath(ctx);
    
    CGContextSetRGBStrokeColor(ctx, 1.0f, 1.0f, 1.0f, 1.0f);
        
    CGContextMoveToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, self.contentView.bounds.size.width, 0);
    CGContextStrokePath(ctx);
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    float alpha = 0.0;
    if (highlighted) {
        alpha = 1.0;
    } else {
        alpha = 0.0;
    }
    [UIView animateWithDuration:[SIMenuConfiguration selectionSpeed] animations:^{
        self.cellSelection.alpha = alpha;
    } completion:^(BOOL finished) {
        
    }];
}
- (void)setSelected:(BOOL)selected withCompletionBlock:(void (^)())completion
{
    float alpha = 0.0;
    if (selected) {
        alpha = 1.0;
    } else {
        alpha = 0.0;
    }
    [UIView animateWithDuration:[SIMenuConfiguration selectionSpeed] animations:^{
        self.cellSelection.alpha = alpha;
    } completion:^(BOOL finished) {
        completion();
    }];
}

- (void)dealloc
{
    self.cellSelection = nil;
    //[super dealloc];
}

@end
