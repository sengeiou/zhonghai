//
//  KKCutTool.m
//  kdweibo
//
//  Created by kingdee on 2017/8/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "KKCutTool.h"
#import "KKCutGridView.h"
#import "UIImage+Rotate.h"

@interface KKCutTool()

@end

@implementation KKCutTool{
    //裁剪view
    KKCutGridView *_gridView;
    //底部菜单
    UIView *_menuContainer;
}

#pragma mark- implementation
- (void)setup{
    _menuContainer = [[UIView alloc] initWithFrame:self.editor.menuView.frame];
    _menuContainer.backgroundColor = self.editor.menuView.backgroundColor;
    [self.editor.view addSubview:_menuContainer];
    
    [self setMenu];
    [self setGridView];
    
    _menuContainer.transform = CGAffineTransformMakeTranslation(0, self.editor.view.frame.size.height-_menuContainer.frame.origin.y);
    [UIView animateWithDuration:kImageToolAnimationDuration
                     animations:^{
                         _menuContainer.transform = CGAffineTransformIdentity;
                     }];
    
}

- (void)cleanup{
    [self.editor resetZoomScaleWithAnimated:YES];
    [_gridView removeFromSuperview];
    
    [UIView animateWithDuration:kImageToolAnimationDuration
                     animations:^{
                         _menuContainer.transform = CGAffineTransformMakeTranslation(0, self.editor.view.frame.size.height-_menuContainer.frame.origin.y);
                     }
                     completion:^(BOOL finished) {
                         [_menuContainer removeFromSuperview];
                     }];
}

-(void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock{
    CGFloat zoomScale = self.editor.imageView.frame.size.width / self.editor.imageView.image.size.width;
    CGRect rct = _gridView.clippingRect;
    rct.size.width  /= zoomScale;
    rct.size.height /= zoomScale;
    rct.origin.x    /= zoomScale;
    rct.origin.y    /= zoomScale;
    
    CGPoint origin = CGPointMake(-rct.origin.x, -rct.origin.y);
    UIGraphicsBeginImageContextWithOptions(rct.size, NO, self.editor.imageView.image.scale);
    [self.editor.imageView.image drawAtPoint:origin];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    completionBlock(img, nil, nil);
}

- (void)setMenu {
    UIButton *btn = [self buttonWithTitle:ASLocalizedString(@"KKCutTool_rotate") image:[UIImage imageNamed:@"graffiti_rotate"]];
    btn.frame = CGRectMake(120, 20, 75, 40);
    btn.center = CGPointMake([UIScreen mainScreen].bounds.size.width/3 * 2, 18);
    [btn addTarget:self action:@selector(rotate) forControlEvents:UIControlEventTouchUpInside];
    [_menuContainer addSubview:btn];
    
    UIButton *btnRestore = [self buttonWithTitle:ASLocalizedString(@"KKCutTool_restore") image:[UIImage imageNamed:@"graffiti_rotateReturn"]];
    btnRestore.frame = CGRectMake(20, 20, 75, 40);
    btnRestore.center = CGPointMake([UIScreen mainScreen].bounds.size.width/3, 18);
    [btnRestore addTarget:self action:@selector(restore) forControlEvents:UIControlEventTouchUpInside];
    [_menuContainer addSubview:btnRestore];
    
    UIButton *okBtn = [UIButton blueBtnWithTitle:ASLocalizedString(@"KKCutTool_cut")];
    okBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 12 - 75, 36+8, 75, 26);
    [okBtn addTarget:self action:@selector(okClick) forControlEvents:UIControlEventTouchUpInside];
    [_menuContainer addSubview:okBtn];
    
}

- (UIButton *)buttonWithTitle:(NSString *)title image:(UIImage *)image {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.textColor = [UIColor whiteColor];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setImage:image forState:UIControlStateNormal];
    btn.imageEdgeInsets = UIEdgeInsetsMake(0,-5, 0, 0);
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -5);
    
    return btn;
}

- (void)setGridView {
    if (_gridView) {
        [_gridView removeFromSuperview];
    }
    
    [self.editor fixZoomScaleWithAnimated:YES];
    _gridView = [[KKCutGridView alloc] initWithSuperview:self.editor.imageView.superview frame:self.editor.imageView.frame];
    _gridView.backgroundColor = [UIColor clearColor];
    _gridView.bgColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    _gridView.gridColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    _gridView.clipsToBounds = NO;
    
}

- (void)rotate {
    UIImage *rotateImage = [self.editor.imageView.image rotate:UIImageOrientationRight];
    [self.editor refreshImageViewWith:rotateImage];
    [self setGridView];
}

- (void)restore {
    [self.editor refreshImageViewWith:_tmpImage];
    [self.editor fixZoomScaleWithAnimated:YES];
    [self setGridView];
}

- (void)okClick {
    [self.editor clearBoard];
    [self.editor pushedDoneBtn:nil];
}

@end

