//
//  KDProfileTagsViewController.m
//  kdweibo
//
//  Created by Gil on 15/2/3.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDProfileTagsViewController.h"
#import "UIButton+Factory.h"

static NSString *const kCustomTag = @"添加自定义标签";

@interface KDProfileTagsViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSArray *customTags;
@property (nonatomic, strong) NSString *currentTag;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextField *textField;
@end

@implementation KDProfileTagsViewController

- (id)initWithTags:(NSArray *)tags customTags:(NSArray *)customTags currentTag:(NSString *)currentTag {
	self = [super init];
	if (self) {
		self.tags = tags;

		if ([customTags count] > 0) {
			__block NSMutableArray *tempTags = [NSMutableArray array];
			__weak KDProfileTagsViewController *selfInBlock = self;
			[customTags enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
			    if (![selfInBlock.tags containsObject:obj]) {
			        [tempTags addObject:obj];
				}
			}];
			self.customTags = tempTags;
		}

		if (currentTag.length > 0) {
			self.currentTag = currentTag;
			if (![self.tags containsObject:currentTag] && ![self.customTags containsObject:currentTag]) {
				self.customTags = [self.customTags arrayByAddingObject:currentTag];
			}
		}
		else {
			self.currentTag = [self.tags firstObject];
		}
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.title = ASLocalizedString(@"KDProfileTagsViewController_Tag");
	self.view.backgroundColor = MESSAGE_BG_COLOR;

	self.navigationItem.leftBarButtonItem = [UIButton textBarButtonItemWithTitle:ASLocalizedString(@"Global_Cancel")addTarget:self action:@selector(cancelButtonClick:)];

	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 70.f )   style:UITableViewStyleGrouped];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.clipsToBounds = NO;
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.showsVerticalScrollIndicator = NO;
	[self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - keyboard

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    /* Listen for keyboard */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    if (self.textField) {
        [self.textField resignFirstResponder];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, CGRectGetHeight(keyboardEndFrame)+36, 0)];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

#pragma mark - btn click

- (void)cancelButtonClick:(UIButton *)btn {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)done {
	NSString *tag = self.currentTag;
	if (self.textField && self.textField.text.length > 0) {
        tag = self.textField.text;
	}

	if (self.delegate) {
		[self.delegate didSelect:self tag:tag];
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView Datasource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return [self.tags count];
	}
	return [self.customTags count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 10.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *reuseIdentifier = @"reuseIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	}

	if (indexPath.section == 0) {
		cell.textLabel.text = self.tags[indexPath.row];
	}
	else {
		if (indexPath.row == 0) {
			cell.textLabel.text = ASLocalizedString(@"KDProfileTagsViewController_CustomTag");
		}
		else {
			cell.textLabel.text = self.customTags[indexPath.row - 1];
		}
	}

	if ([cell.textLabel.text isEqualToString:self.currentTag]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_btn_sel"]];
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.accessoryView = nil;
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	NSString *text = cell.textLabel.text;
	if ([text isEqualToString:ASLocalizedString(@"KDProfileTagsViewController_CustomTag")]) {
		if (!cell.textLabel.hidden) {
			UITextField *textField = [[UITextField alloc] initWithFrame:cell.textLabel.frame];
			textField.backgroundColor = [UIColor clearColor];
			textField.font = cell.textLabel.font;
			textField.textColor = cell.textLabel.textColor;
			textField.delegate = self;
			textField.returnKeyType = UIReturnKeyDone;
			[textField becomeFirstResponder];
			self.textField = textField;
			[cell.contentView addSubview:textField];

			cell.textLabel.hidden = YES;
		}
	}
	else {
		self.currentTag = cell.textLabel.text;
		[tableView reloadData];

		[self done];
	}
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell *)textField.superview.superview;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self done];

	return YES;
}

@end
