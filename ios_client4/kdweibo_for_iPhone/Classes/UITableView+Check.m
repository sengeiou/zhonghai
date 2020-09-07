//
//  UITableView+Check.m
//  kdweibo
//
//  Created by fang.jiaxin on 16/12/15.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "UITableView+Check.h"
#import "UITableViewCell+Check.h"

@implementation UITableView (Check)
-(BOOL)showCheck
{
    return [objc_getAssociatedObject(self, @selector(showCheck)) boolValue];
}

-(void)setShowCheck:(BOOL)showCheck
{
    objc_setAssociatedObject(self, @selector(showCheck), [NSNumber numberWithBool:showCheck], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.checkStateDic = [NSMutableDictionary dictionary];
    [self reloadData];
}


-(NSMutableDictionary *)checkStateDic
{
    return objc_getAssociatedObject(self, @selector(checkStateDic));
}

-(void)setCheckStateDic:(NSMutableDictionary *)checkStateDic
{
    objc_setAssociatedObject(self, @selector(checkStateDic), checkStateDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UITableViewCheckBlock)checkBlock
{
    return objc_getAssociatedObject(self, @selector(checkBlock));
}

-(void)setCheckBlock:(UITableViewCheckBlock)checkBlock
{
    objc_setAssociatedObject(self, @selector(checkBlock), [checkBlock copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSArray *)getCheckArray
{
    NSMutableArray *checkArray = [NSMutableArray array];
    NSMutableDictionary *checkStateDic = self.checkStateDic;
    [checkStateDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        BOOL isCheck = [obj boolValue];
        if(isCheck)
            [checkArray addObject:key];
    }];
    
    return [NSArray arrayWithArray:checkArray];
}

//-(void)dealloc
//{
//    self.checkStateDic = nil;
//}
@end
