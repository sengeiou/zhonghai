//
//  KKTextView.m
//  kdweibo
//
//  Created by kingdee on 2017/8/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "KKTextView.h"
#import "KDImageEditorViewController.h"

@interface KKTextView()<UIGestureRecognizerDelegate>


@end

@implementation KKTextView{
    UIButton *_deleteButton;
    
    __weak KDImageEditorViewController *_editor;
    
    CGPoint _initialPoint;
}

+ (void)setActiveTextView:(KKTextView*)view
{
    static KKTextView *activeView = nil;
    if(view != activeView){
        activeView = view;
        [activeView.superview bringSubviewToFront:activeView];
    }
}

- (id)initWithEditor:(KDImageEditorViewController *)editor {
    
    self = [super initWithFrame:CGRectZero];
    if(self){
        _editor = editor;
        _label = [[KKTextLable alloc] init];
        _label.numberOfLines = 0;
        _label.backgroundColor = [UIColor clearColor];
        _label.font = [UIFont systemFontOfSize:30];
        _label.lineBreakMode = NSLineBreakByCharWrapping;
        [_label setTextColor:[UIColor redColor]];
        _label.textInsets = UIEdgeInsetsMake(0.f, 10, 0.f, 10);
        _label.textAlignment = NSTextAlignmentCenter;
        _label.text = @"";
        [self addSubview:_label];
        [self setLableFrameWithText:_label.text];
        self.frame = CGRectMake(0, 0, _label.frame.size.width + 32, _label.frame.size.height + 300*2);
        
        [self initGestures];
    }
    return self;
    
}

//计算lable的frame
- (void)setLableFrameWithText:(NSString *)text{
    CGSize constraint = CGSizeMake(_editor.imageView.frame.size.width - 45 - 20,0); //这里是指lable的宽度，下同；减20是为了迎合内边距
    NSDictionary *attributes = [[NSDictionary alloc] initWithObjects:@[[UIFont systemFontOfSize:30]] forKeys:@[NSFontAttributeName]];
    
    //计算lable的frame 根据文字计算lable的高度
    CGRect size = [text boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    _label.frame = CGRectMake(16, 300, _editor.imageView.frame.size.width - 45, size.size.height);

}

- (void)initGestures
{
    _label.userInteractionEnabled = YES;
    [_label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)]];
    [_label addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)]];
    
    UIPinchGestureRecognizer *pinchGR = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPinch:)];
    pinchGR.delegate = self;
    [self addGestureRecognizer:pinchGR];
    UIRotationGestureRecognizer *rotationGR = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidRotation:)];
    rotationGR.delegate = self;
    [_label addGestureRecognizer:rotationGR];
}

- (void)setLableText:(NSString *)text{
    
    if ([text isEqualToString:@""]) {
        [self removeFromSuperview];
        return;
    }
    _label.text = text;
    [self setLableFrameWithText:text];
    self.frame = CGRectMake(0, 0, _label.frame.size.width + 32, _label.frame.size.height + 300*2);
}

- (void)setLableTextColor:(UIColor *)color {
    _label.textColor = color;
}

- (NSString *)getLableText{
    return _label.text;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

#pragma mark- gesture events

- (void)viewDidTap:(UITapGestureRecognizer*)sender {
    if (self.tapTextBlock) {
        self.tapTextBlock();
    }
}

- (void)viewDidPan:(UIPanGestureRecognizer*)sender
{
    [[self class] setActiveTextView:self];
    
    CGPoint p = [sender translationInView:self.superview];
    
    if(sender.state == UIGestureRecognizerStateBegan){
        _initialPoint = self.center;
    }
    self.center = CGPointMake(_initialPoint.x + p.x, _initialPoint.y + p.y);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(handelPanGestureView:withGR:)]) {
        [self.delegate handelPanGestureView:self withGR:sender];
    }
}

- (void)viewDidPinch:(UIPinchGestureRecognizer *)sender {
    self.transform = CGAffineTransformScale(self.transform, sender.scale, sender.scale);
    sender.scale = 1;
}

- (void)viewDidRotation:(UIRotationGestureRecognizer *)sender {
    self.transform = CGAffineTransformRotate(self.transform, sender.rotation);
    sender.rotation = 0;
}

@end
