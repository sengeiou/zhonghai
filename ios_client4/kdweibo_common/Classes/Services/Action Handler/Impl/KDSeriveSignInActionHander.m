//
//  KDSeriveSignInActionHander.m
//  kdweibo_common
//
//  Created by Tan yingqi on 13-8-26.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDSeriveSignInActionHander.h"
#import "NSDictionary+Additions.h"
#import "KDSignInSchema.h"
#import "KDSignInRecord.h"
#import "KDGroup.h"

#define KD_SERVICE_TASK_ACTION_PATH	@"/signId/"


@implementation KDSeriveSignInActionHander
+ (NSString *)supportedServiceActionPath {
    return KD_SERVICE_TASK_ACTION_PATH;
}

- (NSData *)contentForFile:(NSString *)fileName {
    NSBundle *bundle = [NSBundle bundleForClass:[KDSeriveSignInActionHander class]];
    // NSString *filePath = [bundle pathForResource:fileName ofType:@"json"];
    NSString *filePath = [[bundle resourcePath] stringByAppendingPathComponent:fileName];
    return [NSData dataWithContentsOfFile:filePath];
}

- (void)getSignList:(KDServiceActionInvoker *)invoker {

     [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/list_sign.json"];
     
     [super doGet:invoker configBlock:nil
     didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
         [self _asyncParseSignin:response completionBlock:^(NSDictionary * records) {
             [super didFinishInvoker:invoker results:records request:request response:response];
         }];
     }];
   
}

- (void)sign:(KDServiceActionInvoker *)invoker {
    
    KDSignInRecord *record = [invoker.query propertyForKey:@"signin"];
    [self bindSign:record toQuery:invoker.query];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/sign.json"];
    
    [super doPost:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
        [self _asyncParseSignin:response completionBlock:^(NSDictionary * records) {
            [super didFinishInvoker:invoker results:records request:request response:response];
        }];
    }];

}

- (void)checkHasSetPoint:(KDServiceActionInvoker *)invoker {
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/check_has_set_point.json"];
    
    [super doGet:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *requestWrapper, KDResponseWrapper *responseWrapper, BOOL failed) {
        [self _parseCheckHasSetPoint:responseWrapper completionBlock:^(NSNumber * result)  {
            [super didFinishInvoker:invoker results:result request:requestWrapper response:responseWrapper];
            
        }];
    }];
}

- (void)resign:(KDServiceActionInvoker *)invoker {
    
    KDSignInRecord *record = [invoker.query propertyForKey:@"signin"];
    [self bindSign:record toQuery:invoker.query];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/update_sign.json"];
    
    [super doPost:invoker configBlock:nil  didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
        [self _asyncParseSignin:response completionBlock:^(NSDictionary * records) {
            [super didFinishInvoker:invoker results:records request:request response:response];
        }];
    }];

}

- (void)deleteSign:(KDServiceActionInvoker *)invoker {
    KDSignInRecord *record = [invoker.query propertyForKey:@"signin"];
    [invoker.query setParameter:@"id" stringValue:record.singinId];
    
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/del_sign.json"];
    
    [super doPost:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
        [self _asyncParseSignin:response completionBlock:^(NSDictionary * records) {
            [super didFinishInvoker:invoker results:records request:request response:response];
        }];
    }];
}


#pragma mark - 绑定帐号
- (void)bindingDevice:(KDServiceActionInvoker *)invoker
{
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/mobile/bindingDevice.json"];
    [super doGet:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *requestWrapper, KDResponseWrapper *responseWrapper, BOOL failed) {
        NSDictionary *entities = [responseWrapper responseAsJSONObject];
        [super didFinishInvoker:invoker results:entities request:requestWrapper response:responseWrapper];
    }];
}

- (void)_parseCheckHasSetPoint : (KDResponseWrapper *)response
               completionBlock : (void(^)(NSNumber *))block {
    if ([response isCancelled]) {
        return;
    }
    NSDictionary *tempDic = [response responseAsJSONObject];
    NSNumber *result = [tempDic valueForKey:@"isSetPoint"];
    //id result = nil;
    block(result);
}

/**
 *  解析返回的json内容
 *
 *  @param response
 *  @param block
 */
- (void)_asyncParseSignin:(KDResponseWrapper *)response
          completionBlock:(void (^)(NSDictionary *))block {
    if ([response isCancelled]) {
        return;
    }
    if (![response isValidResponse]) {
        block(nil);
        return;
    }
  
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        
        NSDictionary *entities = [response responseAsJSONObject];

        BOOL success = [entities boolForKey:@"success"];
        NSString *errorMessage = [entities stringForKey:@"errorMessage"];
        NSDictionary *data = [entities objectForKey:@"data"];
        
        KDSignInSchema *schema = nil;
        NSArray *array = nil;
        
        if ((NSNull *)data != [NSNull null]) {
            KDSignSchemaParser *parser = [super parserWithClass:[KDSignSchemaParser class]];
            schema = [parser parse:data];
            array = [data objectForKey:@"signs"];
            if(!array && (NSNull *)array != [NSNull null]) {
                array = @[data];
            }
        }
        
        NSArray *signs = nil;
        if (array  && (NSNull *)array != [NSNull null]) {
            KDSignInParser *parser2 = [super parserWithClass:[KDSignInParser class]];
            signs = [parser2 parseSignIns:array];
        }
        
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@(success) forKey:@"success"];
        if (errorMessage) {
            [result setObject:errorMessage forKey:@"errorMessage"];
        }
        if (schema) {
            [result setObject:schema forKey:@"schema"];
        }
        if (signs) {
            [result setObject:signs forKey:@"singIns"];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            block(result);
        });
    });
}

/**
 *  将签到数据绑定到query
 *
 *  @param record
 *  @param query
 */
- (void)bindSign:(KDSignInRecord *)record toQuery:(KDQuery *)query {
    if(record.singinId.length > 0) {
        [query setParameter:@"id" stringValue:record.singinId];
    }
    if (record.message) {
        [query setParameter:@"remark" stringValue:record.message];
    }
   
    [query setParameter:@"latitude" doubleValue:record.latitude];
    [query setParameter:@"longitude" doubleValue:record.longitude];
    [query setParameter:@"featurename" stringValue:record.featurename];
    NSString *featureNameDetail = [record propertyForKey:@"featurenamedetail"];
    if (featureNameDetail) {
        [query setParameter:@"featurenamedetail" stringValue:featureNameDetail];
    }
}

// 增加签到共享范围的网络请求 2013.10.17 Tan Yingqi

- (void)deleteShareGroup:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/delete/user_group.json"];
    [super doPost:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
         NSDictionary *entities = [response responseAsJSONObject];
        [super didFinishInvoker:invoker results:entities request:request response:response];
      }];
}

- (void)getSelectedShareGroups:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/user_selected_groups.json"];
    
    [super doGet:invoker configBlock:nil
      didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
    [self asyncParseSelectedShareGroups:response completionBlock:^(NSDictionary * result) {
        [super didFinishInvoker:invoker results:result request:request response:response];
    }];
  }];

}

//同时获取分享小组和未分享小组
- (void)getSelectedAndDeSelectedGroups:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/list_group.json"];
    
    [super doGet:invoker configBlock:nil
     didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
    [self asyncParseSelectedAndDeSelectedGroups:response completionBlock:^(NSDictionary * result) {
        [super didFinishInvoker:invoker results:result request:request response:response];
    }];
   }];
}


- (void)asyncParseSelectedShareGroups:(KDResponseWrapper *)response
          completionBlock:(void (^)(NSDictionary *))block {
    
    if (![response isValidResponse]) {
        block(nil);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        DLog(@"response = %@",[response responseAsString]);
        NSDictionary *result = nil;
        
        NSDictionary *entities = [response responseAsJSONObject];
        
        BOOL success = [entities boolForKey:@"success"];
        NSString *errorMessage = [entities stringForKey:@"errorMessage"];
        if (!errorMessage) {
            errorMessage = @"";
        }
        //NSDictionary *data = [entities objectForKey:@"data"];
        NSDictionary *data = [entities objectNotNSNullForKey:@"data"];
        id groups = nil;
        if (data) {
            NSArray *groupData = [data objectNotNSNullForKey:@"groups"];
            KDGroupParser *parser = [super parserWithClass:[KDGroupParser class]];
            groups = [parser parseAsGroupList:groupData];
        }
        if (groups) {
             result = @{@"success":@(success),@"errorMessage":errorMessage,@"groups":groups};
        }else {
             result = @{@"success":@(success),@"errorMessage":errorMessage};
        }
    
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            block(result);
        });
    });
}

- (void)asyncParseSelectedAndDeSelectedGroups:(KDResponseWrapper *)response
 completionBlock:(void (^)(NSDictionary *))block {
     if (![response isValidResponse]) {
         block(nil);
         return;
     }
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
         DLog(@"response = %@",[response responseAsString]);
         
         NSDictionary *result = nil;
         
         NSDictionary *entities = [response responseAsJSONObject];
         BOOL success = [entities boolForKey:@"success"];
         NSString *errorMessage = [entities stringForKey:@"errorMessage"];
         if (!errorMessage) {
             errorMessage = @"";
         }
        
         BOOL isCompanySeleted = NO;
         NSArray *groups = nil;
         NSArray *unGroups = nil;
         if (success) {
             NSDictionary *data = [entities objectNotNSNullForKey:@"data"];
             if (data) {
                {
                     KDGroupParser *parser = [super parserWithClass:[KDGroupParser class]];
                     NSArray *groupsData = [data objectNotNSNullForKey:@"groups"];
                     NSArray *unGroupData = [data objectNotNSNullForKey:@"unGroups"];
                     if (groupsData) {
                         groups = [parser parseAsGroupList:groupsData];
                     }
                     if (unGroupData) {
                         unGroups = [parser parseAsGroupList:unGroupData];
                     }
                     
                 }
             }
             if (!groups) { //如果没有返回默认选择大厅
                 KDGroup *group = [[KDGroup alloc] init];
                 group.groupId = @"-1";
                 group.name = ASLocalizedString(@"KDSeriveSignInActionHander_weibo_hall");
                 groups = [NSArray arrayWithObject:group];
             }
            
         }
         NSMutableArray *groupsM = nil;
         NSMutableArray *unGroupsM = nil;
         if (success) {   //决定是否大厅在所选组内
             if (groups) {
                 groupsM = [NSMutableArray arrayWithArray:groups];
             }
             if (unGroups) {
                 unGroupsM = [NSMutableArray arrayWithArray:unGroups];
             }
            __block NSInteger companyIndex = NSNotFound;
            [groupsM enumerateObjectsUsingBlock:^(id obj,NSUInteger idx,BOOL *stop) {
            if ([[(KDGroup*)obj groupId] isEqualToString:@"-1"]) {
                companyIndex = idx;
                *stop = YES;
                }
              }];
              if (companyIndex != NSNotFound) {
                isCompanySeleted = YES;
                [groupsM removeObjectAtIndex:companyIndex];
                if ([groupsM count] == 0) {
                    groupsM = nil;
                 }
               }
            }
        
        result = @{@"success":@(success),@"errorMessage":errorMessage,
                    @"groups":groupsM?groupsM:[NSNull null],
                    @"unGroups":unGroupsM?unGroupsM:[NSNull null],
                    @"isCompanySelected":@(isCompanySeleted)};
         dispatch_sync(dispatch_get_main_queue(), ^(void){
             block(result);
         });
     });
 }

- (void)updateSignInRangeShare:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/update/user_group.json"];
    [super doPost:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
        DLog(@"response  =%@",[response responseAsString]);
        NSDictionary *entities = [response responseAsJSONObject];
        [super didFinishInvoker:invoker results:entities request:request response:response];
        
    }];
}

- (void)setSignInGroup:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/attSetGroup.json"];
    
    [super doPost:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *requestWrapper, KDResponseWrapper *responseWrapper, BOOL failed) {
        
        DLog(@"response = %@",[responseWrapper responseAsString]);
        NSDictionary *entities = [responseWrapper responseAsJSONObject];
        [super didFinishInvoker:invoker results:entities request:requestWrapper response:responseWrapper];
    }];
}

- (void)getSignInGroupList:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/attSetGroup.json"];
    
    [super doPost:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *requestWrapper, KDResponseWrapper *responseWrapper, BOOL failed) {
        
        DLog(@"response = %@",[responseWrapper responseAsString]);
        NSDictionary *entities = ![responseWrapper isValidResponse] ? nil : [responseWrapper responseAsJSONObject];
        [super didFinishInvoker:invoker results:entities ? entities[@"data"] : nil request:requestWrapper response:responseWrapper];
    }];
}


- (void)setSignInFeedbackSetting:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/attendance-feedback-setting.json"];
    
    [super doPost:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *requestWrapper, KDResponseWrapper *responseWrapper, BOOL failed) {
        
        DLog(@"response = %@",[responseWrapper responseAsString]);
        NSDictionary *entities = [responseWrapper responseAsJSONObject];
        [super didFinishInvoker:invoker results:entities request:requestWrapper response:responseWrapper];
    }];
}

- (void)getSignInFeedbackSetting:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/attendance-feedback-setting.json"];
    
    [super doGet:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
        
        DLog(@"response = %@",[response responseAsString]);
        NSDictionary *entities = [response responseAsJSONObject];
        [super didFinishInvoker:invoker results:entities request:request response:response];
    }];
}

- (void)getAttendanceSetInfo:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/attendance-set-info.json"];
    
    
    [super doGet:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
        DLog(@"response = %@",[response responseAsString]);
        NSDictionary *entities = [response responseAsJSONObject];
        [super didFinishInvoker:invoker results:entities request:request response:response];
    }];
}

- (void)getRemindList:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/get/clockin_new_remind.json"];
    [super doGet:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
        DLog(@"response = %@",[response responseAsString]);
        NSDictionary *entities = [response responseAsJSONObject];
        [super didFinishInvoker:invoker results:entities request:request response:response];
    }];
}

- (void)setRemind:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/set/clockin_new_remind.json"];
    [super doPost:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
        DLog(@"response = %@",[response responseAsString]);
        NSDictionary *entities = [response responseAsJSONObject];
        [super didFinishInvoker:invoker results:entities request:request response:response];
    }];
}
#pragma mark - 在签到组中保存签到点 -
- (void)saveSignInPoint:(KDServiceActionInvoker *) invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/saveAttSet.json"];
    
    [super doPost:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
        DLog(@"response = %@",[response responseAsString]);
        NSDictionary *result = ![response isValidResponse] ? nil : [response responseAsJSONObject];
        [super didFinishInvoker:invoker results:result request:request response:response];
    }];
}

#pragma mark - 查询并编辑签到点
- (void)findAttendSet4Edit:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/findAttendSet4Edit.json"];
    [super doPost:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
        DLog(@"response = %@",[response responseAsString]);
        NSDictionary *entities = ![response isValidResponse] ? nil : [response responseAsJSONObject];
        [super didFinishInvoker:invoker results:entities request:request response:response];
    }];
}

- (void)checkHasAttSetGroup:(KDServiceActionInvoker *)invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/checkHasAttSetGroup.json"];
    [super doPost:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *request, KDResponseWrapper *response, BOOL failed) {
        DLog(@"response = %@",[response responseAsString]);
        NSDictionary *entities = ![response isValidResponse] ? nil : [response responseAsJSONObject];
        [super didFinishInvoker:invoker results:entities request:request response:response];
    }];
}

#pragma mark - 获取签到高级设置信息 -
- (void)getAttendanceSetAdvanced:(KDServiceActionInvoker *) invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/attendanceSetAdvanced.json"];
    
    [super doGet:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *requestWrapper, KDResponseWrapper *responseWrapper, BOOL failed) {
        DLog(@"response = %@",[responseWrapper responseAsString]);
        NSDictionary *result = ![responseWrapper isValidResponse] ? nil : [responseWrapper responseAsJSONObject];
        [super didFinishInvoker:invoker results:result request:requestWrapper response:responseWrapper];
    }];
}

#pragma mark - 设置签到高级设置信息 -
- (void)saveAttendanceSetAdvanced:(KDServiceActionInvoker *) invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/attendanceSetAdvanced.json"];
    
    [super doPost:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *requestWrapper, KDResponseWrapper *responseWrapper, BOOL failed) {
        DLog(@"response = %@",[responseWrapper responseAsString]);
        NSDictionary *result = ![responseWrapper isValidResponse] ? nil : [responseWrapper responseAsJSONObject];
        [super didFinishInvoker:invoker results:result request:requestWrapper response:responseWrapper];
    }];
}

#pragma mark - 获取是否有签到点管理的权限
- (void)getAttendAdminRole:(KDServiceActionInvoker *)invoker
{
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/getAttendAdminRole.json"];
    [super doGet:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *requestWrapper, KDResponseWrapper *responseWrapper, BOOL failed) {
        NSDictionary *entities = [responseWrapper responseAsJSONObject];
        [super didFinishInvoker:invoker results:entities request:requestWrapper response:responseWrapper];
    }];
}

- (void)signInFeedback:(KDServiceActionInvoker *) invoker {
    [invoker configWithMask:KD_INVOKER_MASK_AUTH_COMMUNITY serviceURL:@"attendance/attendance-feedback-form.json"];
    
    [super doPost:invoker configBlock:nil didCompleteBlock:^(KDRequestWrapper *requestWrapper, KDResponseWrapper *responseWrapper, BOOL failed) {
        DLog(@"response = %@",[responseWrapper responseAsString]);
        NSDictionary *result = ![responseWrapper isValidResponse] ? nil : [responseWrapper responseAsJSONObject];
        [super didFinishInvoker:invoker results:result request:requestWrapper response:responseWrapper];
    }];
}

@end
