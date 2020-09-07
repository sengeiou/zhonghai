//
//  KDTileViewCell.h
//  kdweibo
//
//  Created by laijiandong on 12-5-27.
//  Copyright 2012 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KDTileViewCell : UIView {
@private    
	NSString *identifier_;
	
    UIView *contentView_;
}

@property (nonatomic, readonly, copy) NSString *identifier;

@property (nonatomic, readonly, retain) UIView *contentView;
@property(nonatomic, retain) id userInfo;

- (id) initWithIdentifier:(NSString *)identifier;
- (void) prepareForReuse;
- (void) shouldCacheCell;

@end

