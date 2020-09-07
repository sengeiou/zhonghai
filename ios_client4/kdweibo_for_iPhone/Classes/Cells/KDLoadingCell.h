//
//  KDLoadingViewCell.h
//  kdweibo
//
//  Created by Jiandong Lai
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@class KDLoadingContentImplView;

@interface KDLoadingCell : UITableViewCell {
@private
    KDLoadingContentImplView *_loadingContentImplView;
}

- (void) toggleActivityAnimation:(BOOL)start;
- (void) setLoadingText:(NSString*)loadingText;

@end
