//
//  XTCompanyDelegate.h
//  XT
//
//  Created by Gil on 14-4-2.
//  Copyright (c) 2014年 Kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDLinkInviteConfig.h"

@class XTOpenCompanyDataModel;

@protocol XTCompanyDelegate <NSObject>

@optional
- (void)companyDidSelect:(id)viewController company:(XTOpenCompanyDataModel *)company;
- (void)companyDidCreate:(id)createCompanyViewController company:(XTOpenCompanyDataModel *)company;
- (BOOL)companyNeedInvitePerson;
@end

@interface XTOpenCompanyListDataModel : BOSBaseDataModel <KDLinkInviteDataSource>
@property (nonatomic, strong) NSString *openId;
@property (nonatomic, strong) NSArray *companys;
@property (nonatomic, strong) NSArray *authstrCompanys;

@end
@interface XTOpenCompanyDataModel : BOSBaseDataModel
@property (nonatomic, strong) NSString *companyId;
@property (nonatomic, strong) NSString *companyName;
@end
