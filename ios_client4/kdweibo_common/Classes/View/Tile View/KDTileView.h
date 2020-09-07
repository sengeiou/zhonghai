//
//  KDTileView.h
//  kdweibo
//
//  Created by laijiandong on 12-5-27.
//  Copyright 2012 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class KDTileViewCell;


typedef enum {
	KDTileViewStyleFullPage = 0x01,
	KDTileViewStyleGridPage
}KDTileViewStyle;


@protocol KDTileViewDataSource;

@interface KDTileView : UIScrollView {
@private
//	id<KDTileViewDataSource> dataSource_;
	KDTileViewStyle style_;
 	
	NSMutableArray *visibleColumns_;
	NSMutableArray *visibleCells_;
	NSMutableDictionary *reuseableTileCells_;
	
	NSInteger numberOfColumns_;
	CGRect visibleBounds_;
	CGFloat cellWidth_;
	CGFloat paddingWidth_;
}

@property (nonatomic, assign) id<KDTileViewDataSource> dataSource;

@property (nonatomic, assign) CGFloat paddingWidth;

- (id) initWithFrame:(CGRect)frame style:(KDTileViewStyle)style cellWidth:(CGFloat)cellWidth paddingWidth:(CGFloat)paddingWidth;

// reloading
- (void) reloadData;
- (void) displayTileCellsUsedInLowVersion;

- (void) scrollToColumn:(NSInteger)column;
- (KDTileViewCell *) cellForColumn:(NSInteger)column;

- (NSArray *) visibleColumns;
- (NSArray *) visibleCells;
- (KDTileViewCell *) centerTileViewCell;

- (KDTileViewCell *) dequeueReuseableCellWithIndentifier:(NSString *)indentifier;

- (void) shouldChangeToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

@end


@protocol KDTileViewDataSource <NSObject>

@required
- (NSUInteger) numberOfColumnsAtTileView:(KDTileView *)tileView;
- (KDTileViewCell *) tileView:(KDTileView *)tileView cellForColumn:(NSInteger)column;

@end



