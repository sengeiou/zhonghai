//
//  KDSignInClient.h
//  kdweibo
//
//  Created by AlanWong on 14/11/7.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "BOSConnect.h"
#import "KDSignInRecord.h"

@interface KDSignInClient : BOSConnect
-(void)searchPOIWithLatitude:(double)latitude longitude:(double)longitude;

- (void)getShortSignInShareUrl:(KDSignInRecord *)record;


- (void)searchAtteShareLinkWithRecord:(KDSignInRecord *)record;
@end
