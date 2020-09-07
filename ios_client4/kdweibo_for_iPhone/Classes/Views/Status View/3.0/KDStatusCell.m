//
//  KDStausCell.m
//  kdweibo
//
//  Created by Tan Yingqi on 13-12-27.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDStatusCell.h"


@interface UIView(loadImage)
- (void)loadImage;
@end

@implementation UIView(loadImage)
- (void)loadImage {
    for (UIView *view in self.subviews) {
        if ([view respondsToSelector:@selector(loadThumbailsImage)]) {
            [view performSelectorOnMainThread:@selector(loadThumbailsImage) withObject:nil waitUntilDone:NO];
            return;
        }
        [view loadImage];
    }
}
@end

@implementation KDStatusCell
@synthesize maskInsets = maskInsets_;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = nil;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.maskInsets = UIEdgeInsetsMake(10, 8,0,8);
    }
    return self;
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
       [super setHighlighted:highlighted animated:animated];
 
       UIView *mask  = [self viewWithTag:1090];
       if (!mask) {
            mask = [[UIView alloc] initWithFrame:CGRectMake(maskInsets_.left , maskInsets_.top, self.bounds.size.width-(maskInsets_.left +maskInsets_.right), self.bounds.size.height-(maskInsets_.top + maskInsets_.bottom))];
           mask.tag = 1090;
           mask.backgroundColor = [UIColor kdBackgroundColor1];
           mask.alpha = 0.1;
           [self addSubview:mask];
//           [mask release];
        }
    
       //self.backgroundColor = highlighted?[self bringSubviewToFront:mask ]:[UIColor clearColor];
    if (highlighted) {
        mask.hidden = NO;
        [self bringSubviewToFront:mask];
    }else {
        mask.hidden = YES;
        [self insertSubview:mask atIndex:0];
    }
}

+ (void)loadImagesForVisibleCellsIfNeed:(UITableView *)tableView {
    NSArray *cells = [tableView visibleCells];
    if ([cells count] >0) {
        //[timelineProvider_ loadImageSourceInTableView:tableView_];
        NSArray *cells = [tableView visibleCells];
        if (cells != nil) {
            for(KDStatusCell *cell in cells){
                if ([cell isKindOfClass:[KDStatusCell class]]) {
                    [cell loadThumbanilsImage];
                }
            }
        }
    }
}


//+ (KDStatusCell *)cellWithStatus:(KDStatus *)status constainedWidth:(CGFloat )width {
//  
//    KDStatusCell * cell = [[[KDStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
//    cell.backgroundColor = [UIColor clearColor];
//  
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    KDStatusLayouter *layouter = [KDStatusLayouter groupStatusLayouter:status constrainedWidth:width];
//    KDLayouterView * layouterView = [layouter view];
//    [cell addSubview:layouterView];
//    layouterView.layouter = layouter;
//    return cell;
//}
- (void)loadThumbanilsImage {
    [self loadImage];
}

@end
