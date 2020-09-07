//
//  KDPhotoSignInContentCell.m
//  kdweibo
//
//  Created by lichao_liu on 9/23/15.
//  Copyright © 2015 www.kingdee.com. All rights reserved.
//

#import "KDPhotoSignInContentCell.h"

@implementation KDPhotoSignInContentCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textView.frame = CGRectMake([NSNumber kdDistance1]-5, [NSNumber kdDistance2], CGRectGetWidth(self.frame) -2*[NSNumber kdDistance1], CGRectGetHeight(self.frame) - 2*[NSNumber kdDistance2]);
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.textView = [[HPTextViewInternal alloc] init];
        self.textView.placeholder = ASLocalizedString(@"KDPhotoSignInContentCell_mark");
        self.textView.placeholderColor = FC3;
        self.textView.displayPlaceHolder = YES;
        self.textView.font = FS4;
        self.textView.delegate = self;
        self.textView.layer.borderWidth = 0;
        [self.contentView addSubview:self.textView];
    }
    return self;
}

#pragma mark -textviewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidChange:(HPTextViewInternal *)textView
{
    textView.displayPlaceHolder = textView.text.length == 0;
    [textView setNeedsDisplay];
}


@end
