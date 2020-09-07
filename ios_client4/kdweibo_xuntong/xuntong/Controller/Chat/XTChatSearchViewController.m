//
//  XTChatSearchViewController.m
//  kdweibo
//
//  Created by bird on 14-7-29.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "XTChatSearchViewController.h"
#import "BOSPublicConfig.h"
#import "MBProgressHUD.h"
#import "XTDataBaseDao.h"
#import "BubbleDataInternal.h"
#import "BubbleTableViewCell.h"
#import "XTFileUtils.h"
#import "BOSConfig.h"
#import "ContactUtils.h"
#import "XTDeleteService.h"
#import "BubbleTableViewSearchCell.h"

#define kSearchIconCapWidth 8.f
#define BubbleLabelMaxWidth (ScreenFullWidth - (10+44+3)*2)

@interface XTChatSearchViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, weak)   UIButton *selectedBtn;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UIView *searchBar;
@property (nonatomic, assign) UIStatusBarStyle statusBarStyple;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *describeLabel;
@property (nonatomic, strong) UILabel *searchLabel;
@property (nonatomic, strong) UILabel *subDescribeLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *bubbleArray;
@property (nonatomic, strong) NSMutableArray *recordsList;
@property (nonatomic, strong) UIActivityIndicatorView *lastPageIndicatorView;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, assign) BOOL isAtEnd;
@property (nonatomic, assign) int pageIndex;
@end

@implementation XTChatSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _pageIndex = 0;
        _mode = SearchModeUnActive;
        _statusBarStyple = [UIApplication sharedApplication].statusBarStyle;
        _bubbleArray = [NSMutableArray array];
        _recordsList = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self.view addGestureRecognizer:gesture];
}
- (void)loadView{
    [super loadView];
    self.view.frame = [UIScreen mainScreen].bounds;
    
    CGRect rect = self.view.frame;
    rect.origin.y = NavigationBarHeight;
//    if (isAboveiOS7) {
        rect.origin.y += [UIApplication sharedApplication].statusBarFrame.size.height;
//    }
    rect.size.height -= rect.origin.y;
    self.contentView = [[UIView alloc] initWithFrame:rect];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.contentView];
    
    self.contentView.hidden = YES;
    
    self.describeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenFullWidth -10, 24.f)];
    [self.contentView addSubview:_describeLabel];
    self.describeLabel.font = [UIFont systemFontOfSize:15.f];
    self.describeLabel.textColor = MESSAGE_NAME_COLOR;
    [self.describeLabel setBackgroundColor: [UIColor clearColor]];
    
    self.searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,12, ScreenFullWidth -10, 21.f)];
    self.searchLabel.numberOfLines = 0;
    [self.contentView addSubview:_searchLabel];
    self.searchLabel.font = [UIFont systemFontOfSize:17.f];
    self.searchLabel.textColor = UIColorFromRGB(0x1a85ff);
    [self.searchLabel setBackgroundColor: [UIColor clearColor]];
    
    self.subDescribeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,20, ScreenFullWidth - 10, 21.f)];
    self.subDescribeLabel.numberOfLines = 0;
    [self.contentView addSubview:_subDescribeLabel];
    self.subDescribeLabel.font = [UIFont systemFontOfSize:18.f];
    self.subDescribeLabel.textColor = MESSAGE_NAME_COLOR;
    [self.subDescribeLabel setBackgroundColor: [UIColor clearColor]];
    
    rect.origin.y = 0.0f;
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contentView addSubview:_tableView];
}
- (void)tap{
    if (_searchTextField.isFirstResponder) {
        [_searchTextField resignFirstResponder];
    }
}
- (void)beginBgColorAnimation{

    [UIView animateWithDuration:0.3f animations:^{
        
        if (_mode == SearchModeSearch) {
            self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
        }
        else if(_mode == SearchModeActive){
//            self.view.backgroundColor = [UIColor colorWithRed:237/255.f green:237/255.f blue:237/255.f alpha:1.0f];
            self.view.backgroundColor = [UIColor kdBackgroundColor1];
        }
        else if(_mode == SearchModeUnActive){
            self.view.backgroundColor = [UIColor clearColor];
        }
        
    } completion:^(BOOL finished) {
        
        
    }];
}
- (void)beginNavigationBarAnimation{

    [UIView animateWithDuration:0.3f animations:^{
        
        if (_mode == SearchModeUnActive) {
            
            CGRect rect = _controller.navigationController.navigationBar.frame;
            rect.origin.y += rect.size.height;
            
//            if (isAboveiOS7) {
                rect.origin.y += [UIApplication sharedApplication].statusBarFrame.size.height;
//            }
            
            [_controller.navigationController.navigationBar setFrame:rect];

        }
        else{
            
            CGRect rect = _controller.navigationController.navigationBar.frame;
            rect.origin.y -= rect.size.height;
            
//            if (isAboveiOS7) {
                rect.origin.y -= [UIApplication sharedApplication].statusBarFrame.size.height;
//            }
            
            [_controller.navigationController.navigationBar setFrame:rect];
        }
        
    } completion:^(BOOL finished) {
        
        if (_mode == SearchModeUnActive) {
            
            if (self.view.superview) {
                [self.view removeFromSuperview];
            }
            
            self.selectedBtn = nil;
        }
        else{
            
            [_controller.navigationController setNavigationBarHidden:YES];
            
            CGRect rect = _controller.view.frame;
            rect.origin.y +=  _controller.navigationController.navigationBar.frame.size.height;
//            if (isAboveiOS7) {
                rect.origin.y += [UIApplication sharedApplication].statusBarFrame.size.height;
//            }
            _controller.chatSearchViewPresentInMainView.frame = rect;
            
            self.contentView.hidden = NO;
            [self search];
        }
    }];
}
- (void)beginTopViewAnimation{

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    
    
    if (_mode == SearchModeUnActive) {
        
        CGRect rect = _topView.frame;
        rect.origin.y += CGRectGetHeight(_controller.navigationController.navigationBar.frame);
        rect.size.height = CGRectGetHeight(_controller.navigationController.navigationBar.frame);
//        if (isAboveiOS7) {
            rect.origin.y +=  [UIApplication sharedApplication].statusBarFrame.size.height;
//        }
        
        [_topView setFrame:rect];
        
        _closeBtn.hidden = YES;
        
    }
    else{
    
        CGRect rect = _topView.frame;
        rect.origin.y -= CGRectGetHeight(_controller.navigationController.navigationBar.frame);
        rect.size.height = CGRectGetHeight(_controller.navigationController.navigationBar.frame);
//        if (isAboveiOS7) {
            rect.origin.y -=  [UIApplication sharedApplication].statusBarFrame.size.height;
            rect.size.height += [UIApplication sharedApplication].statusBarFrame.size.height;
//        }
        
        [_topView setFrame:rect];
        
        _closeBtn.hidden = NO;
    }
    
    [UIView commitAnimations];
    
}
- (void)beginItemAnimation{
    
    NSTimeInterval delay = _mode == SearchModeUnActive? 0.3f:0.0f;
    
    [UIView animateWithDuration:0.0 delay:delay options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
        
        if (_mode == SearchModeUnActive) {
            
            if (_selectedBtn.tag == 2) {
                _searchBar.hidden = YES;
            }
            
            for (UIButton *btn  in _buttons) {
                if (btn != _selectedBtn) {
                    [btn setHidden:NO];
                }
                else{
                    
                    NSInteger tag = btn.tag;
                    
                    CGRect rect = btn.frame;
                    rect.origin.x = rect.size.width*tag;
                    btn.frame = rect;
                }
            }
            
        }
        else{
        
            for (UIButton *btn  in _buttons) {
                if (btn != _selectedBtn) {
                    [btn setHidden:YES];
                }
                else{
                    
                    CGRect rect = btn.frame;
                    rect.origin.x = rect.size.width;
                    btn.frame = rect;
                }
            }
            
            if (_selectedBtn.tag == 2) {
                _searchBar.hidden = NO;
            }
            
        }
    
    } completion:^(BOOL finished) {
        
    }];
}
- (UIView *)topView{
    
    if (_topView == nil) {
        
        _buttons = [NSMutableArray array];
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
        _topView.backgroundColor = [UIColor whiteColor];
        _topView.clipsToBounds = YES;
        _topView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _topView.alpha = 0.9f;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44-0.5f, ScreenFullWidth, 1.f)];
        lineView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        lineView.clipsToBounds = YES;
        lineView.backgroundColor = UIColorFromRGB(0xdddddd);
        [_topView addSubview:lineView];
        
       // NSArray *imgs = [NSArray arrayWithObjects:@"dm_btn_head_pic",@"dm_btn_head_text",@"dm_btn_head_search", nil];
       //  NSArray *img_hs = [NSArray arrayWithObjects:@"dm_btn_tag_pic",@"dm_btn_tag_text",@"dm_btn_tag_search", nil];

        NSArray *imgs = [NSArray arrayWithObjects:@"dm_btn_tag_pic",@"dm_btn_tag_text",@"dm_btn_tag_search", nil];

        NSArray *img_hs = [NSArray arrayWithObjects:@"dm_btn_head_pic",@"dm_btn_head_text",@"dm_btn_head_search", nil];

        
        CGRect frame = CGRectMake(0, 0, CGRectGetWidth(_topView.frame)*0.3333f, CGRectGetHeight(_topView.frame)-0.5f);
        for (int i = 0; i<3; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = frame;
            btn.tag = i;
            btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            [btn setImage:[UIImage imageNamed:[imgs objectAtIndex:i]] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(itemBgClick:) forControlEvents:UIControlEventTouchDown];
            [btn addTarget:self action:@selector(resetItemBg:) forControlEvents:UIControlEventTouchCancel];
            [btn addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn setImage:[UIImage imageNamed:[img_hs objectAtIndex:i]] forState:UIControlStateHighlighted];
            frame.origin.x += frame.size.width;
            [_topView addSubview:btn];
            
            [_buttons addObject:btn];
        }
        
        frame.origin.x = 0.0f;
        frame.size.width = _topView.frame.size.width;
        _searchBar = [[UIView alloc] initWithFrame:frame];
        _searchBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight;
        _searchBar.backgroundColor = [UIColor whiteColor];
        [_topView addSubview:_searchBar];
        _searchBar.hidden = YES;
        
        UIImage *textFieldBgImage = [UIImage imageNamed:@"dm_img_bg_search"];
        textFieldBgImage = [textFieldBgImage stretchableImageWithLeftCapWidth:textFieldBgImage.size.width*0.5f topCapHeight:textFieldBgImage.size.height*0.5f];
        
        _searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(kSearchIconCapWidth, 8, ScreenFullWidth - 62, 30.0f)];
        _searchTextField.placeholder = ASLocalizedString(@"KDSearchBar_Search");
        _searchTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _searchTextField.background = textFieldBgImage;
        _searchTextField.font = [UIFont systemFontOfSize:14];
        _searchTextField.delegate = self;
        _searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _searchTextField.returnKeyType = UIReturnKeySearch;
        _searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [_searchTextField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
        _searchTextField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        UIImageView *leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dm_img_search"]];
        leftView.contentMode = UIViewContentModeCenter;
        leftView.frame = CGRectMake(0, 0, 30, 30);
        _searchTextField.leftViewMode = UITextFieldViewModeAlways;
        [_searchTextField setLeftView:leftView];
        
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 30.f)];
        _searchTextField.rightViewMode = UITextFieldViewModeAlways;
        [_searchTextField setRightView:rightView];
        
        [_searchBar addSubview:_searchTextField];
    }
    
    return _topView;
}

- (void)resetItemBg:(UIButton *)btn{
    
    [btn setBackgroundColor:[UIColor whiteColor]];
}
- (void)itemClick:(id)sender{
    
    [self resetItemBg:sender];
    
    if ([_controller isTopViewAnimation]) {
        return;
    }
    
    if (_mode != SearchModeUnActive)
        return;
    
    if (_controller && [_controller respondsToSelector:@selector(chatSearchViewWillPresent)]) {
        [_controller chatSearchViewWillPresent];
    }
    
    self.selectedBtn = sender;
    
    NSString *filterType = nil;
    switch (self.selectedBtn.tag) {
        case 0:
            filterType = label_session_filter_picture;
            break;
        case 1:
            filterType = label_session_filter_file;
            break;
        case 2:
            filterType = label_session_filter_search;
            break;
        default:
            break;
    }
    [KDEventAnalysis event:event_session_filter attributes:@{label_session_filter: filterType}];
    
    if (self.view.superview == nil) {
        [_controller.view addSubview:self.view];
    }
    [_controller.view bringSubviewToFront:_topView];
    
    
    if (_closeBtn == nil) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.frame = CGRectMake(_topView.frame.size.width - 50, 0, 50, _topView.frame.size.height);
        _closeBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [_topView addSubview:_closeBtn];
        [_closeBtn addTarget:self action:@selector(closeClick:) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn setTitleColor:UIColorFromRGB(0x1a85ff) forState:UIControlStateNormal];
        _closeBtn.titleLabel.font = [UIFont systemFontOfSize:18.f];
        _closeBtn.hidden = YES;
    }
    if (_loadingView == nil) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0, self.tableView.bounds.size.width, 30.0f)];
        view.backgroundColor = [UIColor clearColor];
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.center = CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2);
        indicatorView.hidesWhenStopped = YES;
        self.lastPageIndicatorView = indicatorView;
        [view addSubview:indicatorView];
        
        self.loadingView = view;
    }
    self.tableView.tableHeaderView = _loadingView;
    
    UIButton *button = (UIButton *)sender;
    if (button.tag == 0 || button.tag == 1) {
        _mode = SearchModeActive;
        [_closeBtn setTitle:ASLocalizedString(@"KDChooseOrganizationViewController_Close")forState:UIControlStateNormal];
    }
    else{
        _mode = SearchModeSearch;
        [_searchTextField becomeFirstResponder];
        [_closeBtn setTitle:ASLocalizedString(@"Global_Cancel")forState:UIControlStateNormal];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    [self beginItemAnimation];
    [self beginBgColorAnimation];
    [self beginNavigationBarAnimation];
    [self beginTopViewAnimation];
}
- (void)closeClick:(id)sender{
    [self dismissChatSearchView];
    [self.controller.navigationController popViewControllerAnimated:YES];
}
- (void)dismissChatSearchView{

    if (_controller && [_controller respondsToSelector:@selector(chatSearchViewWillDismiss)]) {
        [_controller chatSearchViewWillDismiss];
    }
    _searchTextField.text = nil;
    if (_searchTextField.isFirstResponder) {
        [_searchTextField resignFirstResponder];
    }
    
    _pageIndex = 0;
    _mode = SearchModeUnActive;
    
    [[UIApplication sharedApplication] setStatusBarStyle:_statusBarStyple animated:YES];
    
    [_controller.navigationController setNavigationBarHidden:NO];
    [KDWeiboAppDelegate setExtendedLayout:_controller];
    
    
    CGRect rect = _controller.navigationController.navigationBar.frame;
    rect.origin.y -= rect.size.height;
//    if (isAboveiOS7) {
        rect.origin.y -= [UIApplication sharedApplication].statusBarFrame.size.height;
//    }
    
    [_controller.navigationController.navigationBar setFrame:rect];
    
    rect = _controller.view.bounds;
    _controller.chatSearchViewPresentInMainView.frame = rect;
    
    self.contentView.hidden = YES;
    
    [self beginItemAnimation];
    [self beginBgColorAnimation];
    [self beginNavigationBarAnimation];
    [self beginTopViewAnimation];
}
- (void)itemBgClick:(id)sender{
    UIButton *btn = (UIButton *)sender;
    btn.backgroundColor = UIColorFromRGB(0xf7f7f7);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate methods
- (void)textChanged:(UITextField *)textField{
    
    if (_bubbleArray) {
        [_bubbleArray removeAllObjects];
    }
    if (_recordsList) {
        [_recordsList removeAllObjects];
    }
    [_tableView reloadData];
    _subDescribeLabel.text = @"";
    
    if ([textField.text length] == 0) {
        self.contentView.hidden = YES;
        _mode = SearchModeSearch;
        [self beginBgColorAnimation];
    }
    else{
        if (_mode != SearchModeActive) {
            self.contentView.hidden = NO;
            _mode = SearchModeActive;
            [self beginBgColorAnimation];
        }
    }
    
    //_searchLabel.text = [NSString stringWithFormat:ASLocalizedString(@"搜索：%@"),textField.text];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if ([textField.text length] == 0) {
        return YES;
    }
    
    if (_recordsList) {
        [_recordsList removeAllObjects];
    }
    if (_bubbleArray) {
        [_bubbleArray removeAllObjects];
    }
    
    __strong MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view.window];
    [hud setLabelText:ASLocalizedString(@"XTChatSearchViewController_Searching")];
    [hud setRemoveFromSuperViewOnHide:YES];
    [self.view.window addSubview:hud];
    
    [hud showAnimated:YES whileExecutingBlock:^{
        
        NSString *userId = nil;
        if ([_group.participant count] == 1) {
            PersonSimpleDataModel *person = [_group.participant lastObject];
            userId = [NSString stringWithFormat:@"%d",person.userId];
        }
        
        [_recordsList addObjectsFromArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryAllContentWithGroupId:_group.groupId toUserId:userId content:textField.text pageIndex:_pageIndex isAtEnd:&_isAtEnd]];
        for (int i=0;i<[_recordsList count];i++) {
            [_bubbleArray addObject:[NSNull null]];
        }
        
        
    } completionBlock:^{
        
        if (_isAtEnd) {
            _tableView.tableHeaderView = nil;
        }
        
        _searchLabel.text = @"";
        [_searchTextField resignFirstResponder];
        
        if (_recordsList.count >0) {
       
            [_tableView reloadData];
            
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_bubbleArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        else{
            CGRect rect = _subDescribeLabel.frame;
            rect.size.height = 50.f;
            _subDescribeLabel.frame = rect;
            _subDescribeLabel.text = ASLocalizedString(@"XTChatSearchViewController_NoContent");
        }
       
    }];
    
    return YES;
}

//搜索逻辑
- (void)search{
    
    if (_bubbleArray) {
        [_bubbleArray removeAllObjects];
    }
    if (_recordsList) {
        [_recordsList removeAllObjects];
    }
    
    [self reloadData];
    
    if (_selectedBtn.tag == 0) {
        _searchLabel.text = @"";
        _describeLabel.text = @"";
        _subDescribeLabel.text = @"";
        
        CGRect rect = _tableView.frame;
        rect.origin.y = CGRectGetMaxY(_describeLabel.frame);
        rect.size.height = CGRectGetHeight(_contentView.frame) - rect.origin.y;
        
        _tableView.frame =rect;
        
        
        __strong MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view.window];
        [hud setLabelText:ASLocalizedString(@"XTChatSearchViewController_Searching")];
        [hud setRemoveFromSuperViewOnHide:YES];
        [self.view.window addSubview:hud];
        
        [hud showAnimated:YES whileExecutingBlock:^{
            
            NSString *userId = nil;
            if ([_group.participant count] == 1) {
                PersonSimpleDataModel *person = [_group.participant lastObject];
                userId = [NSString stringWithFormat:@"%d",person.userId];
            }
            [_recordsList addObjectsFromArray:[[XTDataBaseDao sharedDatabaseDaoInstance]queryAllContentWithGroupId:_group.groupId toUserId:userId  content:_searchTextField.text pageIndex:_pageIndex isAtEnd:&_isAtEnd]];
//            [_recordsList addObjectsFromArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryAllPicturesWithGroupId:_group.groupId toUserId:userId pageIndex:_pageIndex isAtEnd:&_isAtEnd]];
            for (int i=0;i<[_recordsList count];i++) {
                [_bubbleArray addObject:[NSNull null]];
            }

        } completionBlock:^{
            
            if (_isAtEnd) {
                _tableView.tableHeaderView = nil;
            }
            if (_recordsList.count == 0) {
                
                CGRect rect = _subDescribeLabel.frame;
                rect.size.height = 21.f;
                _subDescribeLabel.frame = rect;
                
                _subDescribeLabel.text = ASLocalizedString(@"XTChatSearchViewController_No_Chat");
                _describeLabel.text = @"";
                
            }
            else{
                
//                _describeLabel.text = [NSString stringWithFormat:ASLocalizedString(@"XTChatSearchViewController_Record"),_group.groupName];
            
                [_tableView reloadData];
                
                
//                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_bubbleArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
            
          
        }];
        
    }else if (_selectedBtn.tag == 1){
        
        _searchLabel.text = @"";
        _describeLabel.text = @"";
        _subDescribeLabel.text = @"";
        
        CGRect rect = _tableView.frame;
        rect.origin.y = CGRectGetMaxY(_describeLabel.frame);
        rect.size.height = CGRectGetHeight(_contentView.frame) - rect.origin.y;
        
        _tableView.frame =rect;
        
        
        __strong MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view.window];
        [hud setLabelText:ASLocalizedString(@"XTChatSearchViewController_Searching")];
        [hud setRemoveFromSuperViewOnHide:YES];
        [self.view.window addSubview:hud];
        
        [hud showAnimated:YES whileExecutingBlock:^{
            
            NSString *userId = nil;
            if ([_group.participant count] == 1) {
                PersonSimpleDataModel *person = [_group.participant lastObject];
                userId = [NSString stringWithFormat:@"%d",person.userId];
            }
            
            [_recordsList addObjectsFromArray:[[XTDataBaseDao sharedDatabaseDaoInstance] queryAllDocumentsWithGroupId:_group.groupId toUserId:userId pageIndex:_pageIndex isAtEnd:&_isAtEnd]];
            for (int i=0;i<[_recordsList count];i++) {
                [_bubbleArray addObject:[NSNull null]];
            }
            
        } completionBlock:^{
            
            if (_isAtEnd) {
                _tableView.tableHeaderView = nil;
            }
            
            if (_recordsList.count == 0) {
                
                CGRect rect = _subDescribeLabel.frame;
                rect.size.height = 21.f;
                _subDescribeLabel.frame = rect;
                
                _subDescribeLabel.text = ASLocalizedString(@"XTChatSearchViewController_No_Document");
                _describeLabel.text = @"";
                
            }
            else{
                
                _describeLabel.text = [NSString stringWithFormat:ASLocalizedString(@"XTChatSearchViewController_Document"),_group.groupName];
                
                [_tableView reloadData];
                
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_bubbleArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
        }];
    }
    else{
        _describeLabel.text = @"";
        _searchLabel.text = @"";
        _subDescribeLabel.text = @"";
        
        CGRect rect = _tableView.frame;
        rect.origin.y = 0;
        rect.size.height = CGRectGetHeight(_contentView.frame);
        
        _tableView.frame =rect;
    }
}

- (void)startLoading
{
    if (self.isAtEnd) {
        return;
    }

    __weak XTChatSearchViewController *selfInBlock = self;
    [UIView animateWithDuration:0.0 animations:^{
        
        [selfInBlock.lastPageIndicatorView startAnimating];
        
    } completion:^(BOOL finished) {
        
        selfInBlock.pageIndex ++;
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            NSString *userId = nil;
            NSInteger count = 0;
            if ([_group.participant count] == 1) {
                PersonSimpleDataModel *person = [_group.participant lastObject];
                userId = [NSString stringWithFormat:@"%d",person.userId];
            }
            
            if (_selectedBtn.tag == 0) {
                NSArray *records = [[XTDataBaseDao sharedDatabaseDaoInstance] queryAllPicturesWithGroupId:_group.groupId toUserId:userId pageIndex:_pageIndex isAtEnd:&_isAtEnd];
                NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, records.count)];
                [_recordsList insertObjects:records atIndexes:indexSet];
            }
            else if(_selectedBtn.tag == 1){
                NSArray *records = [[XTDataBaseDao sharedDatabaseDaoInstance] queryAllDocumentsWithGroupId:_group.groupId toUserId:userId pageIndex:_pageIndex isAtEnd:&_isAtEnd];
                NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, records.count)];
                [_recordsList insertObjects:records atIndexes:indexSet];
            }
            else if(_selectedBtn.tag == 2){
                NSArray *records = [[XTDataBaseDao sharedDatabaseDaoInstance] queryAllContentWithGroupId:_group.groupId toUserId:userId content:_searchTextField.text pageIndex:_pageIndex isAtEnd:&_isAtEnd];
                NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, records.count)];
                [_recordsList insertObjects:records atIndexes:indexSet];
            }
            count = [_recordsList count] - [_bubbleArray count];
            for (int i= 0;i< count;i++) {
                [_bubbleArray insertObject:[NSNull null] atIndex:i];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (_isAtEnd) {
                    _tableView.tableHeaderView = nil;
                }
            
                [selfInBlock.tableView reloadData];
                CGFloat height = 0.0f;
                for (int i=0; i< count; i++) {
                    BubbleDataInternal *bubbleDataModel = (BubbleDataInternal *)[_bubbleArray objectAtIndex:i];
                    if (![bubbleDataModel isKindOfClass:[NSNull class]]) {
                        height+= bubbleDataModel.cellHeight1;
                    }
                }
                [selfInBlock.tableView setContentOffset:CGPointMake(0, height)];
                
                [self stopLoading];
            });  
            
        });
    }];
}

- (void)stopLoading
{
    [self.lastPageIndicatorView stopAnimating];
}
#pragma mark - tableView delegate & datasource methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.contentView) {
        return;
    }
    
    BOOL load = scrollView.contentOffset.y == -_tableView.contentInset.top;
    if (load) {
        [self startLoading];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    BubbleDataInternal *dataInterna = [_bubbleArray objectAtIndex:indexPath.row];
    if (![dataInterna isKindOfClass:[BubbleDataInternal class]]) {
        dataInterna = [self getDataInternaFromRecordModel:[_recordsList objectAtIndex:indexPath.row]];
        [_bubbleArray replaceObjectAtIndex:indexPath.row withObject:dataInterna];
    }
    return dataInterna.cellHeight1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_mode == SearchModeActive) {
        return [_bubbleArray count];
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"tblBubbleCell";
    
    BubbleDataInternal *dataInternal = [_bubbleArray objectAtIndex:indexPath.row];
    dataInternal.checkMode = -1;
    BubbleTableViewSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@_%@", cellId, dataInternal.record.msgId]];
    if (cell == nil)
    {
        cell = [[BubbleTableViewSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%@_%@", cellId, dataInternal.record.msgId]];
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.msgDeleteDelegate = self;
    cell.chatViewController = (XTChatViewController *)_controller;
    cell.highlightText = _searchTextField.text;

    cell.dataInternal = dataInternal;
    
    cell.row_index = indexPath.row;
    return cell;
}
#pragma mark - TableView
- (BubbleDataInternal *)getDataInternaFromRecordModel:(RecordDataModel *)recordModel{

    NSDate *last = [NSDate dateWithTimeIntervalSince1970:0];
    NSDateFormatter *dateFormatter2Date = [[NSDateFormatter alloc]init];
    [dateFormatter2Date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    __strong BubbleDataInternal *dataInternal = [[BubbleDataInternal alloc] init];
    dataInternal.group = self.group;
    dataInternal.record = recordModel;
    
    BOOL personNameLabelHidden = NO;
    float personNameLabelHeight = 15.0;
    if ([[BOSConfig sharedConfig].user.userId isEqualToString:dataInternal.record.fromUserId])
    {
        personNameLabelHidden = YES;
        personNameLabelHeight = 0.0;
    } else {
        if (self.chatMode == ChatPrivateMode) {
            if (self.group.groupType != GroupTypeMany) {
                personNameLabelHidden = YES;
                personNameLabelHeight = 0.0;
            }
        } else {
            if (dataInternal.record.msgDirection == MessageDirectionLeft && self.group.groupType != GroupTypePublicMany) {
                personNameLabelHidden = YES;
                personNameLabelHeight = 0.0;
            }
        }
    }
    dataInternal.personNameLabelHidden = personNameLabelHidden;
    
    // Calculating cell height
    switch (dataInternal.record.msgType) {
        case MessageTypeSpeech:
        {
            //语音
            float width = 100.0 * (dataInternal.record.msgLen / 60.0) + 59.0;
            dataInternal.bubbleLabelSize = CGSizeMake(width, 31.0);
            dataInternal.contentLabelFrame = CGRectMake(dataInternal.record.msgDirection == MessageDirectionLeft ? 12.0 : 6.0, 8.0, dataInternal.bubbleLabelSize.width - 18.0, dataInternal.bubbleLabelSize.height - 16.0);
            dataInternal.cellHeight1 = 61.0 + personNameLabelHeight + 5.0;
        }
            break;
        case MessageTypeSystem:
        case MessageTypeCancel:
        {
            //其他:系统、电话等
            NSString *content = dataInternal.record.content ? dataInternal.record.content : @"";
            NSMutableAttributedString *contentString = [NSMutableAttributedString attributedStringWithString:content];
            [contentString setFont:[UIFont systemFontOfSize:12.0]];
            [contentString setTextAlignment:kCTTextAlignmentCenter lineBreakMode:kCTLineBreakByWordWrapping];
            CGSize contentSize = [contentString sizeConstrainedToSize:CGSizeMake(300, 9999)];
            
            if (contentSize.height < 20){
                contentSize.height = 20.0;
            }
            contentSize.width += 10.0;
            dataInternal.bubbleLabelSize = CGSizeMake(contentSize.width, contentSize.height);
            dataInternal.contentLabelFrame = CGRectMake(0.0, 0.0, contentSize.width, contentSize.height);
            dataInternal.cellHeight1 = dataInternal.bubbleLabelSize.height + 10 + 5.0;
        }
            break;
        case MessageTypePicture:
        {
            //图片
            dataInternal.bubbleLabelSize = CGSizeMake(90.0 + 27.0, 180.0);
            dataInternal.contentLabelFrame = CGRectZero;
            dataInternal.cellHeight1 = dataInternal.bubbleLabelSize.height + 20.0;
            if (dataInternal.record.param) {
                dataInternal.cellHeight1 += 20.0;
            }
        }
            break;
        case MessageTypeFile:
        {
            //文件
            MessageFileDataModel *file = (MessageFileDataModel *)dataInternal.record.param.paramObject;
            
            if ([XTFileUtils isPhotoExt:file.ext]) {
                dataInternal.bubbleLabelSize = CGSizeMake(90.0 + 27.0, 180);
                dataInternal.contentLabelFrame = CGRectZero;
                dataInternal.cellHeight1 = dataInternal.bubbleLabelSize.height + 20.0;
                if (dataInternal.record.param) {
                    dataInternal.cellHeight1 += 20.0;
                }
            }
            else {
                
                CGSize contentSize = [(file.name ? file.name : @"") boundingRectWithSize:CGSizeMake(KDChatConstants.bubbleContentLabelMaxWidth - 12 - 55, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: FS4} context:nil].size;
                
                if (contentSize.height < 30) {
                    contentSize.height = 30;
                }
                if (contentSize.height > 18*4) {
                    contentSize.height = 18*4;
                }
                
                if (contentSize.width < ScreenFullWidth-180) {
                    contentSize.width = ScreenFullWidth-180;
                }
                
                dataInternal.bubbleLabelSize = CGSizeMake(BubbleLabelMaxWidth, contentSize.height + 12*2 + 8 + 15);
                dataInternal.cellHeight1 = dataInternal.bubbleLabelSize.height + 10.0 + personNameLabelHeight + 15.0;
                if (file.appName.length > 0) {
                    dataInternal.cellHeight1 += 20.0;
                }
            }
            
        }
            break;
        case MessageTypeAttach:
        {
            //带操作的消息
            NSString *content = dataInternal.record.content ? dataInternal.record.content : @"";
            NSMutableAttributedString *contentString = [NSMutableAttributedString attributedStringWithString:content];
            [contentString setFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
            [contentString setTextAlignment:kCTTextAlignmentLeft lineBreakMode:kCTLineBreakByWordWrapping];
            CGSize contentSize = [contentString sizeConstrainedToSize:CGSizeMake(272.0, 9999)];
            
            float bubbleLabelSizeHeight = contentSize.height;
            CGFloat actionHeight = 0;
            MessageAttachDataModel *paramObject = dataInternal.record.param.paramObject;
            if ([paramObject.attach count] == 1) {
                actionHeight = 31 + 4.0;
            } else if ([paramObject.attach count] == 2) {
                actionHeight = 31 + 30 + 4.0;
            }
            bubbleLabelSizeHeight += (18.0 + actionHeight);
            float bubbleLabelSizeWidth = 290.0;
            dataInternal.bubbleLabelSize = CGSizeMake(bubbleLabelSizeWidth, bubbleLabelSizeHeight);
            dataInternal.contentLabelFrame = CGRectMake(8.0, 8.0, 272.0, contentSize.height);
            dataInternal.cellHeight1 = dataInternal.bubbleLabelSize.height + 10.0 + 5.0;
        }
            break;
        case MessageTypeNews:
        {
            //新闻
            MessageNewsDataModel *paramObject = dataInternal.record.param.paramObject;
            MessageNewsEachDataModel *news = [paramObject.newslist objectAtIndex:0];
            
            CGSize contentSize = [(news.text ? news.text : @"") sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]] constrainedToSize:CGSizeMake(174, 70) lineBreakMode:NSLineBreakByWordWrapping];
            if (contentSize.height < 13.0) {
                contentSize.height = 13.0;
            }
            
            dataInternal.bubbleLabelSize = CGSizeMake(contentSize.width + 18.0, contentSize.height + 10.0);
            dataInternal.contentLabelFrame = CGRectZero;
            if (paramObject.model == 1 && !paramObject.todoNotify  && paramObject.newslist.count > 0)
            {
                dataInternal.cellHeight1 = 68+dataInternal.bubbleLabelSize.height+10;
            }else if(paramObject.model == 2 && paramObject.newslist.count > 0)
            {
                dataInternal.cellHeight1 = 207+dataInternal.bubbleLabelSize.height+10;
            }
            else if(paramObject.model == 3 && paramObject.newslist.count > 0)
            {
                dataInternal.cellHeight1 = 74+74*paramObject.newslist.count+10;
            }
            else if(paramObject.model == 4){
                
                if ([[paramObject.newslist objectAtIndex:0] hasHeaderPicture]) {
                    dataInternal.cellHeight1 = 207+dataInternal.bubbleLabelSize.height+10;
                }
                else{
                    dataInternal.cellHeight1 = 68+dataInternal.bubbleLabelSize.height+10;
                }
                if ([[[paramObject.newslist objectAtIndex:0] buttons] count]>0) {
                    dataInternal.cellHeight1 += 23.f;
                }
            }
        }
            break;
        case MessageTypeShareNews:
        {
            //分享到
            CGSize contentSize = CGSizeMake(174.0, 92.0);
            dataInternal.bubbleLabelSize = CGSizeMake(contentSize.width + 18.0, contentSize.height + 10.0);
            dataInternal.contentLabelFrame = CGRectMake(72.0, 42.0, 114.0, 55.0);
            dataInternal.cellHeight1 = dataInternal.bubbleLabelSize.height + 10.0 + 20.0;
        }
            break;
        default:
        {
            BOOL hasEffectiveDuration = false;
            BOOL hasAppShareLabel = false;
            if (dataInternal.record.msgType == MessageTypeText)
            {
                MessageShareTextOrImageDataModel *paramObject = dataInternal.record.param.paramObject;
                if (paramObject.effectiveDuration > 0)
                {
                    hasEffectiveDuration = true;
                    
                    //失效的密码不显示
                    NSTimeInterval interval = [paramObject.clientTime timeIntervalSinceNow];
                    interval = 0 - interval;
                    if (interval > paramObject.effectiveDuration) {
                        
                        dataInternal.cellHeight1 = 0.0f;
                        
                        return dataInternal;
                    }
                }
                if (paramObject.appName.length > 0)
                {
                    hasAppShareLabel = true;
                }
            }
            
            NSString *content = dataInternal.record.content ? dataInternal.record.content : @"";
            UIFont *font = hasEffectiveDuration ? [UIFont systemFontOfSize:20.0] : [UIFont systemFontOfSize:17.0];
            KDExpressionLabelType type = KDExpressionLabelType_Expression | KDExpressionLabelType_URL | KDExpressionLabelType_PHONENUMBER | KDExpressionLabelType_EMAIL | KDExpressionLabelType_TOPIC;
            
            CGSize contentSize = [KDExpressionLabel sizeWithString:content constrainedToSize:CGSizeMake(204, CGFLOAT_MAX) withType:type textAlignment:NSTextAlignmentLeft textColor:nil textFont:font];
            
            if (hasEffectiveDuration) {
                contentSize.width += content.length * 3.0;
            }
            
            float bubbleLabelSizeWidth = contentSize.width + 28.0;
            if (bubbleLabelSizeWidth < 60.0) {
                bubbleLabelSizeWidth = 60.0;
            }
            
            float bubbleLabelMiniSizeHeight = hasEffectiveDuration ? 51.0 : 31.0;
            float bubbleLabelSizeHeight = contentSize.height + 20.0;
            if (bubbleLabelSizeHeight < bubbleLabelMiniSizeHeight) {
                bubbleLabelSizeHeight = bubbleLabelMiniSizeHeight;
            }
            
            dataInternal.bubbleLabelSize = CGSizeMake(bubbleLabelSizeWidth, bubbleLabelSizeHeight);
            
            float x = dataInternal.record.msgDirection == MessageDirectionLeft ? 12.0 : 6.0;
            if (bubbleLabelSizeWidth - contentSize.width - 18.0 > 0) {
                x += (bubbleLabelSizeWidth - contentSize.width - 18.0)/2;
            }
            float y = (bubbleLabelSizeHeight - contentSize.height)/2;
            dataInternal.contentLabelFrame = CGRectMake(x, y, contentSize.width, contentSize.height);
            dataInternal.cellHeight1 = (dataInternal.bubbleLabelSize.height > 51.0 ? dataInternal.bubbleLabelSize.height + 10.0 : 61) + personNameLabelHeight + 5.0;
            
            if (hasAppShareLabel) {
                dataInternal.cellHeight1 += 20.0;
            }
        }
    }
    
    dataInternal.header = nil;
    
    NSDate *time = [dateFormatter2Date dateFromString:dataInternal.record.sendTime];
    if ([time timeIntervalSinceDate:last] > 300)
    {
        dataInternal.header = [ContactUtils xtDateFormatter:dataInternal.record.sendTime];
        dataInternal.cellHeight1 += 35;
        last = time;
    }

    return dataInternal;
}

- (void)reloadData
{
    [_tableView reloadData];
}
- (void)bubbleDidDeleteMsg:(BubbleImageView *)bubbleImageView cell:(BubbleTableViewSearchCell *)cell{

    if (cell != nil) {
        NSIndexPath *index = [self.tableView indexPathForCell:cell];
        if (!index)
		{
            return;
        }
        if (index.row >= 0 && index.row < [self.bubbleArray count]) {
            [self.bubbleArray removeObjectAtIndex:index.row];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:bubbleImageView.record.msgDirection == MessageDirectionLeft ? UITableViewRowAnimationLeft : UITableViewRowAnimationRight];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               [[XTDeleteService shareService] deleteMessageWithGroupId:self.group.groupId msgId:bubbleImageView.record.msgId];
            });
            
            if (_controller && [_controller respondsToSelector:@selector(chatMessageDeleted:group:)]) {
                [_controller chatMessageDeleted:bubbleImageView.record.msgId group:self.group.groupId];
            }
        }
    }
}
@end
