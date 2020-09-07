//
//  XTSelectPersonsView.m
//  XT
//
//  Created by Gil on 13-7-22.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTSelectPersonsView.h"
#import "UIImage+XT.h"
#import "XTPersonHeaderImageView.h"

#define MAXNUM  400 //创建组最高人数

@interface KDSelectPersonCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) XTPersonHeaderImageView *personView;
@property (nonatomic, strong) PersonSimpleDataModel *personModel;
@end


@implementation KDSelectPersonCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        self.personView =  [[XTPersonHeaderImageView alloc] initWithFrame:CGRectZero checkStatus:YES];
        self.personView.layer.cornerRadius = 34.0/2;
        [self.contentView addSubview:self.personView];
        
        [self.personView makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(34);
            make.height.mas_equalTo(34);
            make.left.equalTo(self.contentView.left).with.offset(0);
            make.top.equalTo(self.contentView.top).with.offset(0);
        }];
    }
    return self;
}

- (void)setPersonModel:(PersonSimpleDataModel *)personModel
{
    _personModel = personModel;
    self.personView.person = personModel;
}
@end



@interface XTSelectPersonsView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *persons;
@property (nonatomic, strong) NSMutableArray *datasources;

//@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIImageView *defaultImageView;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) MBProgressHUD *progressHud;

@end

@implementation XTSelectPersonsView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.minCount = 1;
        self.isMult = YES;
        self.backgroundColor = [UIColor colorWithPatternImage:[XTImageUtil tabBarBackgroundImage]];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = [NSNumber kdDistance1];
        layout.itemSize = CGSizeMake(34, 34);
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(12.0, 3.0, ScreenFullWidth - 100, frame.size.height - 5.0) collectionViewLayout:layout];
        [self.collectionView setBackgroundColor:[UIColor clearColor]];
        [self.collectionView setShowsHorizontalScrollIndicator:NO];
        [self.collectionView setDelegate:self];
        [self.collectionView setDataSource:self];
        
        [self.collectionView registerClass:[KDSelectPersonCollectionViewCell class] forCellWithReuseIdentifier:@"KDSelectPersonCollectionViewCell"];
        [self addSubview:self.collectionView];
        
        CGRect rect = self.collectionView.frame;
        rect.origin.x = 2.0;
        rect.origin.y = 3.0;
        rect.size.width = 39.0;
        rect.size.height = 39.0;
        
        rect.origin.y = 7.0;
        rect.size.width = 70.0;
        rect.size.height = 30.0;
        rect.origin.x = CGRectGetWidth(frame) - (CGRectGetWidth(rect) + 12.0);
        
        
        UIButton *confirmBtn = [UIButton blueBtnWithTitle:ASLocalizedString(@"XTSelectPersonsView_Begin")];
        [confirmBtn setFrame:rect];
        [confirmBtn setCircle];
        [confirmBtn.titleLabel setFont:FS6];
        [confirmBtn addTarget:self action:@selector(confirmButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.confirmButton = confirmBtn;
        [self confirmButtonTitle];
        [self addSubview:confirmBtn];
    }
    return self;
}

#pragma mark - get

- (NSMutableArray *)persons
{
    if (_persons == nil) {
        _persons = [[NSMutableArray alloc] init];
    }
    return _persons;
}

#pragma mark - add or delete person

-(void)setIsStopRefresh:(BOOL)isStopRefresh
{
    _isStopRefresh = isStopRefresh;
    if(!_isStopRefresh)
    {
        [self.collectionView reloadData];
        [self confirmButtonTitle];
        if (self.persons.count > 0) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.persons.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        }
    }
}

- (void)addPerson:(PersonSimpleDataModel *)person
{
    if ([self.persons containsObject:person]) {
        return;
    }
    
    [self.persons addObject:person];
    
    [self.dataSource selectPersonViewDidAddPerson:person];
    for(id<XTSelectPersonsViewDataSource> ds in _datasources) {
        if([ds respondsToSelector:@selector(selectPersonViewDidAddPerson:)]) {
            [ds selectPersonViewDidAddPerson:person];
        }
    }
    
    [self layoutPersonViewWithAddPerson:person];
}

- (void)deletePerson:(PersonSimpleDataModel *)person
{
    int index = (int)[self.persons indexOfObject:person];
    if(index >= self.persons.count)
        return;
    [self.persons removeObjectAtIndex:index];
    
    [self.dataSource selectPersonsViewDidDeletePerson:person];
    for(id<XTSelectPersonsViewDataSource> ds in _datasources) {
        if([ds respondsToSelector:@selector(selectPersonsViewDidDeletePerson:)]) {
            [ds selectPersonsViewDidDeletePerson:person];
        }
    }
    
    [self layoutPersonViewWithDeletePersonIndex:index];
}

- (void)addDataSource:(id<XTSelectPersonsViewDataSource>)dsToAdd
{
    if(!_datasources) {
        _datasources = [[NSMutableArray alloc] initWithCapacity:2];
    }
    
    if(![_datasources containsObject:dsToAdd]) {
        [_datasources addObject:dsToAdd];
    }
}

- (void)removeDataSource:(id<XTSelectPersonsViewDataSource>)dsToRemove
{
    if([_datasources containsObject:dsToRemove]) {
        [_datasources removeObject:dsToRemove];
    }
}

#pragma mark - btn

- (void)confirmButtonPressed:(UIButton *)btn
{
    [self.delegate selectPersonViewDidConfirm:self.persons];
}

#pragma mark - layout

- (void)layoutPersonViewWithAddPerson:(PersonSimpleDataModel *)person
{
    if(self.isStopRefresh)
        return;
    
    [self.collectionView reloadData];
    [self confirmButtonTitle];
    if (self.persons.count > 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.persons.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    }
}

- (void)layoutPersonViewWithDeletePersonIndex:(int)index
{
    if(self.isStopRefresh)
        return;
    
    if(self.persons.count != 0 && index<self.persons.count)
        [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
    else
        [self.collectionView reloadData];
    [self confirmButtonTitle];
    
    if (self.persons.count > 0 && index == self.persons.count) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.persons.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
}

-(void)updateType
{
    [self.confirmButton setTitle:(self.type == 1 ?ASLocalizedString(@"KDVoteViewController_Share"):ASLocalizedString(@"XTSelectPersonsView_Begin"))forState:UIControlStateNormal];
}

- (void)confirmButtonTitle
{
    NSString *title = self.type == 1 ?ASLocalizedString(@"KDVoteViewController_Share"):ASLocalizedString(@"XTSelectPersonsView_Begin");
    
    if (self.minCount > 0) {
        if ([self.persons count] < self.minCount){ //|| [self.persons count] > MAXNUM) {
            self.confirmButton.enabled = NO;
        }
        else {
            self.confirmButton.enabled = YES;
        }

        if (self.persons.count > self.minCount - 1) {
        title = [title stringByAppendingFormat:@" (%lu)",(unsigned long)[self.persons count]];
        }
    }else
    {
        if ([self.persons count] > 0){ //|| [self.persons count] > MAXNUM) {
            self.confirmButton.enabled = YES;
        }
        else {
            self.confirmButton.enabled = NO;
        }
        if (self.persons.count > 0) {
            title = [title stringByAppendingFormat:@" (%lu)",(unsigned long)[self.persons count]];
        }
    }
    [self.confirmButton setTitle:title forState:UIControlStateNormal];
}

- (void)deleteAllPerson {
    [self.persons removeAllObjects];
    [self.collectionView reloadData];
    [self confirmButtonTitle];
}

#pragma mark collectionViewDelegate & datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KDSelectPersonCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([KDSelectPersonCollectionViewCell class]) forIndexPath:indexPath];
    
    PersonSimpleDataModel *person = self.persons[indexPath.row];
    cell.personModel = person;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    KDSelectPersonCollectionViewCell *cell = (KDSelectPersonCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self deletePerson: cell.personModel];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.persons.count;
}


@end
