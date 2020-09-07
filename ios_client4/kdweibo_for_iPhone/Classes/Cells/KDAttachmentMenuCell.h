//
//  KDAttachmentMenuCell.h
//  kdweibo
//
//  Created by shen kuikui on 12-12-28.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDAttachmentMenuCellDelegate;

@interface KDAttachmentMenuCell : UITableViewCell {
@private
//    id<KDAttachmentMenuCellDelegate> delegate_;
}

@property (nonatomic, assign) id<KDAttachmentMenuCellDelegate> delegate;

@end


@protocol KDAttachmentMenuCellDelegate <NSObject>

@required

- (void)viewButtonClickedInAttachmentMenuCell:(KDAttachmentMenuCell *)cellView;
- (void)deleteButtonClickedInAttachmentMenuCell:(KDAttachmentMenuCell *)cellView;

@end