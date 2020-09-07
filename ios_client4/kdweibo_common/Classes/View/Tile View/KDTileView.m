//
//  KDTileView.h
//  kdweibo
//
//  Created by laijiandong on 12-5-27.
//  Copyright 2012 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDTileView.h"

#import "KDTileViewCell.h"


static const NSInteger kGAInvalidColumn = -1;

@interface KDTileView ()

@property (nonatomic, retain) NSMutableArray *visibleColumns;
@property (nonatomic, retain) NSMutableArray *visibleCells;
@property (nonatomic, retain) NSMutableDictionary *reuseableTileCells;

- (void) resetStageContentSize;

- (void) displayFullPageTileCells;
- (void) displayGridPageTileCells;
- (void) changeVisibleTileCellFrame;
- (void) shouldChangeCellsVisible;

- (void) loadVisibleTileCellWithColumn:(NSInteger)column atHead:(BOOL)atHead offsetX:(CGFloat)offsetX;
- (void) clearUpTileCellFromVisibleQueueAtHead:(BOOL)atHead;
- (void) removeTileCellAtIndex:(NSUInteger)index;

- (BOOL) isLeftColumn:(NSInteger)column;
- (BOOL) isRightColumn:(NSInteger)column;
- (NSInteger) previousColumnRelativeWithColumn:(NSInteger)column;
- (NSInteger) nextColumnRelativeWithColumn:(NSInteger)column;
- (CGFloat) offsetXForCellWithColumn:(NSInteger)column;

- (void) enqueueReuseableCell:(KDTileViewCell *)cell;

@end


@implementation KDTileView

@synthesize dataSource=dataSource_;

@synthesize visibleColumns=visibleColumns_;
@synthesize visibleCells=visibleCells_;
@synthesize reuseableTileCells=reuseableTileCells_;

@synthesize paddingWidth=paddingWidth_;

- (id)initWithFrame:(CGRect)frame {
	if(self = [super initWithFrame:frame]) {
		super.showsVerticalScrollIndicator = NO;
		super.showsHorizontalScrollIndicator = NO;
		super.pagingEnabled = YES;
		super.contentOffset = CGPointZero;
		
		dataSource_ = nil;
		
		style_ = KDTileViewStyleFullPage;
		
		numberOfColumns_ = 0;
		visibleBounds_ = frame;
		
		visibleColumns_ = [[NSMutableArray alloc] init];
		visibleCells_ = [[NSMutableArray alloc] init];
		reuseableTileCells_ = [[NSMutableDictionary alloc] init];
	}
	
    return self;
}

- (id) initWithFrame:(CGRect)frame style:(KDTileViewStyle)style cellWidth:(CGFloat)cellWidth paddingWidth:(CGFloat)paddingWidth {
	CGRect rect = frame;
	rect.size.width += 2*paddingWidth;
	rect.origin.x -= paddingWidth;
	
	if(self = [self initWithFrame:rect]){
		style_ = style;
		
		cellWidth_ = cellWidth;
		paddingWidth_ = paddingWidth;

		visibleBounds_ = frame;
	}
	
	return self;
}

- (void) layoutSubviews {
	[super layoutSubviews];
	
	if(style_ == KDTileViewStyleGridPage){
		[self displayGridPageTileCells];
		
	}else {
		[self displayFullPageTileCells];
	}
	
	[self shouldChangeCellsVisible];
}

- (void) shouldChangeCellsVisible {
	BOOL visible = NO;
	for(KDTileViewCell *cell in visibleCells_){
		visible = (cell.frame.origin.x-super.contentOffset.x+cell.frame.size.width+paddingWidth_ < 0.01 ||
				   cell.frame.origin.x > super.contentOffset.x+self.frame.size.width)?NO:YES;
		
		if(cell.hidden != !visible){
			cell.hidden = !visible;
			if(cell.hidden){
				[cell shouldCacheCell];
			} 
		}
	}
}

- (void) displayTileCellsUsedInLowVersion {
	[self displayFullPageTileCells];
	[self shouldChangeCellsVisible];
}

- (void) displayFullPageTileCells {
	CGFloat stageOffsetX = super.contentOffset.x;
	if(stageOffsetX > -0.1 && stageOffsetX < super.contentSize.width+0.1){
		CGFloat width = cellWidth_+2*paddingWidth_;
		
		// we need plus half of cell width to calculate center index, Because the scroll view have bounce feature when
		// after swipe or draging. So, When the scroll view bounces and we not need update page.
		int centerIndex = (int)((stageOffsetX+0.5*width)/width);
		if(centerIndex >= numberOfColumns_){
			return;
		}
		
		BOOL isLeft = [self isLeftColumn:centerIndex];
		BOOL isRight = [self isRightColumn:centerIndex];
		
		int previousIndex = isLeft?centerIndex:(centerIndex-1);
		int nextIndex = isRight?centerIndex:(centerIndex+1);
		
		if([visibleColumns_ count] > 0){
			NSInteger firstColumn = [[visibleColumns_ objectAtIndex:0x00] integerValue];
			NSInteger lastColumn = [[visibleColumns_ lastObject] integerValue];
			if(firstColumn == previousIndex && lastColumn == nextIndex){
				return;
			}
			
			CGFloat boundary = width*centerIndex;
			CGFloat leftBoundary = boundary-width;
			CGFloat rightBoundary = boundary+2*width;
			
			NSUInteger i = 0;
			KDTileViewCell *cell = nil;
			NSMutableArray *removeCells = [[NSMutableArray alloc] init];
			
			for(; i<[visibleCells_ count]; i++){
				cell = [visibleCells_ objectAtIndex:i];
				if(cell.frame.origin.x < leftBoundary || cell.frame.origin.x > rightBoundary){
					[removeCells addObject:cell];
				}
			}
			
			for(KDTileViewCell *obj in removeCells){
				i = [visibleCells_ indexOfObject:obj];
				[self removeTileCellAtIndex:i];
			}
//			[removeCells release];
		}
		
		BOOL flags[] = {NO, NO, NO};
		for(NSNumber *item in visibleColumns_){
			NSInteger value = [item integerValue];
			if(value == previousIndex){
				flags[0] = YES;
			}
			
			if(value == centerIndex){
				flags[1] = YES;
			}
			
			if(value == nextIndex){
				flags[2] = YES;
			}
		}
		
		CGFloat originX = 0.0;
		CGFloat offsetX = width*centerIndex+paddingWidth_;
		
		if(!flags[1]){
			[self loadVisibleTileCellWithColumn:centerIndex atHead:(!isRight && !flags[2])?NO:YES offsetX:offsetX];
		}

		if(!isLeft && !flags[0]){
			originX = offsetX-width;
			[self loadVisibleTileCellWithColumn:previousIndex atHead:YES offsetX:originX];
		}
		
		if(!isRight && !flags[2]){
			originX = offsetX+width;
			[self loadVisibleTileCellWithColumn:nextIndex atHead:NO offsetX:originX];
		}
	}
}

- (void) displayGridPageTileCells {
	CGFloat stageOffsetX = super.contentOffset.x;
	if(stageOffsetX > -0.1 && stageOffsetX < super.contentSize.width+0.1){
		CGFloat cellWidth = cellWidth_+2*paddingWidth_;
		int closeLeftEdgeIndex = (int)(stageOffsetX/cellWidth);
		
		BOOL isLeft = [self isLeftColumn:closeLeftEdgeIndex];
		BOOL isRight = [self isRightColumn:closeLeftEdgeIndex];
		
		int leftEdgeIndex = isLeft?closeLeftEdgeIndex:(closeLeftEdgeIndex-1);
		
		int rightEdgeIndex = 0;
		if(isRight){
			rightEdgeIndex = closeLeftEdgeIndex;
			
		}else {
			int visibleCount = (int)(self.frame.size.width/cellWidth);
			int relativeIndex = closeLeftEdgeIndex+visibleCount+1;
			if(relativeIndex < numberOfColumns_-1){
				rightEdgeIndex = relativeIndex;
				
			}else {
				rightEdgeIndex = (int)numberOfColumns_-1;
			}
		}
		
		if([visibleCells_ count] > 0){
			CGFloat boundary = cellWidth*closeLeftEdgeIndex;
			CGFloat leftBoundary = boundary-cellWidth;
			CGFloat rightBoundary = boundary+self.frame.size.width+cellWidth;
			
			NSMutableArray *removeCells = [[NSMutableArray alloc] init];
			for(KDTileViewCell *cell in visibleCells_){
				if(cell.frame.origin.x < leftBoundary || cell.frame.origin.x > rightBoundary){
					[removeCells addObject:cell];
				}
			}
			
			NSUInteger idx = 0;
			for(KDTileViewCell *obj in removeCells){
				idx = [visibleCells_ indexOfObject:obj];
				[self removeTileCellAtIndex:idx];
			}
//			[removeCells release];
		}
		
		NSInteger i = 0;
		CGFloat originX = 0.0;
		if([visibleColumns_ count] > 0){
			NSInteger innerLeftIndex = [[visibleColumns_ objectAtIndex:0x00] integerValue];
			NSInteger innerRightIndex = [[visibleColumns_ lastObject] integerValue];
			
			if(innerLeftIndex > leftEdgeIndex){
				i = innerLeftIndex-1;
				originX = cellWidth*i+paddingWidth_;
				for(; i>=leftEdgeIndex; i--){
					[self loadVisibleTileCellWithColumn:i atHead:YES offsetX:originX];
					originX -= cellWidth;
				}
			}
			
			if(innerRightIndex < rightEdgeIndex){
				i = innerRightIndex+1;
				originX = cellWidth*i+paddingWidth_;
				for(; i<=rightEdgeIndex; i++){
					[self loadVisibleTileCellWithColumn:i atHead:NO offsetX:originX];
					originX += cellWidth;
				}
			}
			
		}else {
			originX = cellWidth*leftEdgeIndex+paddingWidth_;
			for(i=leftEdgeIndex; i<=rightEdgeIndex; i++){
				[self loadVisibleTileCellWithColumn:i atHead:NO offsetX:originX];
				originX += cellWidth;
			}
		}
		
	}
}

- (void) changeVisibleTileCellFrame {
	CGFloat offsetX = paddingWidth_;
	if([visibleColumns_ count] > 0){
		offsetX += [self offsetXForCellWithColumn:[[visibleColumns_ objectAtIndex:0x00] integerValue]];
	}
	
	for(KDTileViewCell *cell in visibleCells_){
		cell.frame = CGRectMake(offsetX, 0.0, cellWidth_, visibleBounds_.size.height);
		offsetX += cell.frame.size.width+2*paddingWidth_;
	}
}

- (void) loadVisibleTileCellWithColumn:(NSInteger)column atHead:(BOOL)atHead offsetX:(CGFloat)offsetX {
	KDTileViewCell *cell = [dataSource_ tileView:self cellForColumn:column];
	
	cell.frame = CGRectMake(offsetX, 0.0, cellWidth_, visibleBounds_.size.height);
	cell.hidden = YES;
	[self addSubview:cell];
	
	if(atHead){
		[visibleCells_ insertObject:cell atIndex:0x00];
		[visibleColumns_ insertObject:[NSNumber numberWithInteger:column] atIndex:0x00];
		
	}else {
		[visibleCells_ addObject:cell];
		[visibleColumns_ addObject:[NSNumber numberWithInteger:column]];	
	}
}

- (void) clearUpTileCellFromVisibleQueueAtHead:(BOOL)atHead {
	NSUInteger index = (atHead)?0x00:[visibleCells_ count]-0x01;
	[self removeTileCellAtIndex:index];
}

- (void) removeTileCellAtIndex:(NSUInteger)index {
	[visibleColumns_ removeObjectAtIndex:index];
	
	KDTileViewCell *cell = [visibleCells_ objectAtIndex:index];
	[cell removeFromSuperview];
	[self enqueueReuseableCell:cell];
	[visibleCells_ removeObjectAtIndex:index];
}

- (void) resetStageContentSize {
	CGFloat fullStageWidth = 0.0;
	if(dataSource_){
		numberOfColumns_ = [dataSource_ numberOfColumnsAtTileView:self];
		fullStageWidth = numberOfColumns_*(cellWidth_+2*paddingWidth_);
	}
	
	super.contentSize = CGSizeMake(fullStageWidth, visibleBounds_.size.height);
}

- (CGFloat) offsetXForCellWithColumn:(NSInteger)column {
	if(kGAInvalidColumn == column){
		return 0.0; // Invalid index path
	}
	
	return column*(cellWidth_+2*paddingWidth_);
}

- (BOOL) isLeftColumn:(NSInteger)column {
	return (0x00 == column);
}

- (BOOL) isRightColumn:(NSInteger)column {
	return ((numberOfColumns_-1) == column);
}

- (NSInteger) previousColumnRelativeWithColumn:(NSInteger)column {
	if([self isLeftColumn:column]){
		return kGAInvalidColumn;
	}
	
	return column-1;
}

- (NSInteger) nextColumnRelativeWithColumn:(NSInteger)column {
	if([self isRightColumn:column]){
		return kGAInvalidColumn;
	}
	
	return column+1;
}

- (BOOL) isVisibleCellAtColumn:(NSInteger)column {
	BOOL visible = NO;
	for(NSNumber *item in visibleColumns_){
		if([item integerValue] == column){
			return YES;	
		}
	}
	
	return visible;
}

- (void) scrollToColumn:(NSInteger)column {
	CGFloat offsetX = [self offsetXForCellWithColumn:column];
	
	super.contentOffset = CGPointMake(offsetX, super.contentOffset.y);
	if(style_ == KDTileViewStyleGridPage){
		[self displayGridPageTileCells];
	}else {
		[self displayFullPageTileCells];
	}
	
	[self shouldChangeCellsVisible];
}

- (void) reloadData {
	for(KDTileViewCell *cell in visibleCells_){
		[cell removeFromSuperview];
	}
	[visibleCells_ removeAllObjects];
	[visibleColumns_ removeAllObjects];
	
	[reuseableTileCells_ removeAllObjects];
	
	numberOfColumns_ = 0;
	super.contentOffset = CGPointZero;
	
	[self setNeedsLayout];
}

- (KDTileViewCell *) cellForColumn:(NSInteger)column {
	if(column < 0 || column >= numberOfColumns_){
		return nil;
	}
	
	NSUInteger idx = 0;
	for(NSNumber *item in visibleColumns_){
		if([item integerValue] == column){
			return [visibleCells_ objectAtIndex:idx];
		}
		
		idx++;
	}
	
	return nil;
}

- (NSArray *) visibleColumns {
	return visibleColumns_;
}

- (NSArray *) visibleCells {
	return visibleCells_;
}

// this method just suitable for full page style
- (KDTileViewCell *) centerTileViewCell {
	for(KDTileViewCell *cell in visibleCells_){
		if(cell.frame.origin.x > super.contentOffset.x){
			return cell;
		}
	}
	
	return nil;
}

- (void) setDataSource:(id <KDTileViewDataSource>)dataSource {
	if(dataSource_ != dataSource){
		dataSource_ = dataSource;
		
		if(numberOfColumns_ < 1){
			[self resetStageContentSize];
		}
	}
}

- (KDTileViewCell *) dequeueReuseableCellWithIndentifier:(NSString *)indentifier {
	KDTileViewCell *cell = nil;
	if(reuseableTileCells_ && [reuseableTileCells_ count]>0){
		cell = [reuseableTileCells_ objectForKey:indentifier];
//		[[cell retain] autorelease];
		[reuseableTileCells_ removeObjectForKey:indentifier];
		[cell prepareForReuse];
	}
	
	return cell;
}

- (void) enqueueReuseableCell:(KDTileViewCell *)cell {
	if(![reuseableTileCells_ objectForKey:cell.identifier]){
		[reuseableTileCells_ setObject:cell forKey:cell.identifier];
	}
}

- (void) shouldChangeToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	int cloumnIndex = (int)(super.contentOffset.x/(cellWidth_+2*paddingWidth_));
	
	CGSize size = [UIScreen mainScreen].bounds.size;
	CGRect rect;
	if(style_ == KDTileViewStyleFullPage){
		size = (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))?CGSizeMake(size.height, size.width):size;
		rect.origin = CGPointMake(0.0-paddingWidth_, self.frame.origin.y);
		cellWidth_ = size.width;
		
	}else {
		size = CGSizeMake((UIInterfaceOrientationIsLandscape(toInterfaceOrientation))?size.height:size.width, visibleBounds_.size.height);
		rect.origin = CGPointMake(0.0-paddingWidth_, size.height-visibleBounds_.size.height);
	}
	visibleBounds_.size = size;
	size.width += 2*paddingWidth_;
	
	CGFloat cellWidth = (cellWidth_+2*paddingWidth_);
	super.contentSize = CGSizeMake(numberOfColumns_*cellWidth, visibleBounds_.size.height);
	super.contentOffset = CGPointMake(cloumnIndex*cellWidth, 0.0);
	
	rect.size = size;
	self.frame = rect;

	[self changeVisibleTileCellFrame];
	[self shouldChangeCellsVisible];
}

- (void)dealloc {
	dataSource_ = nil;
	
    //KD_RELEASE_SAFELY(visibleColumns_);
    //KD_RELEASE_SAFELY(visibleCells_);
    //KD_RELEASE_SAFELY(reuseableTileCells_);
    
    //[super dealloc];
}


@end

