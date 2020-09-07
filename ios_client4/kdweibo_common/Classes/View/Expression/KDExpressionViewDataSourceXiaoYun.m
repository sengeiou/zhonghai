//
//  KDExpressionViewDataSourceXiaoYun.m
//  kdweibo
//
//  Created by Darren Zheng on 7/10/16.
//  Copyright © 2016 www.kingdee.com. All rights reserved.
//

#import "KDExpressionViewDataSourceXiaoYun.h"
#import "KDExpressionCodeXiaoYun.h"

@implementation KDExpressionViewDataSourceXiaoYun

- (NSUInteger)numberOfPagesInExpressionView:(KDExpressionView *)expView {
    return 2;
}

- (NSUInteger)expressionView:(KDExpressionView *)expView numberOfRowsInPage:(NSUInteger)page {
    return 2;
}

- (NSUInteger)expressionView:(KDExpressionView *)expView numberOfColumnsInRow:(NSUInteger)row ofPage:(NSUInteger)page {
    return 4;
}

- (UIImage *)expressionView:(KDExpressionView *)expView imageForPosition:(KDExpressionViewPostion)pos {
    NSUInteger index = [self expressionView:expView positionToIndex:pos];
    if(index >= [KDExpressionCodeXiaoYun allCodeString].count)
        return nil;
    
    NSString *imageName = [KDExpressionCodeXiaoYun codeStringToImageName:[[KDExpressionCodeXiaoYun allCodeString] objectAtIndex:index]];
    
    return [UIImage imageNamed:imageName];
}

- (NSString *)expressionView:(KDExpressionView *)expView titleForPosition:(KDExpressionViewPostion)pos
{
    NSUInteger index = [self expressionView:expView positionToIndex:pos];
    if(index >= [KDExpressionCodeXiaoYun allValues].count)
        return nil;
    return [[KDExpressionCodeXiaoYun allValues] objectAtIndex:index];
}

- (NSString *)expressionView:(KDExpressionView *)expView codeStringAtPosition:(KDExpressionViewPostion)pos {
    NSUInteger index = [self expressionView:expView positionToIndex:pos];
    if(index >= [KDExpressionCodeXiaoYun allCodeString].count)
        return nil;
    return [[KDExpressionCodeXiaoYun allCodeString] objectAtIndex:index];
}

- (NSUInteger)expressionView:(KDExpressionView *)expView positionToIndex:(KDExpressionViewPostion)pos {
    NSUInteger index = 0;
    
    //calculate the before page's total image
    for(NSUInteger pageIndex = 0; pageIndex < pos.page; pageIndex ++) {
        NSUInteger rowCount = [self expressionView:expView numberOfRowsInPage:pageIndex];
        for(NSUInteger rowIndex = 0; rowIndex < rowCount; rowIndex ++) {
            index += [self expressionView:nil numberOfColumnsInRow:rowIndex ofPage:pageIndex];
        }
    }
    
    for(NSUInteger rowIndex = 0; rowIndex < pos.row; rowIndex ++) {
        index += [self expressionView:nil numberOfColumnsInRow:pos.page ofPage:rowIndex];
    }
    
    index += pos.column;
    
    return index;
}

@end