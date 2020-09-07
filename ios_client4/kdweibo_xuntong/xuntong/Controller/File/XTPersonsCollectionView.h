//
//  XTPersonsCollectionView.h
//  kdweibo
//
//  Created by lichao_liu on 15/3/9.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTPersonHeaderCanDeleteView.h"

@interface XTPersonsCollectionView : UICollectionView
@property (nonatomic, weak) id<XTPersonHeaderViewDelegate> deleteDelegate;
- (void)setPersonsArray:(NSArray *)personArray;

@end
