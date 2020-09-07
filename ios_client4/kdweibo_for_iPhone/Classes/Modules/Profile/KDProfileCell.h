//
//  KDProfileCell.h
//  kdweibo
//
//  Created by Gil on 15/2/2.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDProfileIconCell : KDTableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *headerView;
@end

@interface KDProfileTextCell : KDTableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@end

@class KDProfileNewlyCell;
@protocol KDProfileNewlyCellDelegate <NSObject>
@required
- (void)titleLabelDidClick:(KDProfileNewlyCell *)cell;
@end

@interface KDProfileNewlyCell : KDTableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *contentTextField;
@property (nonatomic, weak) id<KDProfileNewlyCellDelegate> delegate;
@end

static NSString *const kProfileRowOriginalAdd = @"kProfileRowOriginalAdd";
static NSString *const kProfileRowOriginalNewly = @"kProfileRowOriginalNewly";


typedef NS_OPTIONS(NSUInteger, KDProfileSectionType) {
    KDProfileSectionTypeBasic,
    KDProfileSectionTypeCompany,
    KDProfileSectionTypeContactPhone,
    KDProfileSectionTypeContactEmail,
    KDProfileSectionTypeContactOther,
    KDProfileSectionTypeContactAllContact
};

@interface KDProfileRowDataModel : NSObject
- (id)initWithTitle:(NSString *)title content:(NSString *)content original:(id)original;
@property (nonatomic, strong) NSString *title;   //在自定义字段等同 name
@property (nonatomic, strong) NSString *content; //在自定义字段等同 value
@property (nonatomic, strong) id original;//原始数据
@property (nonatomic, assign, readonly, getter=isCanEdit) BOOL canEdit;
@property (nonatomic, assign, readonly) UITableViewCellEditingStyle style;
@property (nonatomic, assign) KDProfileSectionType type;

@property (nonatomic, copy) NSString *attributeId; // 自定义字段的Id
@property (nonatomic, assign) NSInteger attributeType; // 0不可修改 1可以修改
@end


@interface KDProfileSectionDataModel : NSObject
- (id)initWithTitle:(NSString *)title type:(KDProfileSectionType)type rows:(NSArray *)rows;
@property (nonatomic, assign) KDProfileSectionType type;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSMutableArray *rows;//KDProfileRowDataModel array
@end

@interface KDProfileDataModel : NSObject
- (id)initWithSections:(NSMutableArray *)sections flags:(NSMutableArray *)flags;
@property (nonatomic, strong) NSMutableArray *sectionFlags;
@property (nonatomic, strong) NSMutableArray *sections;//KDProfileSectionDataModel array
@end
