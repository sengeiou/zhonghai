//
//  KDTaskEditorView.m
//  kdweibo
//
//  Created by bird on 13-11-23.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDTaskEditorView.h"
#import "KDTask.h"
#import "KDExpressionInputView.h"
#import "KDTrendEditorViewController.h"
#import "TwitterText.h"
#import "UIViewAdditions.h"
#import "NSDate+Additions.h"
#import "KDDocumentIndicatorView.h"
#import "KDDefaultViewControllerContext.h"

@implementation UserPortraitGroupCell
@synthesize groupView =groupView_;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
     
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
//        title_ = [[UILabel alloc] initWithFrame:CGRectZero];
//        title_.backgroundColor = [UIColor clearColor];
//        title_.textColor = MESSAGE_NAME_COLOR;
//        title_.font = [UIFont systemFontOfSize:14.0f];
//        title_.text = ASLocalizedString(@"KDTaskEditorView_title_text");
//        [self.contentView addSubview:title_];
        
        groupView_ = [[KDUserPortraitGroupView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:groupView_];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    rect.origin.y = USERPORTRAIT_TITLE_MARGIN;
    rect.size.height = 27.f;
    title_.frame = rect;
    
    rect.origin.y = CGRectGetMaxY(title_.frame);
    rect.origin.x = 0;
    rect.size.width = rect.size.width;
    groupView_.frame = rect;
    
}
- (void)setUsers:(NSArray *)users
{
    groupView_.users = users;
    
}
- (void)dealloc
{
    //KD_RELEASE_SAFELY(groupView_);
    //KD_RELEASE_SAFELY(title_);
    //[super dealloc];
}
@end


@interface TaskEditorItemCell : UITableViewCell
@property(nonatomic,retain)UILabel *leftLabel;
@property(nonatomic,retain)UILabel *rightLabel;
@property(nonatomic,retain)UIImageView *accessoryImageView;
@property(nonatomic,retain)UIImageView *iconImageView;
@property(nonatomic,retain)UIView      *backgroundView;
@property(nonatomic,retain)UIView  *highlightedView;
@end

@implementation TaskEditorItemCell

@synthesize leftLabel = leftLabel_;
@synthesize rightLabel = rightLabel_;
@synthesize accessoryImageView = accessoryImageView_;
@synthesize iconImageView = iconImageView_;
@synthesize backgroundView = backgroundView_;
@synthesize highlightedView = highlightedView_;

- (void)dealloc {
    //KD_RELEASE_SAFELY(highlightedView_);
    //KD_RELEASE_SAFELY(iconImageView_);
    //KD_RELEASE_SAFELY(leftLabel_);
    //KD_RELEASE_SAFELY(rightLabel_);
    //KD_RELEASE_SAFELY(accessoryImageView_);
    //[super dealloc];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (point.y > CGRectGetMaxY(self.backgroundView.frame)) {
        return NO;
    }else {
        return [super pointInside:point withEvent:event];
    }
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
//        UIImage *bgImg = [UIImage imageNamed:@"todo_bg"];
//        bgImg = [bgImg stretchableImageWithLeftCapWidth:bgImg.size.width/2.0f topCapHeight:bgImg.size.height/2.0f];
        backgroundView_ = [[UIImageView alloc] initWithFrame:self.frame];// autorelease];
        backgroundView_.userInteractionEnabled = YES;
        backgroundView_.backgroundColor = [UIColor kdBackgroundColor2];
        [self addSubview:backgroundView_];
        
        highlightedView_ = [[UIView alloc] initWithFrame:CGRectZero];
        [backgroundView_ addSubview:highlightedView_];
        
        iconImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
        [backgroundView_ addSubview:iconImageView_];
        
        leftLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
        leftLabel_.backgroundColor = [UIColor clearColor];
        leftLabel_.font = [UIFont systemFontOfSize:16];
        leftLabel_.textColor = MESSAGE_TOPIC_COLOR;
        leftLabel_.textAlignment = NSTextAlignmentLeft;
        [backgroundView_ addSubview:leftLabel_];
        
        rightLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
        rightLabel_.backgroundColor = [UIColor clearColor];
        rightLabel_.font = [UIFont systemFontOfSize:14];
        rightLabel_.textColor = MESSAGE_NAME_COLOR;
        [backgroundView_ addSubview:rightLabel_];
        rightLabel_.textAlignment = NSTextAlignmentRight;
        
        accessoryImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_edit_narrow_v3"]];
        [backgroundView_ addSubview: accessoryImageView_];
        
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.bounds;
    
    frame.origin.x = 7.0f;
    frame.size.width -= 2*7;
    backgroundView_.frame = frame;
    highlightedView_.frame = CGRectInset(backgroundView_.bounds, 0.5, 0.5);
    
    if (iconImageView_.image) {
        [iconImageView_ sizeToFit];
        frame = iconImageView_.bounds;
        frame.origin.x = 6.0f;
        frame.origin.y = (CGRectGetHeight(self.bounds)-CGRectGetHeight(frame))*0.5;
        iconImageView_.frame = frame;
    }
    
    if (leftLabel_.text) {
        [leftLabel_ sizeToFit];
        frame = leftLabel_.bounds;
        frame.origin.x = CGRectGetMaxX(iconImageView_.frame) + 10.0f;
        frame.origin.y = (CGRectGetHeight(self.bounds)-CGRectGetHeight(frame))*0.5;
        frame.size.width = 90;
        leftLabel_.frame = frame;
    }
    
    if (rightLabel_.text) {
        [rightLabel_ sizeToFit];
        frame = rightLabel_.bounds;
        CGFloat width = MIN(CGRectGetWidth(rightLabel_.frame), 140);
        frame.origin.x = CGRectGetWidth(self.bounds) -width- 25 - 14;
        frame.origin.y = (CGRectGetHeight(self.bounds)-CGRectGetHeight(frame))*0.5;
        frame.size.width = width;
        rightLabel_.frame = frame;
        
    }
    if (accessoryImageView_.image) {
        [accessoryImageView_ sizeToFit];
        frame = accessoryImageView_.bounds;
        frame.origin.x = CGRectGetWidth(self.bounds)- CGRectGetWidth(accessoryImageView_.frame) -10 - 14;
        frame.origin.y = (CGRectGetHeight(self.bounds)-CGRectGetHeight(frame))*0.5;
        accessoryImageView_.frame = frame;
    }
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    // Configure the view for the selected state
    if (!accessoryImageView_.hidden) {
        highlightedView_.backgroundColor = highlighted?[UIColor colorWithRed:240/255.0 green:241/255.0 blue:242/255.f alpha:1.0f]:[UIColor clearColor];
        accessoryImageView_.image = highlighted?[UIImage imageNamed:@"smallTriangle"]:[UIImage imageNamed:@"profile_edit_narrow_v3"];
    }
}
@end

@interface KDTaskEditorView() <KDPostActionMenuViewDelegate, KDExpressionInputViewDelegate, HPGrowingTextViewDelegate, UIGestureRecognizerDelegate, KDDocumentIndicatorViewDelegate>
@property (nonatomic, retain) KDPostActionMenuView *actionMenuView;
@property (nonatomic, retain) KDExpressionInputView *expressionInputView;
@property (nonatomic, retain) NSDate *needFinishDate;
@property (nonatomic, retain) KDDatePickerViewController *datePicker;
@end

@implementation KDTaskEditorView
@synthesize task  = task_;
@synthesize actionMenuView = actionMenuView_;
@synthesize expressionInputView = expressionInputView_;
@synthesize needFinishDate = needFinishDate_;
@synthesize datePicker = datePicker_;
@synthesize delegate = delegate_;
@synthesize type = type_;
@synthesize textView = textView_;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidHide:)
                                                     name:  UIKeyboardDidHideNotification
                                                   object:nil];
        
        [self initSubViews];
        
        executors_ = [NSMutableArray array];// retain];
    }
    return self;
}
- (void)initSubViews
{
    CGRect frame = self.bounds;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
        frame.size.height -= 44+20.f;
    
    tableView_ = [[UITableView alloc] initWithFrame:frame];
    tableView_.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView_.backgroundColor = [UIColor kdBackgroundColor2];
    tableView_.separatorColor = [UIColor kdBackgroundColor1];
    [self addSubview:tableView_];
    tableView_.delegate = self;
    tableView_.dataSource = self;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    recognizer.delegate = self;
    [self addGestureRecognizer:recognizer];
//    [recognizer release];
    
    frame.origin = CGPointMake(0, 32);
    frame.size.height = 30;
    //frame.size.width -= 2*10;
    
    textView_ = [[HPGrowingTextView alloc] initWithFrame:frame];
    textView_.contentInset = UIEdgeInsetsMake(5, 10, 5, 10);
    
	textView_.minNumberOfLines = 3;
	textView_.maxNumberOfLines = 5;
    
    if (![UIDevice isRunningOveriPhone5])
        textView_.maxNumberOfLines = 4;
    
	//textView.returnKeyType = UIReturnKeyGo; //just as an example
    textView_.internalTextView.inputAccessoryView = self.actionMenuView;
	textView_.font = [UIFont systemFontOfSize:15.0f];
	textView_.growingDelegate = self;
    textView_.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 10, 5, 10);
    textView_.backgroundColor = [UIColor clearColor];
    textView_.internalTextView.backgroundColor = [UIColor clearColor];
    textView_.scrollEnabled = NO;
    [tableView_ addSubview:textView_];
    flag_.textViewHeight = CGRectGetHeight(textView_.bounds);
    
    frame.origin.y += 5.5f;
    frame.origin.x += 15.0f;
    frame.size.width -= 15*2.f;
    taskContentView_ = [[KDExpressionLabel alloc] initWithFrame:frame andType:KDExpressionLabelType_Expression urlRespondFucIfNeed:NULL];
    taskContentView_.backgroundColor = [UIColor kdBackgroundColor2];
    taskContentView_.font = [UIFont systemFontOfSize:15.0];
    taskContentView_.textColor = MESSAGE_TOPIC_COLOR;
   // taskContentView_.textAlignment = UITextLayoutDirectionUp;
    [tableView_ addSubview:taskContentView_];
    
    
    wordLimitLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(textView_.bounds.size.width - 65, CGRectGetHeight(textView_.frame)-7+32, 80, 18)];
    wordLimitLabel_.backgroundColor = [UIColor clearColor];
    wordLimitLabel_.font = [UIFont boldSystemFontOfSize:12.0];
    wordLimitLabel_.textAlignment = NSTextAlignmentCenter;
    wordLimitLabel_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [textView_.superview addSubview:wordLimitLabel_];
    
    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
//    label.backgroundColor = [UIColor clearColor];
//    label.font = [UIFont systemFontOfSize:14.f];
//    label.textColor = MESSAGE_NAME_COLOR;
//    label.text = ASLocalizedString(@"KDTaskEditorView_label_text");
//    tableView_.tableHeaderView = [label autorelease];

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)setTask:(KDTask *)task
{
    if (task_ != task) {
//        [task_ release];
        task_ = nil;
        
        task_ = task;// retain];
        
        textView_.text = [task.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        taskContentView_.text = [task.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        CGRect rect = taskContentView_.frame;
        rect.size = [taskContentView_ sizeThatFits:CGSizeMake(rect.size.width, MAXFLOAT)];
        taskContentView_.frame = rect;
        
        self.needFinishDate = task_.needFinishDate;
        
        [executors_ removeAllObjects];
        [executors_ addObjectsFromArray:task.executors];
        
        [tableView_ reloadData];
        
        [self updateWordLimitsLabel];
    }

}
- (void)setType:(KDTaskPageInfoType)type
{
    if (type_ != type) {
        
        type_ = type;
        if (type == KDTaskPageDetailType) {
            taskContentView_.hidden = NO;
            textView_.hidden = YES;
            wordLimitLabel_.hidden = YES;
        }
        else if(type == KDTaskPageEditorType)
        {
            taskContentView_.hidden = YES;
            textView_.hidden = NO;
            wordLimitLabel_.hidden = NO;
        }
        
        [tableView_ reloadData];
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];

    //KD_RELEASE_SAFELY(_status);
    //KD_RELEASE_SAFELY(taskContentView_);
    //KD_RELEASE_SAFELY(executors_);
    //KD_RELEASE_SAFELY(datePicker_);
    //KD_RELEASE_SAFELY(needFinishDate_);
    //KD_RELEASE_SAFELY(textView_);
    //KD_RELEASE_SAFELY(wordLimitLabel_);
    //KD_RELEASE_SAFELY(task_);
    //KD_RELEASE_SAFELY(tableView_);
    //KD_RELEASE_SAFELY(actionMenuView_);
    //KD_RELEASE_SAFELY(expressionInputView_);

    //[super dealloc];
}

#pragma mark - DatePick Methods
#pragma mark -  DatePicker Stuff
- (KDDatePickerViewController *)datePicker {
    if (!datePicker_) {
        datePicker_ = [[KDDatePickerViewController alloc] init];
        datePicker_.date = self.needFinishDate;
        
        self.datePicker.leftbtnTappedEventHander = ^(void) {
            [self dismissDatePicker];
        };
        
        self.datePicker.rightTappedEventHander = ^(void) {
            
            self.needFinishDate = self.datePicker.date;
            [self dismissDatePicker];
            
            [tableView_ reloadData];
        };
    }
    return datePicker_;
}
- (void)displayDatePicker {
    [self.datePicker showInView:((UIViewController *)self.delegate).navigationController.view.window];
}

- (void)dismissDatePicker {

    [self.datePicker hide];
}


#pragma mark - WordLimitsLabel Methods
- (NSString *)stringTobeCounted {
    return textView_.text;
}
- (void)updateWordLimitsLabel {
    
    NSInteger remainingCount = [TwitterText remainingCharacterCount:[self stringTobeCounted]];
    wordLimitLabel_.textColor = (remainingCount < 0) ? [UIColor redColor] :[UIColor colorWithRed:155.0f/255 green:155.0f/255 blue:155.0f/255 alpha:1.0f];
    wordLimitLabel_.text = [NSString stringWithFormat:@"%ld", (long)remainingCount];
}
#pragma mark - MenuView Get Methods
- (KDPostActionMenuView *)actionMenuView {
    if (!actionMenuView_) {
        actionMenuView_= [[KDPostActionMenuView alloc] initWithFrame:CGRectMake(0.0, self.bounds.size.height-44.0, self.bounds.size.width, 44.0)];
        
        actionMenuView_.delegate = self;
        actionMenuView_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        actionMenuView_.align = KDPostActionMenuViewAlignLeft;
        //[self.view addSubview:actionMenuView_];
        [actionMenuView_ menuButtonItemHidden:YES atIndex:0];
        [actionMenuView_ menuButtonItemHidden:YES atIndex:1];
        [actionMenuView_ menuButtonItemHidden:YES atIndex:2];
    }
    return actionMenuView_;
}


- (KDExpressionInputView *)expressionInputView {
    if(!expressionInputView_) {
        
        expressionInputView_ = [[KDExpressionInputView alloc] initWithFrame:CGRectMake(0.0f, self.bounds.size.height, self.bounds.size.width, 216.0f)];
        expressionInputView_.delegate = self;
        [expressionInputView_ setSendButtonShown:NO];
        
        //[self.view addSubview:expressionInputView_];
    }
    return expressionInputView_;
}

- (void)switchExpressionView {
    if (textView_.internalTextView.isFirstResponder) {
        flag_.isExpressionViewShow = 1;
        [textView_.internalTextView resignFirstResponder];
    }
}

#pragma mark -
#pragma mark The keyboard notification

- (void)keyboardDidHide:(NSNotification *)notification {
    if (flag_.isExpressionViewShow == 1) {
        flag_.isExpressionViewShow = 0;
        if (((UIButton *)[actionMenuView_ menuButtonItemAtIndex:5]).selected) {
            textView_.internalTextView.inputView = [self expressionInputView];
        }else {
            textView_.internalTextView.inputView = nil;
        }
        if ([textView_.internalTextView canBecomeFirstResponder]) {
            [textView_.internalTextView becomeFirstResponder];
        }
    }
}

- (void)postActionMenuView:(KDPostActionMenuView *)postActionMenuView clickOnMenuItem:(UIButton *)menuItem {
    NSUInteger idx = [postActionMenuView.menuItems indexOfObject:menuItem];
    if (0x00 == idx) {
        //
        
    }else if(0x01 == idx){
        
    }else if(0x02 == idx){
        
    }else if(0x03 == idx){
        // at friend
        if (delegate_) {
            [delegate_ toAtViewController];
        }
        
    }else if(0x04 == idx) {
        // import popular topic
        if (delegate_) {
            [delegate_ toTopicViewController];
        }
    }else if(0x05 == idx) {
        [self switchExpressionView];
    }
}

- (void)appendText:(NSString *)text {
    if(text == nil) return;
    
    //    if(flag_.isViewDidUnload == 1){
    //        flag_.isViewDidUnload = 0;
    //        // current view controller did receieve memory warning
    //        // and text view did destoried. So append the text to tempoary variable
    //
    //        self.contentBackup = [NSString stringWithFormat:@"%@%@", (contentBackup_ != nil) ? contentBackup_ : @"", text];
    //        return;
    //    }
    
    // append text to current text input cursor
    NSMutableString *body = [NSMutableString string];
    BOOL tail = YES;
    NSUInteger idx = 0;
    NSUInteger location = NSNotFound;
    if([textView_.internalTextView hasText]){
        [body appendString:textView_.text];
        
        NSRange range = textView_.internalTextView.selectedRange;
        if(range.location != NSNotFound && range.location < [body length]){
            tail = NO;
            idx = location = range.location;
        }
    }
    
    if(tail){
        [body appendString:text];
        
    }else {
        [body insertString:text atIndex:idx];
        location += [text length];
    }
    
    textView_.text = body;
    if(location != NSNotFound){
        textView_.internalTextView.selectedRange = NSMakeRange(location, 0);
    }
    
    [self updateWordLimitsLabel];
}

#pragma mark - KDTrendEditorViewController delegate method

- (void)trendEditorViewController:(KDTrendEditorViewController *)tevc didPickTopicText:(NSString *)topicText {
    [self appendText:topicText];
}

#pragma mark - KDExpressionInputViewDelegate Methods
- (void)expressionInputView:(KDExpressionInputView *)inputView didTapExpression:(NSString *)expressionCode {
    if(flag_.textRange.location != NSNotFound) {
        textView_.text = [textView_.text stringByReplacingCharactersInRange:flag_.textRange withString:expressionCode];
        flag_.textRange.location = flag_.textRange.location + expressionCode.length;
    }else {
        textView_.text = [textView_.text stringByAppendingString:expressionCode];
    }
    
    [self updateWordLimitsLabel];
}

- (void)didTapKeyBoardInExpressionInputView:(KDExpressionInputView *)inputView {
    [self switchExpressionView];
}

- (void)didTapDeleteInExpressionInputView:(KDExpressionInputView *)inputView {
    if(!textView_.text || textView_.text.length == 0 || flag_.textRange.location == 0) return;
    
    NSRegularExpression *topicExpression = [NSRegularExpression regularExpressionWithPattern:@"\\[[^\\[\\]]+\\]" options:NSRegularExpressionAnchorsMatchLines error:NULL];
    NSArray *matches = [topicExpression matchesInString:textView_.text options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, textView_.text.length)];
    
    if(flag_.textRange.location != NSNotFound) {
        for(NSTextCheckingResult *result in matches) {
            NSRange range = result.range;
            if(range.location + range.length == flag_.textRange.location) {
                textView_.text = [textView_.text stringByReplacingCharactersInRange:range withString:@""];
                flag_.textRange.location = range.location;
                [self updateWordLimitsLabel];
                return;
            }
        }
        
        textView_.text = [textView_.text stringByReplacingCharactersInRange:NSMakeRange(--flag_.textRange.location, 1.0f) withString:@""];
        [self updateWordLimitsLabel];
    }else {
        NSTextCheckingResult *lastMatch = [matches lastObject];
        if(lastMatch.range.location + lastMatch.range.length == textView_.text.length) {
            textView_.text = [textView_.text stringByReplacingCharactersInRange:lastMatch.range withString:@""];
            [self updateWordLimitsLabel];
            return;
        }else {
            textView_.text = [textView_.text substringToIndex:textView_.text.length - 1];
            [self updateWordLimitsLabel];
        }
    }
}
#pragma mark - UITextView Delegate
- (BOOL)growingTextViewShouldEndEditing:(HPGrowingTextView *)growingTextView {
    flag_.textRange = growingTextView.internalTextView.selectedRange;
    return YES;
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {
    [self updateWordLimitsLabel];
}


- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView {
    [[actionMenuView_ menuButtonItemAtIndex:0x04] setSelected:NO];
    return YES;
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@""]) {
        if(!growingTextView.text || growingTextView.text.length == 0 || flag_.textRange.location == 0) return YES;
        
        flag_.textRange = growingTextView.internalTextView.selectedRange;
        
        NSRegularExpression *topicExpression = [NSRegularExpression regularExpressionWithPattern:@"\\[[^\\[\\]]+\\]" options:NSRegularExpressionAnchorsMatchLines error:NULL];
        NSArray *matches = [topicExpression matchesInString:growingTextView.text options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, growingTextView.text.length)];
        
        if(flag_.textRange.location != NSNotFound) {
            for(NSTextCheckingResult *result in matches) {
                NSRange range = result.range;
                if(range.location + range.length == flag_.textRange.location) {
                    growingTextView.text = [growingTextView.text stringByReplacingCharactersInRange:range withString:@""];
                    flag_.textRange.location = range.location;
                    growingTextView.internalTextView.selectedRange = flag_.textRange;
                    return NO;
                }
            }
            
            return YES;
        }else {
            NSTextCheckingResult *lastMatch = [matches lastObject];
            if(lastMatch.range.location + lastMatch.range.length == growingTextView.text.length) {
                growingTextView.text = [growingTextView.text stringByReplacingCharactersInRange:lastMatch.range withString:@""];
                return NO;
            }else {
                growingTextView.text = [growingTextView.text substringToIndex:growingTextView.text.length - 1];
            }
            return NO;
        }
    }
    
    return YES;
    
}
- (void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height {
    flag_.textViewHeight = height;
    wordLimitLabel_.frame = CGRectMake(textView_.bounds.size.width - 55, CGRectGetHeight(textView_.frame)-7+32, 80, 18);
    [tableView_ reloadData];
}

#pragma mark - GestrueRecogizer Handler
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return textView_.internalTextView.isFirstResponder;
}

- (void)tapped:(UITapGestureRecognizer *)rgzr {
    [textView_.internalTextView resignFirstResponder];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([textView_.internalTextView isFirstResponder])
        [textView_.internalTextView resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView_ deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 2 && indexPath.row == 0  && type_ == KDTaskPageEditorType) {
        [self displayDatePicker];
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 50;
    switch (indexPath.section) {
        case 0:
            if (type_ == KDTaskPageEditorType)
                height = flag_.textViewHeight+20;
            else if (type_ == KDTaskPageDetailType)
                height = [KDExpressionLabel sizeWithString:[task_.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] constrainedToSize:CGSizeMake(taskContentView_.frame.size.width, CGFLOAT_MAX) withType:KDExpressionLabelType_Expression textAlignment:UITextLayoutDirectionUp textColor:MESSAGE_TOPIC_COLOR textFont:[UIFont systemFontOfSize:15.0f]].height + 20.f;
            
            break;
        case 1:
            if (_status.attachments.count == 0) {
                return 0.0f;
            }
            return [KDDocumentIndicatorView heightForDocumentsCount:_status.attachments.count] +10.f;
            break;
        case 3:
             height = [KDUserPortraitGroupView heightForUserPortraitGroupView:executors_ canbeEdit:type_==KDTaskPageEditorType] + 27.f +USERPORTRAIT_TITLE_MARGIN;
            break;
        case 2:
            height = 50.f;
            break;
        default:
            break;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
        return 1;
    else if(section == 1)
        return 1;
    else if(section == 2)
        return 2;
    else if(section == 3)
        return 1;
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TextCellIdentifier = @"TextCell";
    static NSString *AttachmentCellIdentifier = @"AttachmentCell";
    static NSString *UserCellIdentifier = @"UserCell";
    static NSString *TitleCellIdentifier = @"TitleCell";
    
    if (indexPath.row == 0 && indexPath.section == 0) {
        
        UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:TextCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextCellIdentifier];// autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            
            
            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height)];
            bgView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            bgView.backgroundColor = [UIColor kdBackgroundColor2];
            bgView.layer.borderWidth = 0.5;
            bgView.layer.borderColor = [UIColor clearColor].CGColor;
            bgView.layer.cornerRadius = 2.5;
            
            [cell addSubview:bgView];
            bgView.tag = 0x99;
//            [bgView release];
        }
        UIView *bgView = (UIView *)[cell viewWithTag:0x99];
        if (type_ == KDTaskPageDetailType)
            bgView.layer.cornerRadius = 0.0f;
        else if(type_ == KDTaskPageEditorType)
            bgView.layer.cornerRadius = 2.5;
        
        return cell;
        
    }
    else if(indexPath.row == 0 && indexPath.section == 1){
    
        UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:AttachmentCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AttachmentCellIdentifier];// autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            
            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 9, cell.bounds.size.width, [KDDocumentIndicatorView  heightForDocumentsCount:_status.attachments.count]+10 - 9.f)];
            bgView.backgroundColor = [UIColor kdBackgroundColor2];
            bgView.layer.borderWidth = 0.5;
            bgView.layer.borderColor = [UIColor clearColor].CGColor;
            [cell addSubview:bgView];

            KDDocumentIndicatorView *documentIndicatorView = [[KDDocumentIndicatorView alloc] initWithFrame:CGRectMake(7.5, 9.5, CGRectGetWidth(cell.bounds)-2*7.5, [KDDocumentIndicatorView  heightForDocumentsCount:_status.attachments.count])];// autorelease];
            documentIndicatorView.delegate = self;
            documentIndicatorView.documents = _status.attachments;
            [cell addSubview:documentIndicatorView];
            
            bgView.hidden = _status.attachments.count == 0;
        }
        return cell;
    }
    else if(indexPath.section == 3)
    {
        UserPortraitGroupCell *cell = [tableView_ dequeueReusableCellWithIdentifier:UserCellIdentifier];
        if (!cell) {
            cell = [[UserPortraitGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UserCellIdentifier];// autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        cell.groupView.delegate = self.delegate;
        cell.groupView.editable = type_ == KDTaskPageEditorType;
        [cell setUsers:executors_];
        return cell;
    }
    
    else
    {
        TaskEditorItemCell *cell = [tableView_ dequeueReusableCellWithIdentifier:TitleCellIdentifier];
        if (!cell) {
            cell = [[TaskEditorItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TitleCellIdentifier];// autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor kdBackgroundColor1];
            
            CGRect rect = cell.bounds;
            rect.origin.x = 0;//0.5;
            //rect.size.width -= 2*7 +0.5*2;
            rect.origin.y = 0;
            rect.size.height = 0.5;
            UILabel *label  = [[UILabel alloc] initWithFrame:rect];
            label.tag = 0x88;
            label.backgroundColor = MESSAGE_CT_COLOR;
            [cell.backgroundView addSubview:label];
        }
        UILabel *label  = (UILabel *)[cell viewWithTag:0x88];

        if (indexPath.row == 0) {
            cell.leftLabel.text = ASLocalizedString(@"KDCreateTaskViewController_end_time");
            //cell.iconImageView.image = [UIImage imageNamed:@"task_icon_time"];
            cell.backgroundColor = [UIColor kdBackgroundColor2];
            label.hidden = YES;
            cell.rightLabel.text = [self.needFinishDate formatWithFormatter:KD_DATE_ISO_8601_SHORT_FORMATTER];
            cell.accessoryImageView.hidden = (type_ == KDTaskPageDetailType);
        }
        else
        {
            cell.leftLabel.text = ASLocalizedString(@"KDCreateTaskViewController_share_scope");
            //cell.iconImageView.image = [UIImage imageNamed:@"task_icon_share"];
            cell.backgroundColor = [UIColor kdBackgroundColor2];
            cell.accessoryImageView.hidden = YES;
            label.hidden = NO;

            if (task_.groupName) {
                cell.rightLabel.text = task_.groupName;
            }else {
                if ([task_.visibility isEqualToString:@"network"]) {
                    cell.rightLabel.text = ASLocalizedString(@"KDInboxCell_hall");
                }else {
                    cell.rightLabel.text = ASLocalizedString(@"KDCreateTaskViewController_private");
                }
            }
            
        }
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0 || section == 3)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView_.frame), 22)];
        view.backgroundColor = [UIColor kdSubtitleColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([NSNumber kdDistance1], CGRectGetMinY(view.frame), CGRectGetWidth(view.frame) - [NSNumber kdDistance1], CGRectGetHeight(view.frame))];
        label.text = section == 0 ? ASLocalizedString(@"KDCreateTaskViewController_content"):ASLocalizedString(@"KDCreateTaskViewController_member");
        label.font = FS7;
        label.textColor = FC1;
        label.backgroundColor = view.backgroundColor;
        [view addSubview:label];
        return view;
    }else{
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor kdSubtitleColor];
        return view;
    }
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 1)
    {
        return [NSNumber kdDistance1];
    }
    else if(section == 0 || section == 3)
    {
        return 22;
    }
    return 0;
}

#pragma mark - 外部方法
- (void)updateExecutors:(NSArray *)executors
{
    if (executors_) {
        [executors_ removeAllObjects];
        [executors_ addObjectsFromArray:executors];
        
        [tableView_ reloadData];
    }
}
- (NSString *)content
{
    return textView_.text;
}
- (NSString *)finishDate
{
    return [self.needFinishDate formatWithFormatter:KD_DATE_ISO_8601_SHORT_FORMATTER];
}
- (NSString *)executorsIds{
    
    UserPortraitGroupCell *cell = (UserPortraitGroupCell *)[tableView_ cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    NSArray *users = [cell.groupView getCurrentUsers];
    
    NSUInteger count = (users != nil) ? [users count] : 0;
    if(count < 0x01) return @"";
    
    NSMutableString *IDs = [NSMutableString string];
    NSUInteger idx = 0;
    for(KDUser *item in users){
        [IDs appendString:item.userId];
        if(idx++ != (count - 1)){
            [IDs appendString:@","];
        }
    }
    return IDs;
}
- (BOOL)checkInfo
{
    BOOL succed = NO;
    if ([textView_.internalTextView isFirstResponder]) {
        [textView_.internalTextView resignFirstResponder];
    }
    
    int remainingCount = [TwitterText remainingCharacterCount:[self stringTobeCounted]];
    NSString *message = nil;
    
    if (remainingCount == KD_MAX_WEIBO_TEXT_LENGTH)
        message = ASLocalizedString(@"内容不能为空");
    else if(remainingCount <0)
        message = ASLocalizedString(@"内容太长");
    else if([self executorsIds].length == 0)
        message = ASLocalizedString(@"KDTaskEditorView_Executors");
    else
        succed =YES;
    
    if (!succed) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alertView show];
//        [alertView release];
    }

    return succed;
}

- (void)documentIndicatorView:(KDDocumentIndicatorView *)div didClickedAtAttachment:(KDAttachment *)attachment {
    [[KDDefaultViewControllerContext defaultViewControllerContext] showProgressModalViewController:attachment inStatus:_status sender:self];
}

- (void)didClickMoreInDocumentIndicatorView:(KDDocumentIndicatorView *)div {
    [[KDDefaultViewControllerContext defaultViewControllerContext] showAttachmentViewController:_status sender:self];
}

@end
