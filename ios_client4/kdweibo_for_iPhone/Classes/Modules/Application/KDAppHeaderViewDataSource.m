//
//  KDAppHeaderViewDataSource.m
//  kdweibo
//
//  Created by 王 松 on 13-12-2.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDAppHeaderViewDataSource.h"

#import "KDTileViewCell.h"

@implementation KDAppHeaderViewDataSource

- (NSUInteger)numberOfColumnsAtTileView:(KDTileView *)tileView
{
    return ImageCount;
}
- (KDTileViewCell *)tileView:(KDTileView *)tileView cellForColumn:(NSInteger)column
{
    static NSString *CellIdentifier = @"KDTileViewCell";
    KDTileViewCell *cell = [[KDTileViewCell alloc] initWithIdentifier:CellIdentifier];// autorelease];
    cell.frame = CGRectMake(0.0f, 0.0f, 320.f, 90.f);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[self imageForColumn:column]];
    [cell.contentView addSubview:imageView];
//    [imageView release];
    return cell;
}

- (UIImage *)imageForColumn:(NSInteger)column
{
    return [UIImage imageNamed:ImageNames[column]];
}

@end
