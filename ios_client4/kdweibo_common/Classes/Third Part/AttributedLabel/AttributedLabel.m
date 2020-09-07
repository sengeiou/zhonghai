//
//  AttributedLabel.m
//  AttributedStringTest
//
//  Created by sun huayu on 13-2-19.
//  Copyright (c) 2013年 sun huayu. All rights reserved.
//

#import "AttributedLabel.h"

@interface AttributedLabel(){
    
}
@property (nonatomic,retain)NSMutableAttributedString          *attString;
@property (nonatomic,retain)NSString *tempString;
@end

@implementation AttributedLabel
@synthesize attString = _attString;

- (void)dealloc{
//    [_tempString release];
//    [_attString release];
    //[super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    // Drawing code
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();//注，像许多低级别的API，核心文本使用的Y翻转坐标系 更杯具的是，内容是也渲染的翻转向下！
    //手动翻转,注，每次使用可将下面三句话复制粘贴过去。必用
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGMutablePathRef path = CGPathCreateMutable();//1,外边框。mac支持矩形和圆，ios仅支持矩形。本例中使用self.bounds作为path的reference
    CGPathAddRect(path, NULL, self.bounds);
    
    //MarkupParser *p = [[[MarkupParser alloc]init]autorelease];
    
    //NSAttributedString *attString = [p attrStringFromMarkup:@"Hello <font color=\"red\">core text <font color=\"blue\">world!"];
    //[[[NSAttributedString alloc]initWithString:@"Hello core text World!"] autorelease];//2,在core text中，不再使用NSString应使用NSAttributedString。它是NSString的一个衍生类，允许你应用文本格式属性
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attString);//3CTFramesetter是最重要的类时使用的绘图核心文本。管理您的字体引用和绘制文本框。就目前而言，你需要知道什么是CTFramesetterCreateWithAttributedString为您将创建一个CTFramesetter的，保留它，并使用附带的属性字符串初始化。在本节中，你有framesetter后你创建一个框架，你给CTFramesetterCreateFrame，呈现了一系列的字符串（我们选择这里的整个字符串）和矩形绘制文本时会出现。
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [_attString length]), path, NULL);
    CTFrameDraw(frame, context);//4绘制
    
    CFRelease(frame);//5
    CFRelease(path);
    CFRelease(framesetter);
    
}

- (void)setText:(NSString *)text{
    //    [super setText:text];
    if (text == nil) {
        self.attString = nil;
    }else{
        self.attString = [[NSMutableAttributedString alloc] initWithString:text];// autorelease];
    }
    self.tempString = text;
}

// 设置某段字的颜色
- (void)setColor:(UIColor *)color fromIndex:(NSInteger)location length:(NSInteger)length{
    if (location < 0||location>self.tempString.length-1||length+location>self.tempString.length) {
        return;
    }
    [_attString addAttribute:(NSString *)kCTForegroundColorAttributeName
                       value:(id)color.CGColor
                       range:NSMakeRange(location, length)];
}

// 设置某段字的字体
- (void)setFont:(UIFont *)font fromIndex:(NSInteger)location length:(NSInteger)length{
    if (location < 0||location>self.tempString.length-1||length+location>self.tempString.length) {
        return;
    }
    
//gordon_wu 修改内存泄露 2014.08.04
    
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName,
                                                          font.pointSize,
                                                          NULL);
    [_attString addAttribute:(NSString *)kCTFontAttributeName
                       value:(__bridge id)fontRef
                       range:NSMakeRange(location, length)];
    CFRelease(fontRef);
    
//    [_attString addAttribute:(NSString *)kCTFontAttributeName
//                       value:(id)CTFontCreateWithName((CFStringRef)font.fontName,
//                                                      font.pointSize,
//                                                      NULL)
//                       range:NSMakeRange(location, length)];
}

// 设置某段字的风格
- (void)setStyle:(CTUnderlineStyle)style fromIndex:(NSInteger)location length:(NSInteger)length{
    if (location < 0||location>self.tempString.length-1||length+location>self.tempString.length) {
        return;
    }
    [_attString addAttribute:(NSString *)kCTUnderlineStyleAttributeName
                       value:(id)[NSNumber numberWithInt:style]
                       range:NSMakeRange(location, length)];
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
