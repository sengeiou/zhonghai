//
//  KDDocumentIndicatorView.m
//  kdweibo_common
//
//  Created by shen kuikui on 13-7-15.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDDocumentIndicatorView.h"
#import "KDAttachment.h"
#import "KDCommon.h"
#import "UIColor+KDV6.h"
#define ROW_HEIGH   41
@interface KDDocumentIndicatorViewCell : UIView
{
    UIImageView *iconImageView;
    UILabel *fileNameLabel;
}

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, assign) NSUInteger index;
@property(nonatomic, retain)UIColor * textColor;  // 2013.12.3 By Tan yingqi 新增cell 的textColor 属性

@end

@implementation KDDocumentIndicatorViewCell

@synthesize fileName = _fileName, index = _index,textColor = textColor_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = [UIColor kdBackgroundColor1];//RGBCOLOR(238, 238, 238);
    }
    
    return self;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(iconImageView);
    //KD_RELEASE_SAFELY(_fileName);
    //KD_RELEASE_SAFELY(fileNameLabel);
    //KD_RELEASE_SAFELY(textColor_);
    
    //[super dealloc];
}

- (void)setFileName:(NSString *)fileName {
    if(_fileName != fileName) {
//        [_fileName release];
        _fileName = fileName ;//retain];
        
        [self setupViews];
    }
}

- (NSString *)imageNameForFile:(NSString *)fileName {
    NSString *imageName = @"doc";
    
    NSArray *fileNameComponents = [fileName componentsSeparatedByString:@"."];
    if(fileNameComponents.count > 1) {
        NSString *fileSuffix = [fileNameComponents lastObject];
        
        if(fileSuffix && fileSuffix.length >= 3) {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"excel.png", @"xls.xlsx",
                                 @"pdf.png", @"pdf",
                                 @"ppt.png", @"ppt.pptx",
                                 @"txt.png", @"txt",
                                 @"word.png", @"doc.docx",
                                 @"zip.png", @"zip.rar",
                                 nil];
            
            for(NSString * key in dic.allKeys) {
                NSArray *suffixComponents = [key componentsSeparatedByString:@"."];
                BOOL isFound = NO;
                for(NSString *suffix in suffixComponents) {
                    if(NSOrderedSame == [fileSuffix compare:suffix options:NSCaseInsensitiveSearch]) {
                        isFound = YES;
                        break;
                    }
                }
                
                if(isFound) {
                    imageName = [dic objectForKey:key];
                    break;
                }
            }
        }
    }
    
    return imageName;
}

- (void)setupViews {
    if(!iconImageView) {
        iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:iconImageView];
    }
    
    iconImageView.image = [UIImage imageNamed:[self imageNameForFile:_fileName]];
    [iconImageView sizeToFit];
    
    if(!fileNameLabel) {
        fileNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        fileNameLabel.backgroundColor = [UIColor clearColor];
         // 2013.12.3 By Tan yingqi 新增cell 的textColor 属性
        if (textColor_) {
            fileNameLabel.textColor = textColor_;
        }else {
            fileNameLabel.textColor = [UIColor blackColor];
        }
        fileNameLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        fileNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        
        [self addSubview:fileNameLabel];
    }
    
    fileNameLabel.text = _fileName;
    [fileNameLabel sizeToFit];
    
    
    iconImageView.frame = CGRectMake(11.0f, 6, iconImageView.image.size.width, iconImageView.image.size.height);
    fileNameLabel.frame = CGRectMake(CGRectGetMaxX(iconImageView.frame) + 15.0f, (self.bounds.size.height - fileNameLabel.bounds.size.height) * 0.5f, self.bounds.size.width - CGRectGetMaxX(iconImageView.frame) - 15.0f - 10.0f, fileNameLabel.bounds.size.height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
   // self.backgroundColor = RGBCOLOR(241, 241, 241);
    
    iconImageView.frame = CGRectMake(11.0f, 6, iconImageView.image.size.width, iconImageView.image.size.height);
    fileNameLabel.frame = CGRectMake(CGRectGetMaxX(iconImageView.frame) + 15.0f, (self.bounds.size.height - fileNameLabel.bounds.size.height) * 0.5f, self.bounds.size.width - CGRectGetMaxX(iconImageView.frame) - 15.0f - 10.0f, fileNameLabel.bounds.size.height);
}

@end

@interface KDDocumentIndicatorView()
{
    
}

@property(nonatomic, retain) KDDocumentIndicatorViewCell *cell1;
@property(nonatomic, retain) KDDocumentIndicatorViewCell *cell2;
@property(nonatomic, retain) KDDocumentIndicatorViewCell *cell3;
@property(nonatomic, retain) UIView *moreView;
@property(nonatomic, retain) UILabel *moreMsgLabel;
//@property(nonatomic, retain) UIImageView *moreBgImageView;
@property(nonatomic, retain) UIImageView *moreIconImageView;
@property(nonatomic, retain) UIImageView *moreAccessoryImageView;

@end

@implementation KDDocumentIndicatorView

@synthesize documents = _documents;
@synthesize delegate = _delegate;
@synthesize cell1 = _cell1, cell2 = _cell2, cell3 = _cell3, moreView = _moreView, moreMsgLabel = _moreMsgLabel,  moreIconImageView = _moreIconImageView;
@synthesize moreAccessoryImageView = moreAccessoryImageView_;
@synthesize textColor = textColor_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addTap];
    }
    return self;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(_documents);
    //KD_RELEASE_SAFELY(_cell1);
    //KD_RELEASE_SAFELY(_cell2);
    //KD_RELEASE_SAFELY(_cell3);
    //KD_RELEASE_SAFELY(_moreView);
    //KD_RELEASE_SAFELY(_moreMsgLabel);
    //KD_RELEASE_SAFELY(_moreIconImageView);
    //KD_RELEASE_SAFELY(textColor_);
    //KD_RELEASE_SAFELY(moreAccessoryImageView_);
    
    //[super dealloc];
}

- (void)addTap {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
//    [tap release];
}

- (void)tapAction:(UITapGestureRecognizer *)gesture {
    CGPoint p = [gesture locationInView:self];
    NSUInteger index = 0;
    
    if(p.y > 0 && p.y < 40.0f) {
        index = 0;
    }else if(p.y > 40.0f && p.y < 80.0f) {
        index = 1;
    }else if(p.y > 80.0f && p.y < 120.0f) {
        index = 2;
    }else {
        index = 3;
    }
    
    if(_delegate) {
        if(index == 3 && _moreView && !_moreView.hidden) {
            if([_delegate respondsToSelector:@selector(didClickMoreInDocumentIndicatorView:)]) {
                [_delegate didClickMoreInDocumentIndicatorView:self];
            }
        }else {
            if([_delegate respondsToSelector:@selector(documentIndicatorView:didClickedAtAttachment:)]) {
                [_delegate documentIndicatorView:self didClickedAtAttachment:[_documents objectAtIndex:index]];
            }
        }
    }
}

- (void)setDocuments:(NSArray *)documents {
    if(_documents != documents) {
//        [_documents release];
        _documents = documents;// retain];
        
        [self setupView];
    }
}

- (KDDocumentIndicatorViewCell *)cellForAttachmentAtIndex:(NSUInteger)index {
    KDDocumentIndicatorViewCell *cell = [[KDDocumentIndicatorViewCell alloc] initWithFrame:CGRectMake(0.0f, index * ROW_HEIGH, self.frame.size.width, ROW_HEIGH - 1)];// autorelease];
    cell.textColor = textColor_;   // 2013.12.3 By Tan yingqi 新增cell 的textColor 属性
    [self addSubview:cell];
    return cell;
}

- (void)setupView {
    NSUInteger count = _documents.count;
    
    if(count >= 1) {
        if(!_cell1) {
            self.cell1 = [self cellForAttachmentAtIndex:0];
        }
        _cell1.hidden = NO;
        _cell1.fileName = [[_documents objectAtIndex:0] filename];
    }else if(_cell1) {
        _cell1.hidden = YES;
    }
    
    if(count >= 2) {
        if(!_cell2) {
            self.cell2 = [self cellForAttachmentAtIndex:1];
        }
        _cell2.hidden = NO;
        _cell2.fileName = [[_documents objectAtIndex:1] filename];
    }else if(_cell2) {
        _cell2.hidden = YES;
    }
    
    if(count >= 3) {
        if(!_cell3) {
            self.cell3 = [self cellForAttachmentAtIndex:2];
        }
        _cell3.hidden = NO;
        _cell3.fileName = [[_documents objectAtIndex:2] filename];
    }else if(count < 3) {
        _cell3.hidden = YES;
    }
    
    if(count > 3){
        if(!_moreView) {
            _moreView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 80.0f, self.frame.size.width, ROW_HEIGH - 1)];
            _moreView.backgroundColor = [UIColor kdBackgroundColor1];//UIColorFromRGBA(0x000000, 0.77f);
            [self addSubview:_moreView];
            
//            UIImage *bgImage = [UIImage imageNamed:@"document_more.png"];
//            bgImage = [bgImage stretchableImageWithLeftCapWidth:bgImage.size.width * 0.5f topCapHeight:bgImage.size.height * 0.5f];
//            _moreBgImageView = [[UIImageView alloc] initWithImage:bgImage];
//            [_moreView addSubview:_moreBgImageView];
            
            _moreIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_doc_clip"]];
            [_moreView addSubview:_moreIconImageView];
            
            _moreMsgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _moreMsgLabel.backgroundColor = [UIColor clearColor];
            _moreMsgLabel.textColor = [UIColor whiteColor];
            _moreMsgLabel.font = [UIFont systemFontOfSize:14.0f];
            [_moreView addSubview:_moreMsgLabel];
            
            moreAccessoryImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_doc_arrow_icon"]];
            [_moreView addSubview:moreAccessoryImageView_];
        }

        _moreMsgLabel.text = [NSString stringWithFormat:ASLocalizedString(@"KDDocumentIndicatorView_doc"), _documents.count - 3];
    }
    
    _moreView.hidden = count <= 3;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;
    
    if(_cell1 && !_cell1.hidden) {
        _cell1.frame = CGRectMake(0.0f, 0.0f, width, ROW_HEIGH - 1);
    }
    
    if(_cell2 && !_cell2.hidden) {
        _cell2.frame = CGRectMake(0.0f, ROW_HEIGH, width, ROW_HEIGH - 1);
    }
    
    if(_cell3 && !_cell3.hidden) {
        _cell3.frame = CGRectMake(0.0f, ROW_HEIGH*2, width, ROW_HEIGH - 1);
    }
    
    if(_moreView && !_moreView.hidden) {
        _moreView.frame = CGRectMake(0.0f, ROW_HEIGH*3, width, ROW_HEIGH - 1);

        _moreIconImageView.frame = CGRectMake(15, (_moreView.bounds.size.height - _moreIconImageView.image.size.height) * 0.5f, _moreIconImageView.image.size.width, _moreIconImageView.image.size.height);
        _moreMsgLabel.frame = CGRectMake(CGRectGetMaxX(_moreIconImageView.frame) + 10.0f, 9.0f, 150.0f, 21.0f);
        [moreAccessoryImageView_ sizeToFit];
        CGRect frame = moreAccessoryImageView_.frame;
        frame.origin.x = CGRectGetWidth(_moreView.frame) - CGRectGetWidth(frame) - 10;
        frame.origin.y = (CGRectGetHeight(_moreView.bounds) - CGRectGetHeight(frame)) *0.5;
        moreAccessoryImageView_.frame = frame;
        }
}
 
+ (CGFloat)heightForDocumentsCount:(NSUInteger)count {
    NSUInteger realCount = MIN(4,count);
    
    return realCount * ROW_HEIGH;
}

@end
