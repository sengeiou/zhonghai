//
//  KDPlaceAroundTableView.m
//  kdweibo
//
//  Created by wenjie_lee on 16/2/19.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDPlaceAroundTableView.h"
#import "KDLocationTableViewCell.h"


@interface KDPlaceAroundTableView()

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *searchPoiArray;

@property (nonatomic, strong) AMapPOI *selectedPoi;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, assign) BOOL isFromMoreButton;
@property (nonatomic, strong) UIButton *moreButton;


@end

@implementation KDPlaceAroundTableView

#pragma mark - Interface

- (AMapPOI *)selectedTableViewCellPoi
{
    return self.selectedPoi;
}

#pragma mark - AMapSearchDelegate

- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)respons
{
    if (self.isFromMoreButton == YES)
    {
        self.isFromMoreButton = NO;
    }
    else
    {
        [self.searchPoiArray removeAllObjects];
        [self.moreButton setTitle:ASLocalizedString(@"KDPlaceAroundTableView_More")forState:UIControlStateNormal];
        self.moreButton.enabled = YES;
        self.moreButton.backgroundColor = [UIColor whiteColor];
    }
    
    if (respons.pois.count == 0)
    {
        NSLog(ASLocalizedString(@"KDPlaceAroundTableView_NoMore"));
        [self.moreButton setTitle:ASLocalizedString(@"KDPlaceAroundTableView_NoMore..")forState:UIControlStateNormal];
        self.moreButton.enabled = NO;
        self.moreButton.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
        
        [self.tableView reloadData];
        return;
    }
    
    [respons.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        [self.searchPoiArray addObject:obj];
    }];
    
    [self.tableView reloadData];
    AMapPOI *data =self.searchPoiArray[0];
//    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"coor", nil]
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AMapPOI" object:nil userInfo:@{@"data":data}];
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil)
    {
        self.currentRedWaterPosition = response.regeocode.formattedAddress;
        
        
        NSIndexPath *reloadIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        self.selectedIndexPath = reloadIndexPath;
//        [self.tableView reloadRowsAtIndexPaths:@[reloadIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView reloadData];
    }
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.searchPoiArray.count<=indexPath.row)
        return;
    
//    KDLocationTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
//    cell.accessoryType= UITableViewCellAccessoryCheckmark;
    NSIndexPath *oldIndexPath = self.selectedIndexPath;
    self.selectedIndexPath = indexPath;
    NSArray *reloadPaths;
    if(oldIndexPath)
        reloadPaths = @[oldIndexPath,indexPath];
    else
        reloadPaths = @[indexPath];
    [self.tableView reloadRowsAtIndexPaths:reloadPaths withRowAnimation:UITableViewRowAnimationNone];
    self.selectedPoi = self.searchPoiArray[indexPath.row];
    
    [self.tableView reloadData];

    if (indexPath.section == 0)
    {
        [self.delegate didPositionCellTapped:self.selectedPoi];
        self.selectedPoi = nil;
        return ;
    }
    
    if ([self.delegate respondsToSelector:@selector(didTableViewSelectedChanged:)])
    {
        [self.delegate didTableViewSelectedChanged:self.selectedPoi];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - UITableView Datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reusedIndentifier = @"reusedIndentifier";
    
    KDLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIndentifier];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIndentifier];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell == nil)
    {
        cell = [[KDLocationTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reusedIndentifier];
    }
    if (indexPath.section == 0)
    {
        cell.label.text = ASLocalizedString(@"KDPlaceAroundTableView_Position");
        cell.subLabel.text =  self.currentRedWaterPosition;
//        cell.textLabel.text = ASLocalizedString(@"KDPlaceAroundTableView_Position");
//        cell.detailTextLabel.text = self.currentRedWaterPosition;
    }
    else
    {
        AMapPOI *poi = self.searchPoiArray[indexPath.row];
        cell.label.text = poi.name;
        cell.subLabel.text =  poi.address;
//        cell.textLabel.text = poi.name;
//        cell.detailTextLabel.text = poi.address;
    }
    
//    if (self.selectedPoi != nil) {
//        if (self.selectedPoi.uid isEqualToString:<#(nonnull NSString *)#>) {
//            <#statements#>
//        }
//    }
//    if (data == locationData_) {
//        [cell.accessoryImageView setImage:[UIImage imageNamed:@"task_editor_finish"]];
//    } else {
//        [cell.accessoryImageView setImage:nil];
//    }
    cell.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
    
    if (self.selectedIndexPath && self.selectedIndexPath.section == indexPath.section && self.selectedIndexPath.row == indexPath.row)
    {
//         cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [cell.accessoryImageView setImage:[UIImage imageNamed:@"task_editor_finish"]];
     }
     else
    {
//         cell.accessoryType = UITableViewCellAccessoryNone;
        [cell.accessoryImageView setImage:nil];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else
    {
        return self.searchPoiArray.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

#pragma mark - Handle Action

- (void)actionMoreButtonTapped
{
    // 防止快速连续点两次
    if (self.isFromMoreButton == YES)
    {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(didLoadMorePOIButtonTapped)])
    {
        self.isFromMoreButton = YES;
        [self.delegate didLoadMorePOIButtonTapped];
    }
}

#pragma mark - Initialization

- (NSMutableArray *)searchPoiArray
{
    if (_searchPoiArray == nil)
    {
        _searchPoiArray = [[NSMutableArray alloc] init];
    }
    return _searchPoiArray;
}

- (void)initTableViewFooter
{
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 44)];
    
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), 44);
    [moreBtn setTitle:ASLocalizedString(@"KDPlaceAroundTableView_More")forState:UIControlStateNormal];
    [moreBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [moreBtn setTitleColor:[[UIColor grayColor] colorWithAlphaComponent:0.4] forState:UIControlStateHighlighted];
    moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    moreBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    [moreBtn addTarget:self action:@selector(actionMoreButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.moreButton = moreBtn;
    
    [footer addSubview:moreBtn];
    
    UIView *upLineView = [[UIView alloc] initWithFrame:CGRectMake(15, 3, CGRectGetWidth(self.bounds)-15, 0.5)];
    upLineView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
    [footer addSubview:upLineView];
    
    self.tableView.tableFooterView = footer;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        self.isFromMoreButton = NO;
        

        [self addSubview:self.tableView];
        
        [self initTableViewFooter];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
