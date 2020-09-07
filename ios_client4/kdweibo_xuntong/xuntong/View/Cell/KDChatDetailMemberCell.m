//
//  KDChatDetailMemberCell.m
//  kdweibo
//
//  Created by kyle on 16/9/29.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDChatDetailMemberCell.h"

#define personTag 1000

@interface KDChatDetailMemberCell ()

@property (nonatomic, strong) NSMutableArray *needPersons;
@property (nonatomic, assign) NSInteger realNumber;
@property (nonatomic, strong) NSMutableArray *buttonArray;

@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIButton *deleButton;
@property (nonatomic, strong) UILabel *managerLabel;
@property (nonatomic, strong) UIImageView *personStatusView;

@end

@implementation KDChatDetailMemberCell

- (UILabel *)managerLabel {
    if (!_managerLabel) {
        _managerLabel = [[UILabel alloc] init];
        _managerLabel.layer.cornerRadius = 5.f;
        _managerLabel.layer.masksToBounds = YES;
        _managerLabel.font = [UIFont systemFontOfSize:12];
        _managerLabel.text = ASLocalizedString(@"XTContactPersonViewCell_Admin");
        _managerLabel.textColor = FC6;
        _managerLabel.backgroundColor = FC5;
        _managerLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _managerLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _realNumber = 0;
        _needPersons = [NSMutableArray array];
        _buttonArray = [NSMutableArray array];
        _personList = [NSMutableArray array];
        
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addButton setImage:[UIImage imageNamed:@"message_tip_add"] forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(addPerson) forControlEvents:UIControlEventTouchUpInside];
        
        _deleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleButton setImage:[UIImage imageNamed:@"message_tip_delete"] forState:UIControlStateNormal];
        [_deleButton addTarget:self action:@selector(deletePerson) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (NSURL *)headerImageUrl:(PersonSimpleDataModel *)person {
    NSURL *imageURL = nil;
    if ([person hasHeaderPicture]) {
        NSString *url = person.photoUrl;
        
        if ([url rangeOfString:@"?"].location != NSNotFound) {
            url = [url stringByAppendingFormat:@"&spec=180"];
        }
        else {
            url = [url stringByAppendingFormat:@"?spec=180"];
        }
        imageURL = [NSURL URLWithString:url];
    }
    else {
        imageURL = nil;
    }
    
    return imageURL;
}

- (void)stupViews{
    _realNumber = (ScreenFullWidth-12)/52;
    CGFloat space = (ScreenFullWidth - _realNumber * 40)/(_realNumber + 1);
    NSInteger addNumber = 1;
    
    if ([self.group isManager]) {
        addNumber ++;
    }
    
    NSInteger personNumber = _realNumber-addNumber;
    [self removeAllButtons];
    [_needPersons removeAllObjects];
    if (self.personList.count <= personNumber) {
        [_needPersons addObjectsFromArray:self.personList];
    }else{
        [_needPersons addObjectsFromArray:[self.personList subarrayWithRange:NSMakeRange(0, personNumber)]];
    }
    for (int i=0; i < [_needPersons count]; i++) {
        PersonSimpleDataModel *person = [_needPersons objectAtIndex:i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImageWithURL:[self headerImageUrl:person] forState:UIControlStateNormal placeholderImage:[XTImageUtil headerDefaultImage] completed: nil];
        button.tag = i+personTag;
        [button.layer setCornerRadius:20.0];
        [button.layer setMasksToBounds:YES];
        
        [button addTarget:self action:@selector(memberButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:button];
        
        [button makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(space+(space+40)*i);
            make.width.height.mas_equalTo(40);
        }];
        
        if ([self.group.managerIds containsObject:person.personId]) {
            [self.contentView addSubview:self.managerLabel];
            [self.managerLabel makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(button);
                make.bottom.equalTo(button);
                make.width.equalTo(button);
                make.height.mas_equalTo(15);
            }];
        }
        
        if (![person xtAvailable] || ![person accountAvailable]) {
            self.personStatusView = [[UIImageView alloc] initWithImage:[XTImageUtil headerXTAvailableImage]];
            UILabel *statusLabel = [[UILabel alloc] init];
            if ([person accountAvailable]) {
                statusLabel.text = ASLocalizedString(@"KDInvitePhoneContactsViewController_un_active");
            } else {
                statusLabel.text = ASLocalizedString(@"KDInvitePhoneContactsViewController_canceled");
            }
            statusLabel.textAlignment = NSTextAlignmentCenter;
            statusLabel.textColor = [UIColor colorWithRed:77/256.0 green:94/256.0 blue:105/256.0 alpha:1];
            statusLabel.font = [UIFont systemFontOfSize:10];
            [statusLabel sizeToFit];
            statusLabel.center = self.personStatusView.center;
            [self.personStatusView addSubview:statusLabel];
            
            [button addSubview:self.personStatusView];
            [self.personStatusView makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(button);
            }];
        }
        
        [_buttonArray addObject:button];
    }
    
    NSInteger memberCount = [_needPersons count];
    if(![self.group abortAddPersonOpened] || [self.group isManager])
    {
        [self.contentView addSubview:_addButton];
        [_addButton makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(space+(space+40)*memberCount);
            make.width.height.mas_equalTo(40);
        }];
        [_buttonArray addObject:_addButton];
        memberCount ++;
    }
    
    if ([self.group isManager]) {
        [self.contentView addSubview:_deleButton];
        [_deleButton makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(space+(space+40)*(memberCount));
            make.width.height.mas_equalTo(40);
        }];
        [_buttonArray addObject:_deleButton];
    }
}

- (void)removeAllButtons {
    if ([self.buttonArray count] < 1) {
        return;
    }
    for (UIButton *button in self.buttonArray) {
        [button removeFromSuperview];
    }
    
    [self.buttonArray removeAllObjects];
}

- (void)setGroup:(GroupDataModel *)group {
    _group = group;
    [_personList removeAllObjects];
    
    PersonSimpleDataModel *person = [KDCacheHelper personForKey:[BOSConfig sharedConfig].user.userId];
    [self.personList addObject:person];
    NSInteger limitCount = 10;
    NSMutableArray *managers = [NSMutableArray array];
    for (NSString *managerId in self.group.managerIds) {
        // 管理员不是自己的情况
        if ([managerId isEqualToString:[BOSConfig sharedConfig].user.userId] || [managerId isEqualToString:[NSString stringWithFormat:@"%@_ext",[BOSConfig sharedConfig].user.wbUserId]]) {
            continue;
        } else {
            PersonSimpleDataModel *manager = [KDCacheHelper personForKey:managerId];
            if (manager) {
                [managers addObject:manager];
                [self.personList addObject:manager];
            }
        }
    }
    
    for (NSString *personId in group.participantIds) {
        if (self.personList.count >= limitCount) {
            break;
        }
        // 加入非管理员  非自己 person。  目前 显示规则 按组成员从前往后
        if ([personId isEqualToString:[BOSConfig sharedConfig].user.userId] || [personId isEqualToString:[NSString stringWithFormat:@"%@_ext",[BOSConfig sharedConfig].user.wbUserId]]) {
            continue;
        }
        PersonSimpleDataModel *person = [group participantForKey:personId];
        if (person) {
            if ([self isManager:person]) {
                continue;
            }
            if (![self.personList containsObject:person]) {
                [self.personList addObject:person];
            }
            
        }
    }
    
    [self stupViews];
}

- (void)memberButtonClick:(UIButton *)button {
    if ([self.needPersons count] > 0) {
        PersonSimpleDataModel *person = [self.needPersons objectAtIndex:button.tag-personTag];
        self.block(KDChatDetailMemberType_Person, person);
    } else {
        self.block(KDChatDetailMemberType_Person, nil);
    }
}

- (void)addPerson {
    self.block(KDChatDetailMemberType_Add, nil);
}

- (void)deletePerson {
    self.block(KDChatDetailMemberType_Delete, nil);
}

- (BOOL)isManager:(PersonSimpleDataModel *)person
{
    if ([self.group.managerIds containsObject:person.wbUserId] || [self.group.managerIds containsObject:[NSString stringWithFormat:@"%@_ext",person.wbUserId]])
    {
        return YES;
    }
    if ([self.group.managerIds containsObject:person.personId])
    {
        return YES;
    }
    return NO;
}

@end
