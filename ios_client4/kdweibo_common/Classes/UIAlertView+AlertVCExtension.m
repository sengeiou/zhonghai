//
//  UIAlertView+AlertVCExtension.m
//  kdweibo_common
//
//  Created by fang.jiaxin on 2017/9/21.
//  Copyright © 2017年 kingdee. All rights reserved.
//

#import "UIAlertView+AlertVCExtension.h"
#import <objc/runtime.h>

static NSMutableArray *alertArray;
@implementation UIAlertView (AlertVCExtension)

+(void)load
{
    void (^__instanceMethod_swizzling)(Class, SEL, SEL) = ^(Class cls, SEL orgSEL, SEL swizzlingSEL){
        Method orgMethod = class_getInstanceMethod(cls, orgSEL);
        Method swizzlingMethod = class_getInstanceMethod(cls, swizzlingSEL);
        if (class_addMethod(cls, orgSEL, method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod))) {

            class_replaceMethod(cls, orgSEL, method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod));
        }
        else
        {
            method_exchangeImplementations(orgMethod, swizzlingMethod);
        }

    };

    if(isAboveiOS8)
    {
        __instanceMethod_swizzling([self class], @selector(init), @selector(_KDD_init));
        
        __instanceMethod_swizzling([self class], @selector(initWithTitle:message:delegate:cancelButtonTitle:otherButtonTitles:), @selector(_KDD_initWithTitle:message:delegate:cancelButtonTitle:otherButtonTitles:));
        
        __instanceMethod_swizzling([self class], @selector(show), @selector(_KDD_show));
        
        __instanceMethod_swizzling([self class], @selector(addButtonWithTitle:), @selector(_KDD_addButtonWithTitle:));
        
        __instanceMethod_swizzling([self class], @selector(dismissWithClickedButtonIndex:animated:), @selector(_KDD_dismissWithClickedButtonIndex:animated:));
        
        __instanceMethod_swizzling([self class], @selector(setTitle:), @selector(_KDD_setTitle:));
        
        __instanceMethod_swizzling([self class], @selector(setMessage:), @selector(_KDD_setMessage:));
    }
}

-(id)_KDD_init
{
    return [self initWithTitle:nil message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
}


-(id)_KDD_initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    //按钮数组
    NSMutableArray* keys = [NSMutableArray array];
    va_list argList;
    if(otherButtonTitles){
        
        [keys addObject:otherButtonTitles];
        va_start(argList, otherButtonTitles);
        id arg;
        while ((arg = va_arg(argList, id))) {
            [keys addObject:arg];
        }
    }
    va_end(argList);
    
    //处理可变参数给父类传值，最多只能传递10个值
    NSString *title0,*title1 ,*title2,*title3,*title4,*title5,*title6,*title7,*title8,*title9;
    NSInteger keyCount = keys.count;
    NSInteger keyIndex = 0;
    if(keyCount > keyIndex)
        title0 = keys[keyIndex];
    
    keyIndex++;
    if(keyCount > keyIndex)
        title1 = keys[keyIndex];
    
    keyIndex++;
    if(keyCount > keyIndex)
        title2 = keys[keyIndex];
    
    keyIndex++;
    if(keyCount > keyIndex)
        title3 = keys[keyIndex];
    
    keyIndex++;
    if(keyCount > keyIndex)
        title4 = keys[keyIndex];
    
    keyIndex++;
    if(keyCount > keyIndex)
        title5 = keys[keyIndex];
    
    keyIndex++;
    if(keyCount > keyIndex)
        title6 = keys[keyIndex];
    
    keyIndex++;
    if(keyCount > keyIndex)
        title7 = keys[keyIndex];
    
    keyIndex++;
    if(keyCount > keyIndex)
        title8 = keys[keyIndex];
    
    keyIndex++;
    if(keyCount > keyIndex)
        title9 = keys[keyIndex];

    
    
    [self _KDD_initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:title0,title1,title2,title3,title4,title5,title6,title7,title8,title9, nil];
    if(self)
    {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        self.alertVC = alertVC;
        
        __weak __typeof(self) weakSelf = self;
        if(cancelButtonTitle)
        {
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
                [weakSelf callbackWithIndex:weakSelf.cancelButtonIndex];
            }];
            [alertVC addAction:cancelAction];
        }
        
        
        
        __block NSInteger buttonIndex = self.firstOtherButtonIndex;
        [keys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSInteger index = buttonIndex;
            UIAlertAction *action = [UIAlertAction actionWithTitle:obj style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"=============clickIndex %zi=============",index);
                [weakSelf callbackWithIndex:index];
            }];
            [alertVC addAction:action];
            
            //按钮index+1
            buttonIndex++;
        }];
    }
    
    //全局保存下，不然会被释放
    if(alertArray == nil)
        alertArray = [NSMutableArray array];
    [alertArray addObject:self];
    
    return self;
}

-(void)callbackWithIndex:(NSInteger)index
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
        [self.delegate alertView:self clickedButtonAtIndex:index];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)])
        [self.delegate alertView:self didDismissWithButtonIndex:index];
    
    
    if(index == self.cancelButtonIndex)
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(alertViewCancel:)])
            [self.delegate alertViewCancel:self];
    }
    
    //释放对象
    [alertArray removeObject:self];
}

-(void)_KDD_show
{
    // bug 11683
    //首位之前先把其他alert dismiss
//    if (alertArray.count > 1) {
//        [alertArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if (idx == (alertArray.count-1)) {
//                return;
//            }
//            UIAlertView *alertView = obj;
//            if ([alertView isKindOfClass:[UIAlertView class]]) {
//                [alertView dismissWithClickedButtonIndex:alertView.cancelButtonIndex animated:YES];
//            }
//        }];
//    }

    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if(!rootVC)
    {
        rootVC = [[((NSObject *)([UIApplication sharedApplication].delegate)) valueForKey:@"window"] valueForKey:@"rootViewController"];
    }
    UIViewController *presentedViewController = rootVC.presentedViewController;
    if(presentedViewController)
        rootVC = presentedViewController;
    else
    {
        if([rootVC isKindOfClass:NSClassFromString(@"RESideMenu")])
        {
            UINavigationController *nav = [[rootVC valueForKey:@"leftMenuViewController"] valueForKey:@"nav_"];
            if(nav.view.superview)
                rootVC = nav;
        }
    }
    [self showInVC:rootVC];
}

-(void)showInVC:(UIViewController *)vc
{
    if(vc)
        [vc presentViewController:self.alertVC animated:YES completion:nil];
}

-(NSInteger)_KDD_addButtonWithTitle:(NSString *)title
{
    __weak __typeof(self) weakSelf = self;
    NSInteger index = [self _KDD_addButtonWithTitle:title];
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"=============clickIndex %zi=============",index);
        [weakSelf callbackWithIndex:index];
    }];
    [self.alertVC addAction:action];
    return index;
}

-(void)_KDD_setTitle:(NSString *)title
{
    [self _KDD_setTitle:title];
    self.alertVC.title = title;
}

-(void)_KDD_setMessage:(NSString *)message
{
    [self _KDD_setMessage:message];
    self.alertVC.message = message;
}

-(void)_KDD_dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    if(self.alertVC)
        [self.alertVC dismissViewControllerAnimated:YES completion:nil];
}

-(UIAlertController *)alertVC
{
    return objc_getAssociatedObject(self, "alertVC");
}

-(void)setAlertVC:(UIAlertController *)alertVC
{
    objc_setAssociatedObject(self, "alertVC", alertVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
