//
//  KDUsersURLView.m
//  kdweibo
//
//  Created by Guohuan Xu on 3/31/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDUsersURLView.h"

@implementation KDUsersURLView

//init method for usersURLView
- (id)initWithFontSize:(CGFloat)fontSize
                 width:(CGFloat)width
              delegate:(id)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;
        self.FontSize=fontSize;
        self.frameWidth = width; 
    }
    return self;
}

//set content and element ,then layout
- (void)layoutUsersUrlViewWith:(NSString *)replyStatusString
                     userName:(NSString *)useName
                       userId:(NSString *)userId
{
    NSMutableString *body = [NSMutableString string];
    if (useName != nil) {
        // if this status has been deleted, then the username is nil
//        [body appendFormat:@"%@:", useName];
        [body appendString:@":"];
    }
    [body appendString:replyStatusString];
    
    self.sourceText = body;
    
    NSMutableArray *elementArray=[self splitStringByAll:body];
    DSStyleString *urlElement = [[DSStyleString alloc] init];//autorelease];
    urlElement.isUrl = YES;
    urlElement.style=USER;
    urlElement.string = useName;
    urlElement.url=useName;
    [elementArray insertObject:urlElement atIndex:0];
    [self layoutURLViewWithElements:elementArray];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
