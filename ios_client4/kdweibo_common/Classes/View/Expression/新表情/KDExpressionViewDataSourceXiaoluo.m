//
//  KDExpressionViewDataSourceXiaoluo.m
//  kdweibo
//
//  Created by DarrenZheng on 14-7-28.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDExpressionViewDataSourceXiaoluo.h"
#import "KDExpressionCodeXiaoluo.h"

@implementation KDExpressionViewDataSourceXiaoluo


- (NSUInteger)numberOfPagesInExpressionView:(KDExpressionView *)expView {
    return [KDExpressionCodeXiaoluo allCodeString].count/2/4+([KDExpressionCodeXiaoluo allCodeString].count%(2*4)==0?0:1);
}

- (NSUInteger)expressionView:(KDExpressionView *)expView numberOfRowsInPage:(NSUInteger)page {
    return 2;
}

- (NSUInteger)expressionView:(KDExpressionView *)expView numberOfColumnsInRow:(NSUInteger)row ofPage:(NSUInteger)page {
    return 4;
}

- (UIImage *)expressionView:(KDExpressionView *)expView imageForPosition:(KDExpressionViewPostion)pos {
    NSUInteger index = [self expressionView:expView positionToIndex:pos];
    if(index >= [KDExpressionCodeXiaoluo allCodeString].count)
        return nil;
    
    NSString *imageName = [KDExpressionCodeXiaoluo codeStringToImageName:[[KDExpressionCodeXiaoluo allCodeString] objectAtIndex:index]];
    
    return [UIImage imageNamed:imageName];
}

- (NSString *)expressionView:(KDExpressionView *)expView codeStringAtPosition:(KDExpressionViewPostion)pos {
    NSUInteger index = [self expressionView:expView positionToIndex:pos];
    if(index >= [KDExpressionCodeXiaoluo allCodeString].count)
        return nil;
    return [[KDExpressionCodeXiaoluo allCodeString] objectAtIndex:index];
}
- (NSString *)expressionView:(KDExpressionView *)expView titleForPosition:(KDExpressionViewPostion)pos
{
    NSUInteger index = [self expressionView:expView positionToIndex:pos];
    if(index >= [KDExpressionCodeXiaoluo allValues].count)
        return nil;
    return [[KDExpressionCodeXiaoluo allValues] objectAtIndex:index];
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
