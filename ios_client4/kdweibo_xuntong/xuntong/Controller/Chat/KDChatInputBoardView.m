//
//  KDChatInputBoardView.m
//  kdweibo
//
//  Created by wenbin_su on 15/6/23.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDChatInputBoardView.h"
#import "SDWebImage/UIImageView+WebCache.h"

@implementation KDChatInputBoardModal

@end

@interface KDChatInputBoardView ()
<UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *mArrayModals;
@property (nonatomic, strong) UIScrollView *scrollViewBG;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation KDChatInputBoardView

#define item_width 60
#define item_height 80
#define new_flag_tag 100
#define item_view_tag 10000

- (instancetype)initWithFrame:(CGRect)frame modals:(NSMutableArray *)mArrayModals
{
    if (self = [super initWithFrame:frame])
    {
        [self.mArrayModals setArray:mArrayModals];
        
        
    }
    return self;
}

- (NSMutableArray *)mArrayModals
{
    if (!_mArrayModals)
    {
        _mArrayModals = [NSMutableArray new];
    }
    return _mArrayModals;
}

- (UIScrollView *)scrollViewBG
{
    if (!_scrollViewBG)
    {
        _scrollViewBG = [UIScrollView new];
        _scrollViewBG.translatesAutoresizingMaskIntoConstraints = NO;
        _scrollViewBG.pagingEnabled = YES;
        _scrollViewBG.delegate = self;
        _scrollViewBG.contentSize = CGSizeMake(ceil(self.mArrayModals.count/8.0) * self.frame.size.width, self.frame.size.height);
        _scrollViewBG.showsHorizontalScrollIndicator = NO;
        _scrollViewBG.backgroundColor = [UIColor kdBackgroundColor2];//RGBCOLOR(245, 245, 245);
        
        for (int i = 0; i < self.mArrayModals.count; i++)
        {
            KDChatInputBoardModal *modal = self.mArrayModals[i];
            
            UIView *viewItemBG = [[UIView alloc] init];
            
            float fXMargin = (self.frame.size.width - item_width * 4) / 5;
            
            float fYMargin = (self.frame.size.height - 15 - item_height * 2) / 3;
            
            viewItemBG.frame = CGRectMake(fXMargin * (i % 4 + 1) + item_width * (i % 4) + self.frame.size.width * (i / 8),
                                          fYMargin * ((((i / 4) + 2) % 2 )+ 1) + item_height * (((i / 4) + 2) % 2),
                                          item_width,
                                          item_height);
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((item_width-44)/2.0, (item_width-44)/2.0, 55, 55)];
            if (modal.image) {
                imageView.image = modal.image;
            }else{
                [imageView setImageWithURL:[NSURL URLWithString:modal.picUrl] placeholderImage:[UIImage imageNamed:@"app_default_icon"]];
            }
            [imageView roundMask];
            [viewItemBG addSubview:imageView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, item_width+3, item_width, [self caculateCellHeight:modal.strTitle])];
            label.backgroundColor = [UIColor clearColor];
            label.numberOfLines = 2;
            label.textAlignment = NSTextAlignmentCenter;
            label.text = modal.strTitle;
            label.textColor = FC1;
            label.font = FS6;
            [viewItemBG addSubview:label];
            
            
            // new flag
            UIImageView *imageViewNewFlag = [[UIImageView alloc] initWithFrame:CGRectMake(35, 5, 28, 16)];
            imageViewNewFlag.image = [UIImage imageNamed:@"inbox_btn_mention_normal"];
            imageViewNewFlag.tag = new_flag_tag + i;
            UILabel *labelNew = [[UILabel alloc] initWithFrame:CGRectMake(0, -1, imageViewNewFlag.frame.size.width, imageViewNewFlag.frame.size.height)];
            labelNew.backgroundColor = [UIColor clearColor];
            labelNew.text = @"new";
            labelNew.font = [UIFont systemFontOfSize:11];
            labelNew.textColor = [UIColor whiteColor];
            labelNew.textAlignment = NSTextAlignmentCenter;
            [imageViewNewFlag addSubview:labelNew];
            [viewItemBG addSubview:imageViewNewFlag];
            imageViewNewFlag.hidden = modal.bShouldHideNewFlag;
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewItemBG.frame.size.width, viewItemBG.frame.size.height)];
            button.tag = i;
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [viewItemBG addSubview:button];
            
            viewItemBG.tag = item_view_tag + i;
            [_scrollViewBG addSubview:viewItemBG];
        }
    }
    return _scrollViewBG;
}

- (void)buttonPressed:(UIButton *)button
{
    // 消除new
    UIView *view = (UIView *)[_scrollViewBG viewWithTag:(item_view_tag + button.tag)];
    UIImageView *imageView = (UIImageView *)[view viewWithTag:(new_flag_tag + button.tag)];
    if (imageView.hidden == NO) {
        imageView.hidden = YES;
    }
    
    KDChatInputBoardModal *modal = self.mArrayModals[button.tag];
    void (^block)() = modal.block;
    if (block != nil) {
        block();
    }
}

- (UIPageControl *)pageControl
{
    if (!_pageControl)
    {
        _pageControl = [UIPageControl new];
        _pageControl.currentPageIndicatorTintColor = RGBACOLOR(23, 131, 253, 1.0f);
        _pageControl.numberOfPages = ceil(self.mArrayModals.count/8.0);
        _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
//        if (isAboveiOS6) {
            _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
            _pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
//        }
        _pageControl.hidesForSinglePage = YES;
    }
    return _pageControl;
}

- (void)setupVFL
{
    NSArray *arrayVFLs = @[
                           @"|[scrollViewBG]|",
                           @"V:|[scrollViewBG]|",
                           @"|-[pageControl]-|",
                           @"V:[pageControl]-2-|",
                           ];
    
    NSDictionary *dictViews = @{
                                @"scrollViewBG": self.scrollViewBG,
                                @"pageControl": self.pageControl,
                                
                                };
    
    for (NSString *strVFL in arrayVFLs)
    {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:strVFL
                                                                     options:nil
                                                                     metrics:nil
                                                                       views:dictViews]];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.scrollViewBG.frame.size.width;
    float fractionalPage = self.scrollViewBG.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [self addSubview:self.scrollViewBG];
    [self addSubview:self.pageControl];
    [self setupVFL];
}

-(CGFloat)caculateCellHeight:(NSString *)string
{
    //计算一下文本的行数，如果超出一行，将标签高度变成2行。
    CGSize textSize = {item_width, 10000.0};
    CGSize size = [string sizeWithFont:FS6 constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    return size.height >= item_height - item_width ? (item_height - item_width) * 2 : item_height - item_width;
}
@end
