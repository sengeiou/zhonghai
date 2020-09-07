//
//  KDProfileCell.m
//  kdweibo
//
//  Created by Gil on 15/2/2.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDProfileCell.h"
#import "UIImage+XT.h"
#import "KDContactInfo.h"

@implementation KDProfileIconCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.headerView];
        [self setupVFL];
    }
    return self;
}

- (void)setupVFL {
    
    NSDictionary *views = @{ @"titleLabel":self.titleLabel, @"headerView":self.headerView };
    NSDictionary *metrics = @{ @"kHMargin"      : @15,
                               @"kMargin"       : @20,
                               @"kHeightTitleLabel"  : @21,
                               @"kHeightHeaderView"  : @60
                               };
    NSArray *vfls = @[@"|-kHMargin-[titleLabel]-kMargin-[headerView(kHeightHeaderView)]-kHMargin-|",@"V:[titleLabel(kHeightTitleLabel)]",@"V:[headerView(kHeightHeaderView)]"];
    for (NSString *vfl in vfls) {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl
                                                                                 options:nil
                                                                                 metrics:metrics
                                                                                   views:views]];
    }
    
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.titleLabel.superview
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.f constant:0.f]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.headerView.superview
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.f constant:0.f]];
}

- (UIImageView *)headerView {
    if (!_headerView) {
        _headerView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _headerView.layer.cornerRadius = 3;
        _headerView.clipsToBounds = YES;
        _headerView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _headerView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _titleLabel;
}

@end

@interface KDProfileTextCell ()
@property (nonatomic, strong) NSArray *hvlfs;
@property (nonatomic, strong) UIImageView *controlButton;
@end

@implementation KDProfileTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		[self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.contentLabel];
        [self setupVFL];
	}
	return self;
}

- (void)updateConstraints {
    
    [super updateConstraints];
    
    if (self.hvlfs) {
        [self.contentView removeConstraints:self.hvlfs];
    }
    
	NSDictionary *views = @{ @"titleLabel":self.titleLabel, @"contentLabel":self.contentLabel };
    NSDictionary *metrics = @{ @"kHMarginRight" : self.accessoryType == UITableViewCellAccessoryNone ? @15 : @0,
		                       @"kHMarginLeft"  : self.isEditing ? @10 : @15,
		                       @"kMargin"       : @10};
    NSString *vfl1 = @"|-kHMarginLeft-[titleLabel(>=40,<=70)]-kMargin-[contentLabel]-kHMarginRight-|";
    if (self.contentLabel.text.length == 0) {
        vfl1 = @"|-kHMarginLeft-[titleLabel]-kHMarginRight-|";
    }
    self.hvlfs = [NSLayoutConstraint constraintsWithVisualFormat:vfl1
                                                           options:nil
                                                           metrics:metrics
                                                             views:views];
    [self.contentView addConstraints:self.hvlfs];
}

- (void)setupVFL {
	NSDictionary *views = @{ @"titleLabel":self.titleLabel, @"contentLabel":self.contentLabel };
	NSDictionary *metrics = @{@"kHeightLabel"  : @21 };
	NSArray *vfls = @[@"V:[titleLabel(kHeightLabel)]", @"V:[contentLabel(kHeightLabel)]"];
	for (NSString *vfl in vfls) {
		[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl
		                                                                         options:nil
		                                                                         metrics:metrics
		                                                                           views:views]];
	}


	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
	                                                             attribute:NSLayoutAttributeCenterY
	                                                             relatedBy:NSLayoutRelationEqual
	                                                                toItem:self.titleLabel.superview
	                                                             attribute:NSLayoutAttributeCenterY
	                                                            multiplier:1.f constant:0.f]];

	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentLabel
	                                                             attribute:NSLayoutAttributeCenterY
	                                                             relatedBy:NSLayoutRelationEqual
	                                                                toItem:self.contentLabel.superview
	                                                             attribute:NSLayoutAttributeCenterY
	                                                            multiplier:1.f constant:0.f]];
}

- (UILabel *)contentLabel {
	if (!_contentLabel) {
		_contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_contentLabel.backgroundColor = [UIColor clearColor];
		_contentLabel.font = [UIFont systemFontOfSize:14];
		_contentLabel.textColor = MESSAGE_NAME_COLOR;
		_contentLabel.textAlignment = NSTextAlignmentRight;
        _contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _contentLabel;
}

- (UILabel *)titleLabel {
	if (!_titleLabel) {
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _titleLabel;
}

@end

@interface KDProfileNewlyCell ()
@property (nonatomic, strong) UIImageView *separateImage;
@property (nonatomic, strong) UIImageView *separateImage2;
@end

@implementation KDProfileNewlyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.separateImage];
        [self.contentView addSubview:self.separateImage2];
        [self.contentView addSubview:self.contentTextField];
        [self setupVFL];
    }
    return self;
}

- (void)setupVFL {
    
    NSDictionary *views = @{ @"titleLabel":self.titleLabel, @"separateImage":self.separateImage, @"separateImage2":self.separateImage2, @"contentTextField":self.contentTextField };
    NSArray *vfls = @[@"|-10-[titleLabel(>=40,<=70)]-9-[separateImage(6)]-9-[separateImage2(0.5)]-9-[contentTextField]-15-|", @"V:[titleLabel(21)]", @"V:[separateImage(10)]", @"V:[separateImage2(22)]", @"V:[contentTextField(43)]"];
    for (NSString *vfl in vfls) {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl
                                                                                 options:nil
                                                                                 metrics:nil
                                                                                   views:views]];
    }
    
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.titleLabel.superview
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.f constant:0.f]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.separateImage
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.separateImage.superview
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.f constant:0.f]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.separateImage2
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.separateImage2.superview
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.f constant:0.f]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentTextField
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentTextField.superview
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.f constant:0.f]];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font =FS3;
        _titleLabel.textColor = FC1;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleLabelDidClick:)];
        [_titleLabel addGestureRecognizer:tap];
        _titleLabel.userInteractionEnabled = YES;
    }
    return _titleLabel;
}

- (UITextField *)contentTextField {
    if (!_contentTextField) {
        _contentTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _contentTextField.backgroundColor = [UIColor clearColor];
        _contentTextField.font = FS3;
        _contentTextField.textColor = FC2;
        _contentTextField.textAlignment = NSTextAlignmentRight;
        _contentTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _contentTextField.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _contentTextField;
}

- (UIImageView *)separateImage {
    if (!_separateImage) {
        _separateImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_edit_narrow_v3"]];
        _separateImage.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _separateImage;
}

- (UIImageView *)separateImage2 {
    if (!_separateImage2) {
        _separateImage2 = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:[UIColor lightGrayColor]]];
        _separateImage2.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _separateImage2;
}

- (void)titleLabelDidClick:(UITapGestureRecognizer *)tap {
    if (self.delegate) {
        [self.delegate titleLabelDidClick:self];
    }
}

@end

@implementation KDProfileRowDataModel

- (id)initWithTitle:(NSString *)title content:(NSString *)content original:(id)original {
    self = [super init];
    if (self) {
        self.title = title;
        self.content = content;
        self.original = original;
    }
    return self;
}

- (BOOL)isCanEdit {
    
    if (self.attributeId.length > 0) {
        return NO;
    }
    
    
	if (self.original == nil) {
		return NO;
	}

	if ([self.original isKindOfClass:[NSString class]]) {
        if ([self.original isEqualToString:kProfileRowOriginalAdd] || [self.original isEqualToString:kProfileRowOriginalNewly]) {
            return YES;
        }
	}

	if ([self.original isKindOfClass:[KDContactInfo class]]) {
		KDContactInfo *contactInfo = (KDContactInfo *)self.original;
        if (contactInfo.publicid.length == 0) {
            return YES;
        }
		if ([contactInfo.permission isEqualToString:@"W"]) {
			return YES;
		}
	}

	return NO;
}

- (UITableViewCellEditingStyle)style {
	if (self.original == nil) {
		return UITableViewCellEditingStyleNone;
	}

	if ([self.original isKindOfClass:[NSString class]]) {
        if ([self.original isEqualToString:kProfileRowOriginalAdd]) {
            return UITableViewCellEditingStyleInsert;
        }
        else if ([self.original isEqualToString:kProfileRowOriginalNewly]) {
            return UITableViewCellEditingStyleDelete;
        }
	}

	if ([self.original isKindOfClass:[KDContactInfo class]]) {
		KDContactInfo *contactInfo = (KDContactInfo *)self.original;
        if (contactInfo.publicid.length == 0) {
            return UITableViewCellEditingStyleDelete;
        }
		if ([contactInfo.permission isEqualToString:@"W"]) {
			return UITableViewCellEditingStyleDelete;
		}
	}

	return UITableViewCellEditingStyleNone;
}

@end

@implementation KDProfileSectionDataModel

- (id)initWithTitle:(NSString *)title type:(KDProfileSectionType)type rows:(NSArray *)rows
{
    self = [super init];
    if (self) {
        self.title = title;
        self.type = type;
        self.rows = [NSMutableArray arrayWithArray:rows];
    }
    return self;
}

- (NSMutableArray *)rows {
    if (_rows == nil) {
        _rows = [NSMutableArray array];
    }
    return _rows;
}

@end

@implementation KDProfileDataModel

- (id)initWithSections:(NSMutableArray *)sections flags:(NSMutableArray *)flags {
    self = [super init];
    if (self) {
        self.sections = sections;
        self.sectionFlags = flags;
    }
    return self;
}

- (NSMutableArray *)sectionFlags {
    if (_sectionFlags == nil) {
        _sectionFlags = [NSMutableArray array];
    }
    return _sectionFlags;
}

- (NSMutableArray *)sections {
    if (_sections == nil) {
        _sections = [NSMutableArray array];
    }
    return _sections;
}

@end
