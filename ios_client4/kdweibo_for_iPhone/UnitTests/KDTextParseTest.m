//
//  KDTextParseTest.m
//  kdweibo
//
//  Created by shen kuikui on 12-12-7.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDTextParseTest.h"
#import "TwitterText.h"
#import "TwitterTextEntity.h"
#import "JSON.h"

@interface KDTextTestEntity : NSObject

@property (nonatomic, copy) NSString *indent;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *expectType;
@property (nonatomic, retain) id     expected;

- (BOOL)isExpected:(id)real;

@end

@implementation KDTextTestEntity

@synthesize indent, desc, text, expectType, expected;

+ (id)entityWith:(NSDictionary *)dic {
    KDTextTestEntity *entity = [[KDTextTestEntity alloc] init];
    
    if(entity) {
        entity.indent = [dic objectForKey:@"indent"];
        entity.desc = [dic objectForKey:@"desc"];
        entity.text = [dic objectForKey:@"text"];
        entity.expectType = [dic objectForKey:@"expectType"];
        entity.expected = [dic objectForKey:@"expected"];
    }
    
    return [entity autorelease];
}

- (void)dealloc {
    [indent release];
    [desc release];
    [text release];
    [expectType release];
    [expected release];
    
    //[super dealloc];
}

- (BOOL)isExpected:(id)real {
    BOOL retValue = NO;
    
    if([expectType isEqualToString:@"bool"]) {
        retValue = ([expected boolValue] == [real boolValue]);
    } else if([expectType isEqualToString:@"array"]) {
        if([(NSArray *)expected count] == [(NSArray *)real count]) {
            [(NSMutableArray *)expected removeObjectsInArray:real];
            
            if([(NSArray *)expected count] == 0)
                retValue = YES;
        }
    } else if([expectType isEqualToString:@""]) {
        
    } else if([expectType isEqualToString:@""]) {
        
    }
    
    return retValue;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"INDENT:%@<.>TEXT:%@<.>DESC:%@", indent, text, desc];
}

@end

@implementation KDTextParseTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (NSData *)contentForFile:(NSString *)fileName {
    NSBundle *bundle = [NSBundle bundleForClass:[KDTextParseTest class]];
    NSString *filePath = [bundle pathForResource:fileName ofType:nil];

    return [NSData dataWithContentsOfFile:filePath];
}

- (void) testTwitterText {
    
    NSString *html = @"<p>Some Text</p>";
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithHTMLData:data
                                                               documentAttributes:NULL];
    NSLog(@"%@", attrString);
    
    NSArray *entities = [NSJSONSerialization JSONObjectWithData:[self contentForFile:@"status_text_parser.json"] options:NSJSONReadingAllowFragments | NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
    for (NSDictionary *dic in entities) {
        KDTextTestEntity *entity = [KDTextTestEntity entityWith:dic];
        NSArray *entityes = [TwitterText entitiesInText:entity.text];
        NSMutableArray *result = [NSMutableArray arrayWithCapacity:entityes.count];
        
        NSLog(@"entityes : %@", entityes);
        
        for(TwitterTextEntity *tten in entityes) {
            NSLog(@"entity : %@", [entity.text substringWithRange:tten.range]);
            [result addObject:[entity.text substringWithRange:tten.range]];
        }
        
        STAssertTrue([entity isExpected:result], entity.description);
    }
}

@end
