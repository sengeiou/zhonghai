//
//  KDPhotoSheetView.m
//  kdweibo_common
//
//  Created by kingdee on 2017/9/25.
//  Copyright © 2017年 kingdee. All rights reserved.
//

#import "KDPhotoSheetView.h"

@implementation KDPhotoSheetModel
- (instancetype)initWithTitle:(NSString *)title tapBlock:(TapBlock)block {
    self = [super init];
    if (self) {
        self.title = title;
        self.tap = block;
    }
    return self;
}

@end


#define cellHeight 50
#define mainScreenW [UIScreen mainScreen].bounds.size.width
#define mainScreenH [UIScreen mainScreen].bounds.size.height
#define margin 8

@interface KDPhotoSheetView()
@property (nonatomic, strong)NSArray *array; // actionArray

@end

@implementation KDPhotoSheetView

- (instancetype)initWithPhotoSheetModelArray:(NSArray *)array {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
        self.array = array;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIView *containerView = [[UIView alloc] init];
    containerView.frame = CGRectMake(margin, mainScreenH - margin*2 - cellHeight*(self.array.count + 1), mainScreenW - margin * 2, cellHeight*self.array.count);
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.layer.cornerRadius = 8;
    containerView.layer.masksToBounds = YES;
    
    [self addSubview:containerView];
    
    [self.array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KDPhotoSheetModel *action = obj;
        UIButton *actionBtn = [self buttonWithTitle:action.title];
        actionBtn.frame = CGRectMake(0, cellHeight * idx, actionBtn.frame.size.width, actionBtn.frame.size.height);
        actionBtn.tag = idx;
        [actionBtn addTarget:self action:@selector(tapActionBtn:) forControlEvents:UIControlEventTouchUpInside];
        [containerView addSubview:actionBtn];
        
        if (idx == (self.array.count -1)) {
            return;
        }
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, cellHeight * (idx+1) - 1, actionBtn.frame.size.width, 0.5)];
        lineView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.6];
        [containerView addSubview:lineView];
        
    }];
    
    
    UIView *cancelView = [[UIView alloc] init];
    cancelView.frame = CGRectMake(margin, mainScreenH - margin - cellHeight, mainScreenW - margin * 2, cellHeight);
    cancelView.backgroundColor = [UIColor whiteColor];
    cancelView.layer.cornerRadius = 8;
    cancelView.layer.masksToBounds = YES;
    [self addSubview:cancelView];
    
    UIButton *cancelBtn = [self buttonWithTitle:ASLocalizedString(@"Global_Cancel")];
    [cancelBtn addTarget:self action:@selector(hidePhotoSheet) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.frame = CGRectMake(0, 0, cancelBtn.frame.size.width, cancelBtn.frame.size.height);
    [cancelView addSubview:cancelBtn];
    
}

- (UIButton *)buttonWithTitle:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0.0, 0.0, mainScreenW - 2*margin, cellHeight)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [btn setTitleColor:[UIColor colorWithRed:60/255.0 green:186/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal]; // FC5 3CBAFF
    [btn setTitleColor:[UIColor colorWithRed:48/255.0 green:142/255.0 blue:194/255.0 alpha:1.0] forState:UIControlStateHighlighted]; // FC7 308EC2
    [btn setBackgroundColor:[UIColor whiteColor]];
    return btn;
}

- (void)tapActionBtn:(UIButton *)sender {
    NSInteger index = sender.tag;
    KDPhotoSheetModel *model = [self.array objectAtIndex:index];
    if (model.tap) {
        model.tap();
    }
    [self hidePhotoSheet];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hidePhotoSheet];
}

- (void)showPhotoSheet {
    [[UIApplication sharedApplication].delegate.window addSubview:self];
}

- (void)hidePhotoSheet {
    [self removeFromSuperview];
}

@end
