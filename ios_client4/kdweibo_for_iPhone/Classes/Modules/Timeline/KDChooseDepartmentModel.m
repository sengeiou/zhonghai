//
//  KDChooseDepartmentModel.m
//  kdweibo
//
//  Created by DarrenZheng on 14-7-10.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDChooseDepartmentModel.h"
@interface KDChooseDepartmentModel()
@property (strong , nonatomic) NSArray *childrenDep;   //子部门
@end


@implementation KDChooseDepartmentModel

- (void)dealloc {
    safe_release(_strID);
    safe_release(_strParentID);
    safe_release(_strName);
    safe_release(_strWeights);
}

void safe_release(id obj) {
    if (obj) {
        obj = nil;
    }
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]])
    {
        return NO;
    }
    if (![self.strID isEqualToString:[(KDChooseDepartmentModel *)object strID]])
    {
        return NO;
    }
    return YES;
}


- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        id strID = [dictionary objectForKey:@"id"];
        id strName = [dictionary objectForKey:@"orgName"];
        id strParentID = [dictionary objectForKey:@"parentId"];
        id strWeights = [dictionary objectForKey:@"weights"];
        id bIsLeaf = [dictionary objectForKey:@"isLeaf"];
        id personCount = [dictionary objectForKey:@"personCount"];
        
        
        if (![strID isKindOfClass:[NSNull class]] && strID) {
            self.strID = strID;
        }
        if (![strName isKindOfClass:[NSNull class]] && strName) {
            self.strName = strName;
        }
        if (![strParentID isKindOfClass:[NSNull class]] && strParentID) {
            self.strParentID = strParentID;
        }
        if (![strWeights isKindOfClass:[NSNull class]] && strWeights) {
            self.strWeights = strWeights;
        }
        if (![bIsLeaf isKindOfClass:[NSNull class]] && bIsLeaf) {
            self.bIsLeaf = [bIsLeaf boolValue];
        }
        if (![personCount isKindOfClass:[NSNull class]] && personCount) {
            self.personCount = [personCount integerValue];
        }
        else {
            self.personCount = 0;
        }
    }
    return self;
}

- (void)setChecked:(BOOL)checked {
    _checked = checked;
    
}

- (NSArray *)findChildrenWithAllDepartments:(NSArray *)departments {
    if (self.childrenDep) return self.childrenDep;
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (KDChooseDepartmentModel *model in departments) {
        if ([model.strParentID isEqualToString:self.strID]) {
            [temp addObject:model];
            //            model.parentModel = self;
        }
    }
    _childrenDep = temp.copy;
    return _childrenDep;
}

- (void)setTheWholeDepartmentChecked:(BOOL)checked {
    self.checked = checked;
    for (KDChooseDepartmentModel *child in _childrenDep) {
        [child setTheWholeDepartmentChecked:checked];
    }
}


@end
