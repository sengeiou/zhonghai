//
//  KDSubscribeCollectionView.h
//  kdweibo
//
//  Created by wenbin_su on 15/9/14.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^subscribeCollectionCellDelegate)(PersonSimpleDataModel *data);
@interface KDSubscribeCollectionView : UICollectionView<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSMutableArray *subscribeDataArray;
@property (nonatomic, copy) subscribeCollectionCellDelegate subscribeCellDelegate;
@end