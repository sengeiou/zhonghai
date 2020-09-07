//
//  T9SearchResult.h
//  TestT9
//
//  Created by Gil on 13-1-16.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _T9ResultType{
    T9ResultTypeT9 = 0,
    T9ResultTypeHanzi = 1,
    T9ResultTypePhoneNumber = 2
}T9ResultType;

@interface T9SearchResult : NSObject

@property (nonatomic,assign,readonly) int userId;
@property (nonatomic,copy,readonly) NSArray *matchLength;//匹配规则
@property (nonatomic,assign,readonly) int weight;//权重
@property (nonatomic,assign,readonly) T9ResultType type;//类型

- (id)initWithUserId:(int)userId
         matchLength:(NSArray *)matchLength
              weight:(int)weight
                type:(T9ResultType)type;

- (NSString*)calcHighlightName:(NSString*)name;
- (NSString*)calcHighlightPhone:(NSString*)phone;
- (NSString*)calcHighlightPinYin:(NSString*)fullpinyin;

@end
