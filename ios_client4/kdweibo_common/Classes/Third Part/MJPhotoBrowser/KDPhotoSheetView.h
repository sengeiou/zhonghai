//
//  KDPhotoSheetView.h
//  kdweibo_common
//
//  Created by kingdee on 2017/9/25.
//  Copyright © 2017年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TapBlock)();
@interface KDPhotoSheetModel : NSObject
@property (nonatomic, strong)NSString *title;
@property (nonatomic, strong)TapBlock tap;

- (instancetype)initWithTitle:(NSString *)title tapBlock:(TapBlock)block;

@end

@interface KDPhotoSheetView : UIView

- (instancetype)initWithPhotoSheetModelArray:(NSArray *)array;
- (void)showPhotoSheet;
- (void)hidePhotoSheet;

@end
