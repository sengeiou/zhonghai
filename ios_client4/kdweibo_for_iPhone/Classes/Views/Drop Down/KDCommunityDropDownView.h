//
//  KDCommunityDropDownView.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-26.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDDropDownView.h"

#import "KDRequestWrapper.h"

@protocol KDCommunityDropDownViewDelegate;

@class KDCommunity;
@class KDCommunityDropDownFooterView;

@interface KDCommunityDropDownView : KDDropDownView <UITableViewDelegate, UITableViewDataSource, KDRequestWrapperDelegate> {
@private
    NSArray *displayItems_;
    KDCommunity *currentCommunity_;

    UITableView *tableView_;
    UILabel *infoLabel_;
    KDCommunityDropDownFooterView *footerView_;
}

//@property(nonatomic, assign) id<KDCommunityDropDownViewDelegate> delegate;

- (void)setCommunities:(NSArray *)communities selectedCommunity:(KDCommunity *)selectedCommunity;
- (void)reloadData;

@end


@protocol KDCommunityDropDownViewDelegate <KDDropDownViewDelegate>
@optional

- (void)communityDropDownView:(KDCommunityDropDownView *)communityDropDownView didSelectCommunity:(KDCommunity *)community;

@end
