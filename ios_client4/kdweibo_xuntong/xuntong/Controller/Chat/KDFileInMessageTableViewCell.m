//
//  KDFileInMessageTableViewCell.m
//  kdweibo
//
//  Created by janon on 15/3/23.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDFileInMessageTableViewCell.h"
#import "KDFileInMessageDataModel.h"
#import "XTFileUtils.h"
//#import "KDURLPathManager.h"
#import "ContactUtils.h"

@interface KDFileInMessageTableViewCell ()
@property(nonatomic, strong) UILabel *fileTitle;
@property(nonatomic, strong) UILabel *fileSize;
@property(nonatomic, strong) UILabel *fileTimeStamp;
@property(nonatomic, strong) UILabel *alreadReadCount;
@property(nonatomic, strong) UIButton *fileUploader;
@property(nonatomic, strong) UIImageView *fileImageView;
@property(nonatomic, strong) KDFileInMessageDataModel *cellModel;

@property(nonatomic, strong) UILabel *wordLabel;
@property(nonatomic, strong) UIActivityIndicatorView *myActView;
@property(nonatomic, strong) NSDateFormatter *myFormatter;
@end

@implementation KDFileInMessageTableViewCell
- (NSDateFormatter *)myFormatter {
    if (!_myFormatter) {
        _myFormatter = [[NSDateFormatter alloc] init];
        [_myFormatter setDateStyle:NSDateFormatterMediumStyle];
        [_myFormatter setTimeStyle:NSDateFormatterShortStyle];
        [_myFormatter setDateFormat:@"YYYY/MM/dd  HH:mm"];
    }
    return _myFormatter;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSome];
        
        self.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
        self.separatorLineInset = UIEdgeInsetsMake(0, 61.0, 0, 0);
    }
    return self;
}

- (void)initSome {
    CGFloat cellHeight = 68;
    self.fileImageView = [[UIImageView alloc] initWithFrame:CGRectMake([NSNumber kdDistance1], (cellHeight - 44) * 0.5, 44, 44)];
    self.fileImageView.backgroundColor = [UIColor clearColor];
    [self.fileImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:self.fileImageView];
    
    self.fileTitle = [[UILabel alloc] initWithFrame:CGRectMake(61, 10, ScreenFullWidth-61-20-2*[NSNumber kdDistance1], 16)];
    [self.fileTitle setTextColor:FC1];
    [self.fileTitle setFont:FS2];
    [self.fileTitle setTextAlignment:NSTextAlignmentLeft];
    [self.fileTitle setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.fileTitle];
    
    self.fileTimeStamp = [[UILabel alloc] initWithFrame:CGRectMake(X(self.fileTitle.frame), CGRectGetMaxY(self.fileTitle.frame)+5, 115, 20)];
    [self.fileTimeStamp setTextColor:FC2];
    [self.fileTimeStamp setTextAlignment:NSTextAlignmentLeft];
    [self.fileTimeStamp setFont:FS6];
    [self.fileTimeStamp setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.fileTimeStamp];

    self.fileSize = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.fileTimeStamp.frame)+10, Y(self.fileTimeStamp.frame), 58, Height(self.fileTimeStamp.frame))];
    [self.fileSize setTextColor:FC2];
    [self.fileSize setTextAlignment:NSTextAlignmentLeft];
    [self.fileSize setFont:FS6];
    [self.fileSize setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.fileSize];

     self.loadbuttonImageView = [[UIImageView alloc] init];
    self.loadbuttonImageView.frame =CGRectMake(ScreenFullWidth - 20 - [NSNumber kdDistance1], 0.5 * (cellHeight - 20), 20, 20);
    self.loadbuttonImageView.userInteractionEnabled = YES;
    self.loadbuttonImageView.image = [UIImage imageNamed:@"doc_btn_download_nor.png"];

     UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadButtonClicked:)];
    [self.loadbuttonImageView addGestureRecognizer:tap];
 
    self.fileUploader = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.fileUploader setFrame:CGRectMake(CGRectGetMaxX(self.fileSize.frame), Y(self.fileSize.frame), 55, Height(self.fileSize.frame))];
    [self.fileUploader.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.fileUploader.titleLabel setFont:FS6];
    [self.fileUploader setTitleColor:FC5 forState:UIControlStateNormal];
    self.fileUploader.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
     [self.fileUploader setBackgroundColor:[UIColor clearColor]];
    [self.fileUploader addTarget:self action:@selector(personNameButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.fileUploader];

    self.wordLabel = [[UILabel alloc] initWithFrame:CGRectMake(129, 25, 102, 21)];
    [self.wordLabel setTextColor:[UIColor grayColor]];
    [self.wordLabel setTextAlignment:NSTextAlignmentCenter];
    [self.wordLabel setFont:[UIFont systemFontOfSize:17]];
    [self.wordLabel setBackgroundColor:[UIColor clearColor]];
    [self.wordLabel setText:ASLocalizedString(@"KDFileInMessageTableViewCell_Refresh")];

    self.myActView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(96, 25, 20, 20)];
    [self.myActView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
}

- (void)loadButtonClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:openOrDownloadFileWithModel:)]) {
        [self.delegate cell:self openOrDownloadFileWithModel:self.cellModel];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //title、time、size、uploader居中对齐
    [self.fileTimeStamp sizeToFit];
    CGFloat totleHeight = Height(self.fileTimeStamp.frame) + 8 + Height(self.fileTitle.frame);
    SetY(self.fileTitle.frame, (Height(self.frame) - totleHeight)/2 + 1);
    SetY(self.fileTimeStamp.frame, CGRectGetMaxY(self.fileTitle.frame) + 8);
    self.fileSize.frame = CGRectMake(CGRectGetMaxX(self.fileTimeStamp.frame)+10, Y(self.fileTimeStamp.frame), 58, Height(self.fileTimeStamp.frame));
    [self.fileSize sizeToFit];
    self.fileUploader.frame = CGRectMake(CGRectGetMaxX(self.fileSize.frame) +10, Y(self.fileTimeStamp.frame), 58, Height(self.fileTimeStamp.frame));
    if (isAboveiPhone6) {
        [self.fileUploader sizeToFit];
    }
    SetCenterY(self.fileUploader.center,self.fileSize.center.y);
}


- (void)setCellInformation:(KDFileInMessageDataModel *)model IndexPath:(NSIndexPath *)indexPath {

    [self.wordLabel removeFromSuperview];
    [self.myActView removeFromSuperview];
    [self.loadbuttonImageView removeFromSuperview];

    [self addSubview:self.loadbuttonImageView];

    //文件名 文件打小 上传者 时间戳
    self.fileTitle.text = [NSString stringWithFormat:@"%@", model.fileName];
    self.fileSize.text = [XTFileUtils fileSize:model.length];
    [self.fileUploader setTitle:model.userName forState:UIControlStateNormal];
    self.fileTimeStamp.text = [self.myFormatter stringFromDate:model.time];
    //文件图标
    if ([XTFileUtils isPhotoExt:model.fileExt]) {
        NSString *url = [NSString stringWithFormat:@"%@%@%@%@", [[KDWeiboServicesContext defaultContext] serverBaseURL], @"/microblog/filesvr/", model.fileId, @"?thumbnail"];   //
        [self.fileImageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:[XTFileUtils thumbnailImageWithExt:model.fileExt]]];
    }
    else {
        self.fileImageView.image = [UIImage imageNamed:[XTFileUtils fileTypeWithExt:model.fileExt needBig:NO]];
    }

    //按钮标题
    NSString *path = [[ContactUtils fileFilePath] stringByAppendingFormat:@"/%@.%@", model.fileId, model.fileExt];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        self.loadbuttonImageView.hidden = YES;
         model.fileHasOrNot = YES;
    }
    else {
         model.fileHasOrNot = NO;
    }

    //设置cellModel
    self.cellModel = model;

}

- (void)personNameButtonClicked:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:personNameButtonPressedWithModel:)]) {
        [self.delegate cell:self personNameButtonPressedWithModel:self.cellModel];
    }
}
@end
