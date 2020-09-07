//
//  KWIVoteOptionV.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/28/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIVoteOptionV.h"

#import "KDVoteOption.h"
#import "KDVote.h"

@interface KWIVoteOptionV ()

@property (retain, nonatomic) IBOutlet DTAttributedTextContentView *nameV;
@property (retain, nonatomic) IBOutlet UILabel *percentV;
@property (retain, nonatomic) IBOutlet UIButton *voteBtn;
@property (retain, nonatomic) IBOutlet UIButton *muVoteBtn;

@end

@implementation KWIVoteOptionV
{
    BOOL _isSelected;
}

@synthesize nameV = _nameV;
@synthesize percentV = _percentV;
@synthesize voteBtn = _voteBtn;
@synthesize muVoteBtn = _muVoteBtn;

@synthesize data = _data;

+ (KWIVoteOptionV *)view {
    return [self _loadFromNib];
}

+ (KWIVoteOptionV *)_loadFromNib
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:self.description owner:nil options:nil];
    return (KWIVoteOptionV *)[nib objectAtIndex:0];
}

- (void)setData:(KDVoteOption *)data
{
    if (_data != data) {
        [_data release];
        _data = [data retain];
    }
    
    if (_data.vote == nil) {
         return;
    }
    if (_data.vote.isCurUserParticipant || _data.vote.isEnded) {
        self.percentV.text = [NSString stringWithFormat:@"%d (%.f%%)", _data.count, _data.percent * 100];
    }
    
    if (_data.vote.isOpen) {
        if ([_data.vote isMultipleSelections]) {
            self.muVoteBtn.hidden = NO;
        } else {
            self.voteBtn.hidden = NO;
        }
    } else {
        self.muVoteBtn.hidden = YES;
        self.voteBtn.hidden = YES;
    }
    
    NSString *nameStr = nil;

    for (NSString *seleted in _data.vote.selectedOptionIDs) {
            if ([seleted isEqualToString:_data.optionId]) {
                _isSelected = YES;
                nameStr = [NSString stringWithFormat:@"<p style=\"color:#333; font-size:14px; line-height:1.3;\">%@  <span style=\"color:#999; font-size:12px;\">(你的选择)</span></p>", _data.name];
                break;
            }
        }
   

    if (!nameStr) {
        nameStr = [NSString stringWithFormat:@"<span style=\"color:#333; font-size:14px; line-height:1.3;\">%@</span>", _data.name];
    }
    self.nameV.attributedString = [[[NSAttributedString alloc] initWithHTMLData:[nameStr dataUsingEncoding:NSUTF8StringEncoding] documentAttributes:nil] autorelease];
    
//    CGRect frame = self.frame;
//    frame.size.height = CGRectGetMaxY(self.nameV.frame) + 35;
//    self.frame = frame;
    [self setNeedsDisplay];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = _percentV.frame;
    frame.origin.y = CGRectGetMaxY(self.nameV.frame) +6;
    _percentV.frame = frame;
    
}
// Onlyl override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    NSUInteger left = 0;
    NSUInteger top = CGRectGetMaxY(self.nameV.frame) + 6;;
    NSUInteger fullRight = self.frame.size.width - 95;
    NSUInteger curRight = ((self.data.vote.isCurUserParticipant || self.data.vote.isEnded)?fullRight * self.data.percent:0);
    NSUInteger bottom = top + 24;        
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(context, left, top);
    CGContextAddLineToPoint(context, fullRight, top);
    CGContextAddLineToPoint(context, fullRight, bottom);
    CGContextAddLineToPoint(context, left, bottom);
    CGContextAddLineToPoint(context, left, top);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:229.0/255 green:229.0/255 blue:229.0/255 alpha:1].CGColor);
    CGContextFillPath(context);
    
    CGContextMoveToPoint(context, left, top);
    CGContextAddLineToPoint(context, curRight, top);
    CGContextAddLineToPoint(context, curRight, bottom);
    CGContextAddLineToPoint(context, left, bottom);
    CGContextAddLineToPoint(context, left, top);    
    if (_isSelected) {
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:169.0/255 green:69.0/255 blue:64.0/255 alpha:1].CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:153.0/255 green:153.0/255 blue:153.0/255 alpha:1].CGColor);
    }
    CGContextFillPath(context);
}

- (void)dealloc {
    [_data release];
    [_nameV release];
    [_percentV release];
    [_voteBtn release];
    [_muVoteBtn release];
    [super dealloc];
}

#pragma mark -
/*+ (NSUInteger)height
{
    static NSUInteger height;
    if (0 == height) {
        KWIVoteOptionV *view = [self _loadFromNib];
        height = view.frame.size.height;
    }
    
    return height;
}*/

- (IBAction)_voteBtnTapped:(id)sender 
{ 
    ((UIButton *)sender).selected = _isSelected = !_isSelected;
    NSString *note = _isSelected?@"KWIVoteOptionV.selected":@"KWIVoteOptionV.disselected";
    
    [[NSNotificationCenter defaultCenter] postNotificationName:note 
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:self.data forKey:@"option"]];
}

/*- (IBAction)_onMuVoteBtnTapped:(id)sender 
{
    NSString *note = _isSelected?
    @"KWIVoteOptionV.disselected":
    @"KWIVoteOptionV.selected";
    
    [[NSNotificationCenter defaultCenter] postNotificationName:note 
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:self.data forKey:@"option"]];
    self.muVoteBtn.selected = _isSelected = !_isSelected;
}*/

- (void)on
{
    //[self.voteBtn setImage:[UIImage imageNamed:@"voteBtnOn.png"] forState:UIControlStateNormal];
    //self.voteBtn.selected = YES;
    //_isSelected = YES;
    //[self setNeedsDisplay];
}

- (void)off
{
    //[self.voteBtn setImage:[UIImage imageNamed:@"voteBtn.png"] forState:UIControlStateNormal];
    //self.voteBtn.selected = NO;
    self.voteBtn.selected = _isSelected = NO;
    //[self setNeedsDisplay];
}

- (void)lock
{
    self.voteBtn.enabled = NO;
}

- (void)unlock
{
    self.voteBtn.enabled = YES;
}

@end
