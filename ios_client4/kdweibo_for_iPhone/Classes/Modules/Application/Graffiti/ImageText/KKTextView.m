//
//  KKTextView.m
//  kdweibo
//
//  Created by kingdee on 2017/8/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "KKTextView.h"
#import "UIView+Frame.h"
#import "KDImageEditorViewController.h"

@implementation KKTextView{
    UIButton *_deleteButton;
    UIButton *_scaleBtn;
    
    __weak KDImageEditorViewController *_editor;
    
    CGPoint _initialPoint;
    
    CGFloat _scale;    //当前缩放比例
    CGFloat _arg;       //当前旋转比例
    
    CGFloat _initialScale;  //修改前的缩放比例
    CGFloat _initialArg;    //修改前旋转比例
}

+ (void)setActiveTextView:(KKTextView*)view
{
    static KKTextView *activeView = nil;
    if(view != activeView){
        [activeView setAvtive:NO];
        activeView = view;
        [activeView setAvtive:YES];
        
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
        _label.layer.masksToBounds = YES;
        _label.layer.borderColor = [[UIColor whiteColor] CGColor];
        _label.layer.borderWidth = 1;
        _label.layer.cornerRadius = 3;
        _label.font = [UIFont systemFontOfSize:30];
        _label.lineBreakMode = NSLineBreakByCharWrapping;
        [_label setTextColor:[UIColor redColor]];
        _label.textInsets = UIEdgeInsetsMake(0.f, 10, 0.f, 10);
        _label.textAlignment = NSTextAlignmentCenter;
        _label.text = @"";
        [self addSubview:_label];
        [self setLableFrameWithText:_label.text];
        self.frame = CGRectMake(0, 0, _label.frame.size.width + 32, _label.frame.size.height + 32);
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:[UIImage imageNamed:@"btn_delete"] forState:UIControlStateNormal];
        _deleteButton.frame = CGRectMake(0, 0, 32, 32);
        _deleteButton.center = _label.frame.origin;
        [_deleteButton addTarget:self action:@selector(pushedDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
        
        _scaleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_scaleBtn setImage:[UIImage imageNamed:@"icon_drag"] forState:UIControlStateNormal];
        _scaleBtn.frame = CGRectMake(0, 0, 32, 32);
        _scaleBtn.center = CGPointMake(_label.frame.origin.x +_label.frame.size.width, _label.frame.origin.y + _label.frame.size.height);
        _scaleBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_scaleBtn];
        
        _scale = 1;
        _arg = 0;
        
        [self initGestures];
    }
    return self;
    
}

//计算lable的frame
- (void)setLableFrameWithText:(NSString *)text{
    CGSize constraint = CGSizeMake(_editor.imageView.frame.size.width - 45,0); //这里是指lable的宽度，下同
    NSDictionary *attributes = [[NSDictionary alloc] initWithObjects:@[[UIFont systemFontOfSize:30]] forKeys:@[NSFontAttributeName]];
    
    //计算lable的frame 根据文字计算lable的高度
    CGRect size = [text boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    _label.frame = CGRectMake(16, 16, _editor.imageView.frame.size.width - 45, size.size.height);

}

- (void)initGestures
{
    _label.userInteractionEnabled = YES;
    [_label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)]];
    [_label addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)]];
    // 缩放、旋转
    [_scaleBtn addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scaleBtnDidPan:)]];
}

- (void)setAvtive:(BOOL)active
{
    _deleteButton.hidden = !active;
    _scaleBtn.hidden = !active;
    if (active) {
        _label.layer.borderColor = [[UIColor whiteColor] CGColor];
    }else{
        _label.layer.borderColor = [[UIColor clearColor] CGColor];
    }
}

- (void)setLableText:(NSString *)text{
    
    if ([text isEqualToString:@""]) {
        [self removeFromSuperview];
        return;
    }
    _label.text = text;
    [self setLableFrameWithText:text];
    self.frame = CGRectMake(0, 0, _label.frame.size.width + 32, _label.frame.size.height + 32);
}

- (void)setLableTextColor:(UIColor *)color {
    _label.textColor = color;
}

- (NSString *)getLableText{
    return _label.text;
}

#pragma mark- gesture events

- (void)pushedDeleteBtn:(id)sender
{
    KKTextView *nextTarget = nil;
    
    const NSInteger index = [self.superview.subviews indexOfObject:self];
    
    for(NSInteger i=index+1; i<self.superview.subviews.count; ++i){
        UIView *view = [self.superview.subviews objectAtIndex:i];
        if([view isKindOfClass:[KKTextView class]]){
            nextTarget = (KKTextView*)view;
            break;
        }
    }
    
    if(nextTarget==nil){
        for(NSInteger i=index-1; i>=0; --i){
            UIView *view = [self.superview.subviews objectAtIndex:i];
            if([view isKindOfClass:[KKTextView class]]){
                nextTarget = (KKTextView*)view;
                break;
            }
        }
    }
    
    [[self class] setActiveTextView:nextTarget];
    [self removeFromSuperview];
}

- (void)viewDidTap:(UITapGestureRecognizer*)sender
{
    if(!_deleteButton.hidden){
        NSNotification *n = [NSNotification notificationWithName:kTextViewActiveViewDidTapNotification object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:n waitUntilDone:NO];
    }
    [[self class] setActiveTextView:self];
}

- (void)viewDidPan:(UIPanGestureRecognizer*)sender
{
    [[self class] setActiveTextView:self];
    
    CGPoint p = [sender translationInView:self.superview];
    
    if(sender.state == UIGestureRecognizerStateBegan){
        _initialPoint = self.center;
    }
    self.center = CGPointMake(_initialPoint.x + p.x, _initialPoint.y + p.y);
}

- (void)scaleBtnDidPan:(UIPanGestureRecognizer*)sender
{
    CGPoint p = [sender translationInView:self.superview];
    
    static CGFloat tmpR = 1; //临时缩放值
    static CGFloat tmpA = 0; //临时旋转值
    if(sender.state == UIGestureRecognizerStateBegan){
        //文本view中的缩放按钮相对与文本view父视图中的位置
        _initialPoint = [self.superview convertPoint:_scaleBtn.center fromView:_scaleBtn.superview];
        
        CGPoint p = CGPointMake(_initialPoint.x - self.center.x, _initialPoint.y - self.center.y);
        //缩放按钮中点与文本view中点的直线距离
        tmpR = sqrt(p.x*p.x + p.y*p.y); //开根号
        //缩放按钮中点与文本view中点连线的斜率角度
        tmpA = atan2(p.y, p.x);//反正切函数
        
        _initialArg = _arg;
        _initialScale = _scale;
    }
    
    p = CGPointMake(_initialPoint.x + p.x - self.center.x, _initialPoint.y + p.y - self.center.y);
    CGFloat R = sqrt(p.x*p.x + p.y*p.y); //拖动后的距离
    CGFloat arg = atan2(p.y, p.x);    // 拖动后的旋转角度
    //旋转角度
    _arg   = _initialArg + arg - tmpA; //原始角度+拖动后的角度 - 拖动前的角度
    //放大缩小的值
    [self setScale:MAX(_initialScale * R / tmpR, 0.2)];
}

- (void)setScale:(CGFloat)scale {
    _scale = scale;
    self.transform = CGAffineTransformIdentity;
    _label.transform = CGAffineTransformMakeScale(_scale, _scale); //缩放
    CGRect rct = self.frame;
    rct.origin.x += (rct.size.width - (_label.width + 32)) / 2;
    rct.origin.y += (rct.size.height - (_label.height + 32)) / 2;
    rct.size.width  = _label.width + 32;
    rct.size.height = _label.height + 32;
    self.frame = rct;
    _label.center = CGPointMake(rct.size.width/2, rct.size.height/2);
    self.transform = CGAffineTransformMakeRotation(_arg); //旋转
    _label.layer.borderWidth = 1/_scale;
    _label.layer.cornerRadius = 3/_scale;
}

@end
