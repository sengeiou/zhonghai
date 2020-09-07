//
//  KDExpressionViewDefaultDataSource.m
//  kdweibo_common
//
//  Created by shen kuikui on 13-2-28.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDExpressionViewDefaultDataSource.h"
#import "KDExpressionCode.h"

@implementation KDExpressionViewDefaultDataSource

- (NSUInteger)numberOfPagesInExpressionView:(KDExpressionView *)expView {
    return 4;
}

- (NSUInteger)expressionView:(KDExpressionView *)expView numberOfRowsInPage:(NSUInteger)page {
    return 3;
}

- (NSUInteger)expressionView:(KDExpressionView *)expView numberOfColumnsInRow:(NSUInteger)row ofPage:(NSUInteger)page {
    return 7;
}

- (UIImage *)expressionView:(KDExpressionView *)expView imageForPosition:(KDExpressionViewPostion)pos {
    NSUInteger index = [self expressionView:expView positionToIndex:pos];
    if(index >= [KDExpressionCode allCodeString].count)
        return nil;
    
    NSString *imageName = [KDExpressionCode codeStringToImageName:[[KDExpressionCode allCodeString] objectAtIndex:index]];
    
    return [UIImage imageNamed:imageName];
}
- (NSString *)expressionView:(KDExpressionView *)expView titleForPosition:(KDExpressionViewPostion)pos
{
    NSUInteger index = [self expressionView:expView positionToIndex:pos];
    if(index >= [KDExpressionCode allCodeString].count)
        return nil;
    return [[KDExpressionCode allCodeString] objectAtIndex:index];
}

- (NSString *)expressionView:(KDExpressionView *)expView codeStringAtPosition:(KDExpressionViewPostion)pos {
    NSUInteger index = [self expressionView:expView positionToIndex:pos];
    if(index >= [KDExpressionCode allCodeString].count)
        return nil;
    return [[KDExpressionCode allCodeString] objectAtIndex:index];
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
