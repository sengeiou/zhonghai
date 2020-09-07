// Copyright (c) 2016 rickytan <ricky.tan.xin@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <objc/runtime.h>

#import "UIViewController+RTRootNavigationController.h"
#import "RTRootNavigationController.h"

@implementation UIViewController (RTRootNavigationController)
@dynamic rt_disableInteractivePop;

- (void)setRt_disableInteractivePop:(BOOL)rt_disableInteractivePop
{
    objc_setAssociatedObject(self, @selector(rt_disableInteractivePop), @(rt_disableInteractivePop), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)rt_disableInteractivePop
{
    return [objc_getAssociatedObject(self, @selector(rt_disableInteractivePop)) boolValue];
}

- (Class)rt_navigationBarClass
{
    return nil;
}

- (RTRootNavigationController *)rt_navigationController
{
    UIViewController *vc = self;
    while (vc && ![vc isKindOfClass:[RTRootNavigationController class]]) {
        vc = vc.navigationController;
    }
    return (RTRootNavigationController *)vc;
}

- (UIBarButtonItem *)customBackItemWithTarget:(id)target
                                       action:(SEL)action
{
    UIButton *defaultBackButton;
    if (CGColorEqualToColor(self.navigationController.navigationBar.barTintColor.CGColor, FC6.CGColor)) {
        defaultBackButton = [UIButton backBtnInWhiteNavWithTitle:self.backBtnTitle inNav:YES];
        [defaultBackButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        defaultBackButton = [UIButton backBtnInBlueNavWithTitle:self.backBtnTitle inNav:YES];
        [defaultBackButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    return [[UIBarButtonItem alloc] initWithCustomView:defaultBackButton];
}

- (NSString *)backBtnTitle {

    UIViewController *firstVC = [(RTContainerController *)self.rt_navigationController.viewControllers.firstObject contentViewController];

    Class timelineClass = NSClassFromString(@"XTTimelineViewController");
    Class contactClass = NSClassFromString(@"XTContactContentViewController");
    Class appClass = NSClassFromString(@"KDApplicationViewController");
    Class meClass = NSClassFromString(@"KDMeVC");
    if ([firstVC isKindOfClass:timelineClass] || [firstVC isKindOfClass:contactClass] ||[firstVC isKindOfClass:appClass] ||[firstVC isKindOfClass:meClass]) {
        if ([self.rt_navigationController.viewControllers count] > 1) {
            if ([(RTContainerController *)self.rt_navigationController.viewControllers[1] contentViewController] == self) {
                if (firstVC) {
                    if (firstVC.title) {
                        return firstVC.title;
                    }
                    if (firstVC.navigationItem.title) {
                        return firstVC.navigationItem.title;
                    }
                }
            }
        }

    }
    return @"返回";
}




@end
