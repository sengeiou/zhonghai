//
//  KDToDoViewCell.m
//  kdweibo
//
//  Created by janon on 15/4/6.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDToDoViewCell.h"
#import "KDToDoMessageDataModel.h"
#import "UIImageView+WebCache.h"
#import "ContactUtils.h"
#import "KDToDoViewController.h"
#import "RTLabel.h"

#define KDSearchCellContentTextMaxWidth (ScreenFullWidth - 44.0 - (3 * [NSNumber kdDistance1]))

#define BOSCOLORWITHRGBA(rgbValue, alphaValue)		[UIColor colorWithRed:((float)(((rgbValue) & 0xFF0000) >> 16))/255.0 \
green:((float)(((rgbValue) & 0x00FF00) >> 8))/255.0 \
blue:((float)((rgbValue) & 0x0000FF))/255.0 \
alpha:(alphaValue)]

@interface KDToDoViewCell ()<KDPopoverDataSource>
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) RTLabel *headLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) RTLabel *textView;
@property (nonatomic, strong) UILabel *doneState;
@property (nonatomic, strong) UIView *containorView;
@property (nonatomic, strong) UIImageView *actionImageView;
@property (nonatomic, strong) UIImageView *redDot;
@property(nonatomic, strong) KDToDoMessageDataModel *model;


@property (nonatomic, strong) KDMarkModel *markModel;
@property (nonatomic, weak) XTChatViewController *chatViewController;

@property (nonatomic,strong)KDPopover *popoverMain;
@end

@implementation KDToDoViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initSome];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initSome];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self initSome];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initSome];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)initSome
{
    self.backgroundColor = [UIColor kdBackgroundColor1];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.contentView addGestureRecognizer:longPress];
    
//    CGRect contaionorFrame = CGRectMake(8, 8, [UIScreen mainScreen].bounds.size.width - 16, 154);
//    CGRect headImageViewFrame = CGRectMake(8, 8, 40, 40);
//    CGRect headLabelFrame = CGRectMake(56, 8, [UIScreen mainScreen].bounds.size.width - 96, 21);
//    CGRect timeLabelFrame = CGRectMake(57, 25, 56, 21);
//    CGRect textViewFrame = CGRectMake(16, 64, [UIScreen mainScreen].bounds.size.width - 32, 80);
    CGRect redDotFrame = CGRectMake([UIScreen mainScreen].bounds.size.width - 30, 14, 8, 8);
    CGRect actionImageViewFrame = CGRectMake([UIScreen mainScreen].bounds.size.width - 30, 72, 8, 14);
    
    CGRect doneStateFrame = CGRectMake([UIScreen mainScreen].bounds.size.width - 45, 30, 50, 12);
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:AppLanguage]isEqualToString:@"en"]) {
        doneStateFrame.origin.x -= 10;
    }
    
    self.containorView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.containorView setBackgroundColor:[UIColor kdBackgroundColor2]];
    [self.containorView.layer setBorderWidth:0.5];
    [self.containorView.layer setBorderColor:[UIColor kdDividingLineColor].CGColor];
    [self.containorView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentView addSubview:self.containorView];

    
    self.headImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.headImageView setBackgroundColor:[UIColor clearColor]];
    self.headImageView.layer.cornerRadius = (ImageViewCornerRadius==-1?20:ImageViewCornerRadius);
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.layer.shouldRasterize = YES;
    self.headImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    [self.headImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.containorView addSubview:self.headImageView];
    
    self.headLabel = [[RTLabel alloc] initWithFrame:CGRectZero];
    [self.headLabel setBackgroundColor:[UIColor clearColor]];
    self.headLabel.font = FS4;
    self.headLabel.textColor = FC1;
    self.headLabel.textAlignment = NSTextAlignmentLeft;
    [self.headLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.containorView addSubview:self.headLabel];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.timeLabel setBackgroundColor:[UIColor clearColor]];
    [self.timeLabel setTextAlignment:NSTextAlignmentLeft];
    [self.timeLabel setTextColor:FC2];
    [self.timeLabel setFont:FS6];
    [self.timeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.containorView addSubview:self.timeLabel];
    
    self.doneState = [[UILabel alloc]initWithFrame:doneStateFrame];
    [self.doneState setBackgroundColor:[UIColor clearColor]];
    [self.doneState setFont:[UIFont systemFontOfSize:11]];
    
    self.textView = [[RTLabel alloc] initWithFrame:CGRectZero];
    [self.textView setFont:FS4];
    [self.textView setTextColor:FC1];
//    [self.textView setNumberOfLines:4];
    self.textView.backgroundColor = [UIColor clearColor];
    [self.textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentView addSubview:self.textView];
    
    self.actionImageView = [[UIImageView alloc] initWithFrame:actionImageViewFrame];
    self.actionImageView.image = [UIImage imageNamed:@"cell_arrow"];
    [self.containorView addSubview:self.actionImageView];
    
    self.redDot = [[UIImageView alloc] initWithFrame:redDotFrame];
    [self.redDot setBackgroundColor:[UIColor clearColor]];
    [self.redDot setContentMode:UIViewContentModeScaleAspectFit];
    [self.redDot setImage:[UIImage imageNamed:@"common_img_new"]];
    

    NSLayoutConstraint *constraint = nil;
    
    //containorView
    constraint = [NSLayoutConstraint constraintWithItem:self.containorView
                                              attribute:NSLayoutAttributeLeading
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeLeading
                                             multiplier:1.0f
                                               constant:0];
    [self.contentView addConstraint:constraint];
    
    //containorView
    constraint = [NSLayoutConstraint constraintWithItem:self.containorView
                                              attribute:NSLayoutAttributeTrailing
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeTrailing
                                             multiplier:1.0f
                                               constant:0];
    [self.contentView addConstraint:constraint];
    
    //containorView
    constraint = [NSLayoutConstraint constraintWithItem:self.containorView
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1.0f
                                               constant:8];
    [self.contentView addConstraint:constraint];
    
    //containorView
    constraint = [NSLayoutConstraint constraintWithItem:self.containorView
                                              attribute:NSLayoutAttributeBottom
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeBottom
                                             multiplier:1.0f
                                               constant:0];
    [self.contentView addConstraint:constraint];
    
    //headImageView
    constraint = [NSLayoutConstraint constraintWithItem:self.headImageView
                                              attribute:NSLayoutAttributeLeading
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.containorView
                                              attribute:NSLayoutAttributeLeading
                                             multiplier:1.0f
                                               constant:12];
    [self.containorView addConstraint:constraint];
    
    //headImageView
    constraint = [NSLayoutConstraint constraintWithItem:self.headImageView
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.containorView
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1.0f
                                               constant:14];
    [self.containorView addConstraint:constraint];
    
    //headImageView
    constraint = [NSLayoutConstraint constraintWithItem:self.headImageView
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:0
                                               constant:40];
    [self.headImageView addConstraint:constraint];
    
    //headImageView
    constraint = [NSLayoutConstraint constraintWithItem:self.headImageView
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:0
                                               constant:40];
    [self.headImageView addConstraint:constraint];
    
    //headLabel
    constraint = [NSLayoutConstraint constraintWithItem:self.headLabel
                                              attribute:NSLayoutAttributeLeading
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.containorView
                                              attribute:NSLayoutAttributeLeading
                                             multiplier:1.0f
                                               constant:64];
    [self.containorView addConstraint:constraint];
    
    //headLabel
    constraint = [NSLayoutConstraint constraintWithItem:self.headLabel
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.containorView
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1.0f
                                               constant:15];
    [self.containorView addConstraint:constraint];
    
    //headLabel
    constraint = [NSLayoutConstraint constraintWithItem:self.headLabel
                                              attribute:NSLayoutAttributeTrailing
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.containorView
                                              attribute:NSLayoutAttributeTrailing
                                             multiplier:1.0f
                                               constant:-31];
    [self.containorView addConstraint:constraint];
    
    //headLabel
    constraint = [NSLayoutConstraint constraintWithItem:self.headLabel
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:0
                                               constant:21];
    [self.headLabel addConstraint:constraint];
    
    //timeLabel
    constraint = [NSLayoutConstraint constraintWithItem:self.timeLabel
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.containorView
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1.0f
                                               constant:33];
    [self.containorView addConstraint:constraint];
    
    //timeLabel
    constraint = [NSLayoutConstraint constraintWithItem:self.timeLabel
                                              attribute:NSLayoutAttributeLeading
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.containorView
                                              attribute:NSLayoutAttributeLeading
                                             multiplier:1.0f
                                               constant:64];
    [self.containorView addConstraint:constraint];
    
    //timeLabel
    constraint = [NSLayoutConstraint constraintWithItem:self.timeLabel
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:0
                                               constant:19];
    [self.timeLabel addConstraint:constraint];
    
    //timeLabel
    constraint = [NSLayoutConstraint constraintWithItem:self.timeLabel
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:0
                                               constant:100];
    [self.timeLabel addConstraint:constraint];
    
    
    //doneSate
//    constraint = [NSLayoutConstraint constraintWithItem:self.doneState
//                                              attribute:NSLayoutAttributeTop
//                                              relatedBy:NSLayoutRelationEqual
//                                                 toItem:self.containorView
//                                              attribute:NSLayoutAttributeTop
//                                             multiplier:1.0f
//                                               constant:25];
//    [self.containorView addConstraint:constraint];
//    
//    //doneSate
//    constraint = [NSLayoutConstraint constraintWithItem:self.doneState
//                                              attribute:NSLayoutAttributeLeading
//                                              relatedBy:NSLayoutRelationEqual
//                                                 toItem:self.containorView
//                                              attribute:NSLayoutAttributeLeading
//                                             multiplier:1.0f
//                                               constant:265];
//    [self.containorView addConstraint:constraint];
//    
//    //doneSate
//    constraint = [NSLayoutConstraint constraintWithItem:self.doneState
//                                              attribute:NSLayoutAttributeHeight
//                                              relatedBy:NSLayoutRelationEqual
//                                                 toItem:nil
//                                              attribute:NSLayoutAttributeNotAnAttribute
//                                             multiplier:0
//                                               constant:21];
//    [self.containorView addConstraint:constraint];
//    
//    //doneSate
//    constraint = [NSLayoutConstraint constraintWithItem:self.doneState
//                                              attribute:NSLayoutAttributeWidth
//                                              relatedBy:NSLayoutRelationEqual
//                                                 toItem:nil
//                                              attribute:NSLayoutAttributeNotAnAttribute
//                                             multiplier:0
//                                               constant:56];
//    [self.containorView addConstraint:constraint];

    
    
    //textView
    constraint = [NSLayoutConstraint constraintWithItem:self.textView
                                              attribute:NSLayoutAttributeLeading
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeLeading
                                             multiplier:1.0f
                                               constant:64];
    [self.contentView addConstraint:constraint];
    
    //textView
    constraint = [NSLayoutConstraint constraintWithItem:self.textView
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1.0f
                                               constant:64];
    [self.contentView addConstraint:constraint];
    
    //textView
    constraint = [NSLayoutConstraint constraintWithItem:self.textView
                                              attribute:NSLayoutAttributeTrailing
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeTrailing
                                             multiplier:1.0f
                                               constant:-30];
    [self.contentView addConstraint:constraint];
    
    //textView
    constraint = [NSLayoutConstraint constraintWithItem:self.textView
                                              attribute:NSLayoutAttributeBottom
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeBottom
                                             multiplier:1.0f
                                               constant:-14];
    [self.contentView addConstraint:constraint];
 
    
}

- (KDPopover *)popoverMain
{
    if (!_popoverMain) {
        _popoverMain = [KDPopover new];
        _popoverMain.dataSource = self;
    }
    return _popoverMain;
}

- (NSInteger)itemCountForRow {
    if (isAboveiPhone6) {
        return 5;
    } else {
        return 4;
    }
}

- (NSArray<KDItem *> *)itemModels:(KDPopover *)popover
{
    __weak KDToDoViewCell *weakSelf = self;
    
    NSMutableArray *menuArray = [[NSMutableArray alloc] init];
    
    KDItem *marktem = [[KDItem alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_mark")
                                           subtitle:nil
                                              image:[UIImage imageNamed:@"message_popup_mark"]
                                   highlightedImage:nil
                                            onPress:^(NSObject *sender){
                                                [weakSelf mark:nil];
                                            }];
    [menuArray addObject:marktem];

    
    KDItem *deleteItem = [[KDItem alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_13")
                                              subtitle:nil
                                                 image:[UIImage imageNamed:@"message_popup_delete"]
                                      highlightedImage:nil
                                               onPress:^(NSObject *sender){
                                                   [weakSelf deleteBubbleCell:nil];
                                               }];
    
    [menuArray addObject:deleteItem];
    if ([self.model.todoStatus isEqualToString:@"undo"]) {
        KDItem *doneItem = [[KDItem alloc] initWithTitle:ASLocalizedString(@"BubbleTableViewCell_Tip_20")
                                                subtitle:nil
                                                   image:[UIImage imageNamed:@"message_popup_igore"]
                                        highlightedImage:nil
                                                 onPress:^(NSObject *sender){
                                                     [weakSelf changeToDone:nil];
                                                 }];
        
        [menuArray addObject:doneItem];
    }
    return menuArray;
}

- (void)longPress:(UILongPressGestureRecognizer *)sender {
    
    
    if ([sender state] != UIGestureRecognizerStateBegan)
        return;
    
    [self becomeFirstResponder];
    [self.popoverMain showAt:self.headLabel containView:self.todoVC.view];
}


- (void)deleteBubbleCell:(id)sender {
    [KDEventAnalysis event:event_msg_del];
    
    
//    KDToDoMessageDataModel *deleteModel = self.todoArray[_indexPath.row];
//    PersonSimpleDataModel *pubData =[self.group.participant firstObject];
//    NSString *groupId = self.group.groupId;
//    
//    if ([[XTDataBaseDao sharedDatabaseDaoInstance]deleteToDoDataWithMsgId:deleteModel.msgId]) {
//        
//        //            if (pubData.personId.length > 0) {
//        //                [[XTDeleteService shareService] deleteMessageWithPublicId:pubData.personId groupId:groupId msgId:deleteModel.msgId];
//        //
//        //            }
//        //            else
//        //            {
//        [[XTDeleteService shareService] deleteMessageWithGroupId:groupId msgId:deleteModel.msgId];
        //            }

    
    //消息表删除消息
    BOOL deleteMsg = [[XTDataBaseDao sharedDatabaseDaoInstance] deleteToDoDataWithMsgId:self.model.msgId];
    
    //状态表删除状态
//    [[XTDataBaseDao sharedDatabaseDaoInstance] deleteToDoStateWithMessageId:self.model.sourceMsgId];
    
    if (deleteMsg) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(bubbleDidDeleteMsgWithModel:cell:)]) {
            [self.delegate bubbleDidDeleteMsgWithModel:self.model cell:self];
        }
        DLog(@"删除成功");
    }
    else {
        DLog(@"没有删除成功");
    }
}

#define MARK_ALERT_TAG 12312389
- (void)mark:(id)sender {
    
    __weak __typeof(self) weakSelf = self;
    
    [KDAlert showLoading];
    [[KDOpenAPIClientWrapper sharedInstance] createMark:2 messageId:self.model.msgId todoId:self.model.msgId groupId:self.model.groupId appId:self.model.appid title:self.model.title text:(self.model.text.length==0?self.model.content:self.model.text) url:self.model.url fileId:nil icon:self.model.name completion:^(BOOL succ, NSString * error, id data) {
        [KDAlert hideLoading];
        if (succ) {
            [[KDUserDefaults sharedInstance] consumeFlag:kMarkUsed];
            if ([data isKindOfClass:[NSDictionary class]]) {
                weakSelf.markModel = [[KDMarkModel alloc] initWithDict:data];
            }
            [KDAlert showAlert:MARK_ALERT_TAG title:ASLocalizedString(@"Marked") message:ASLocalizedString(@"KDToDoViewCell_alertTips") delegate:self buttonTitles:@[ASLocalizedString(@"KDApplicationQueryAppsHelper_yes"), ASLocalizedString(@"KDApplicationQueryAppsHelper_no")]];
        } else {
            [KDAlert showToastInView:weakSelf.chatViewController.view text:error];
        }
    }];
}

- (void)changeToDone:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeUndoMsgWithModel:cell:)]) {
        [self.delegate changeUndoMsgWithModel:self.model cell:self];
    }
}



- (BOOL)canBecomeFirstResponder {
    return YES;
}
- (void)anotherSetCellInformation:(KDToDoMessageDataModel *)model
{
    self.model = model;
    [self.redDot removeFromSuperview];
    [self.containorView setBackgroundColor:[UIColor whiteColor]];
    
    if (model.msgType == MessageTypeAttach || model.msgType == MessageTypeText) {
        [self.headLabel setText:ASLocalizedString(@"KDToDoViewCell_text")];
        [self.textView setText:model.content];
    }
    else
    {
        if (_searchType && _searchKeyWord.length > 0) {
            [self.headLabel setText:[self highlightWithSearchString:_searchKeyWord ContentString:model.title]];
            [self.textView setText:[self highlightWithSearchString:_searchKeyWord ContentString:model.text]];
        }
        else
        {
            [self.headLabel setText:model.title];
            [self.textView setText:model.text];
        }
    }
     [self.timeLabel setText:[self xtDateFormatter:model.sendTime]];
    if (model.status == MessageStatusUnread)
    {
        [self.containorView addSubview:self.redDot];
    }
    else
    {
        [self.redDot removeFromSuperview];
    }
    NSLog(@"%@",model.todoStatus);
    if (model.todoStatus != nil) {
        [self.containorView addSubview:self.doneState];
        if ([model.todoStatus isEqualToString:@"done"] ) {
            [self.doneState setText:ASLocalizedString(@"KDTodoListViewController_Do")];
            [self.doneState setTextColor:BOSCOLORWITHRGBA(0x88888888, 1.0)];
        }
        else if([model.todoStatus isEqualToString:@"undo"])
        {
            self.doneState.text = ASLocalizedString(@"KDToDoContainorViewController_undoModel_title");
            [self.doneState setTextColor:BOSCOLORWITHRGBA(0xe50000, 1.0)];
        }
        else
        {
            self.doneState.text = model.todoStatus ;
            [self.doneState setTextColor:[UIColor blueColor]];
        }
    }
    else
    {
        [self.doneState removeFromSuperview];
    }
    
    NSURL *imageURL = nil;
    if (model.name.length > 0)
    {
        NSString *url = model.name;
        if ([url rangeOfString:@"?"].location != NSNotFound)
        {
            url = [url stringByAppendingFormat:@"&spec=180"];
        }
        else
        {
            url = [url stringByAppendingFormat:@"?spec=180"];
        }
        imageURL = [NSURL URLWithString:url];
    }
    [self.headImageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"app_default_icon.png"]];
    
    CGRect actionFrame = self.actionImageView.frame;
    actionFrame.origin.y = (model.normalCellHeight - 16) / 2 - 3;
    self.actionImageView.frame = actionFrame;
}

- (NSString *)xtDateFormatter:(NSString *)fullDateString
{
    if (fullDateString == nil || [@"" isEqualToString:fullDateString])
    {
        return @"";
    }
    
    if (fullDateFormatter == nil)
    {
        fullDateFormatter = [[NSDateFormatter alloc] init];
    }
    [fullDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *fullDate = [fullDateFormatter dateFromString:fullDateString];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = nil;
    NSInteger unitFlags = NSYearCalendarUnit;
    comps = [calendar components:unitFlags fromDate:fullDate];
    int fullDateYear = (int)[comps year];
    comps = [calendar components:unitFlags fromDate:[NSDate date]];
    int nowDateYear = (int)[comps year];
    
    NSString *fullShortString = [fullDateString substringToIndex:10];
    if (fullDateYear != nowDateYear) {
        return fullShortString;
    }
    
    if (shortDateFormatter == nil) {
        shortDateFormatter = [[NSDateFormatter alloc] init];
    }
    [shortDateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *fullShortDate = [shortDateFormatter dateFromString:fullShortString];
    
    NSInteger dayDiff = (int)[fullShortDate timeIntervalSinceNow] / (60*60*24);
    
    if (lastDateFormatter == nil) {
        lastDateFormatter = [[NSDateFormatter alloc] init];
    }
    
    switch (dayDiff) {
        case 0:
            [lastDateFormatter setDateFormat:@"HH:mm"];
            break;
        case -1:
            [lastDateFormatter setDateFormat:ASLocalizedString(@"KDToDoOperateCell_Yesterday")];
            break;
        case -2:
            [lastDateFormatter setDateFormat:ASLocalizedString(@"KDToDoOperateCell_TheDayBeforeYesterday")];
            break;
        default:
            [lastDateFormatter setDateFormat:@"MM-dd"];
            break;
    }
    return [lastDateFormatter stringFromDate:fullDate];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == MARK_ALERT_TAG) {
        
        if (buttonIndex == 0) {
//            [KDMarkModel gotoH5Guide:self.chatViewController];
            return;
        }
        [KDMarkModel onSetEvent:self.todoVC model:self.markModel];
    }
}

- (NSString *)highlightWithSearchString:(NSString *)searchString ContentString:(NSString *)contentString
{
    NSString *resultString = nil;
        NSRange range = [[contentString lowercaseString] rangeOfString:searchString.lowercaseString];
        if (range.location != NSNotFound) {
           
            if (range.location >= 10)
            {
                NSString *tempString = contentString ;
                tempString = [contentString substringFromIndex:range.location];
                tempString = [NSString stringWithFormat:@"...%@",tempString];
                resultString = [tempString stringByReplacingOccurrencesOfString:searchString withString:[NSString stringWithFormat:@"<font color=\"#3CBAFF\">%@</font>", [contentString substringWithRange:range]]];
            }else
            {
                resultString = [contentString stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"<font color=\"#3CBAFF\">%@</font>", [contentString substringWithRange:range]]];
            }
        }else
            resultString = contentString;
    
    return resultString;
}


@end
