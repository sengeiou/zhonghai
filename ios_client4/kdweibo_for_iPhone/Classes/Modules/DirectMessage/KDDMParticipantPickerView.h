//
//  KDDMParticipantPickerView.h
//  kdweibo
//
//  Created by Tan yingqi on 12-11-21.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDGridCellView.h"
#import "SMPageControl.h"

@class KDDMParticipantPickerView;

@protocol KDDMparticipantPickerViewDelegate <NSObject>

//

@optional
- (void)pickerView:(KDDMParticipantPickerView *)view shouldDeleteGridAtIndex:(NSInteger)index;

- (void)pickerView:(KDDMParticipantPickerView *)view didSelectGridAtIndex:(NSInteger)index;

- (void)pickerView:(KDDMParticipantPickerView *)view willDisplayGridView:(KDGridCellView *)gridCellView;

@end

@protocol KDDMparticipantPickerViewDataSource <NSObject>

//
@required
- (NSInteger)gridCount;
- (KDGridCellView *)gridCellView:(NSInteger)index;

- (KDGridCellView *)addButtonView;
- (KDGridCellView *)deleteButtonView;
- (CGRect)boundsOfCell;
- (BOOL)addViewEnable;
- (BOOL)deleViewEnable;

@end

@interface KDDMParticipantPickerView : UIView<UIScrollViewDelegate>
@property(nonatomic, assign)id<KDDMparticipantPickerViewDelegate> delegate;
@property(nonatomic, assign)id<KDDMparticipantPickerViewDataSource> dataSource;
@property (nonatomic, retain)UIScrollView *mainScrollerView;
@property (nonatomic, retain)SMPageControl *pageConrol;
@property (nonatomic, retain)NSMutableArray *gridViews;
@property (nonatomic, retain)NSMutableArray *viewsArray;
@property (nonatomic, retain)NSMutableArray *addButtonViews;
@property (nonatomic, retain)NSMutableArray *deleteButtonViews;
@property (nonatomic, assign)NSInteger pagesNum;
@property (nonatomic, assign)NSInteger gridCellNumPerPage;
- (void)reloadCell:(BOOL)animated shouldReArrange:(BOOL)should;
- (CGFloat)realHeight;
@end
