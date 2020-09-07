//
//  KDPhotoSignInPhtoCell.m
//  kdweibo
//
//  Created by lichao_liu on 9/22/15.
//  Copyright © 2015 www.kingdee.com. All rights reserved.
//

#import "KDPhotoSignInPhtoCell.h"
#define kImageSize CGSizeMake(55,55)
#define kImageInset 12
#define kImageViewTagPre (int)100
#define kAddButtonTag (int)10003

@implementation KDPhotoSignInPhtoCell

//- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
//    {
//        self.scrollview = [[UIScrollView alloc] initWithFrame:self.frame];
//        self.scrollview.showsHorizontalScrollIndicator = NO;
//        self.scrollview.showsVerticalScrollIndicator = NO;
//        self.scrollview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        self.scrollview.backgroundColor = [UIColor clearColor];
//        self.scrollview.scrollEnabled = NO;
//        [self.contentView addSubview:self.scrollview];
//        [self setAddButton];
//        [self setAddImageSizeLabel];
//    }
//    return self;
//}
//
//- (void)setAssetURLs:(NSArray *)images
//{
//    _assetURLs = images;
//    [self setupView];
//}
//
//- (void)setupView
//{
//    int index = 0;
//    
//    for (UIView *temp in [self.scrollview subviews]) {
//        if ([temp isKindOfClass:[UIImageView class]]) {
//            [temp removeFromSuperview];
//        }
//    }
//    
//    [self setAddButton];
//    for (NSString *cacheUrlStr in self.assetURLs)
//    {
//        NSData *data = [[NSData alloc] initWithContentsOfFile:cacheUrlStr];
//        UIImage *image = [UIImage imageWithData:data];
//        
//        CGRect rect = CGRectZero;
//        rect.origin.x = (index + 1) * kImageInset + kImageSize.width * index;
//        rect.origin.y = 12.5;
//        rect.size = kImageSize;
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
//        imageView.image = image;
//        imageView.tag = kImageViewTagPre + index;
//        imageView.contentMode = UIViewContentModeScaleAspectFill;
//        imageView.layer.masksToBounds = YES;
//        imageView.layer.cornerRadius = 27.5;
//        imageView.clipsToBounds = YES;
//        [self.scrollview addSubview:imageView];
//        imageView.userInteractionEnabled = YES;
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapped:)];
//        tap.numberOfTapsRequired = 1;
//        [imageView addGestureRecognizer:tap];
//        index ++;
//    }
//    [self setAddImageSizeLabel];
//}
//
//- (void)didTapped:(UIGestureRecognizer *)recognizer
//{
//    UIView *view = recognizer.view;
//    if ([self.previewCelldelegate respondsToSelector:@selector(imagePostPreviewDidTapAtIndex:)]) {
//        [self.previewCelldelegate imagePostPreviewDidTapAtIndex:view.tag - kImageViewTagPre];
//    }
//}
//
//- (void)setAddButton
//{
//    UIButton *addButton = (UIButton *)[self.scrollview viewWithTag:kAddButtonTag];
//    if (!addButton) {
//        addButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        addButton.tag = kAddButtonTag;
//        addButton.userInteractionEnabled = YES;
//        addButton.layer.masksToBounds = YES;
//        addButton.layer.cornerRadius = 27.5;
//        [addButton setBackgroundImage:[UIImage imageNamed:@"message_tip_add"] forState:UIControlStateNormal];
//        [addButton addTarget:self action:@selector(addBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [self.scrollview addSubview:addButton];
//    }
//    NSInteger count = self.assetURLs.count;
//    addButton.frame = CGRectMake(count * (kImageSize.height + kImageInset) + kImageInset, 12.5, kImageSize.width, kImageSize.height);
//    if(count == 4)
//    {
//        addButton.hidden = YES;
//    }else{
//        addButton.hidden = NO;
//    }
//    if(count == 0)
//    {
//        [addButton setBackgroundImage:[UIImage imageNamed:@"sign_tip_photo"] forState:UIControlStateNormal];
//    }else{
//        [addButton setBackgroundImage:[UIImage imageNamed:@"message_tip_add"] forState:UIControlStateNormal];
//    }
//}
//
//- (void)setAddImageSizeLabel
//{
//    if(!self.imageSizeLabel)
//    {
//        self.imageSizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        self.imageSizeLabel.backgroundColor = [UIColor clearColor];
//        self.imageSizeLabel.hidden = YES;
//        self.imageSizeLabel.font = FS8;
//        self.imageSizeLabel.textColor = FC3;
//        [self.scrollview addSubview:self.imageSizeLabel];
//        [self.scrollview bringSubviewToFront:self.imageSizeLabel];
//    }
//    if(_assetURLs && _assetURLs.count>0)
//    {
//        self.imageSizeLabel.frame = CGRectMake([NSNumber kdDistance1], 12.5+55, ScreenFullWidth-2 * [NSNumber kdDistance1],32);
//        self.imageSizeLabel.hidden = NO;
//        self.imageSizeLabel.text = [self fileSizeStrForImages];
//    }else{
//        self.imageSizeLabel.hidden = YES;
//        self.imageSizeLabel.frame = CGRectZero;
//    }
//}
//
//- (long long) fileSizeAtPath:(NSString*) filePath{
//    NSFileManager* manager = [NSFileManager defaultManager];
//    if ([manager fileExistsAtPath:filePath]){
//        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
//    }
//    return 0;
//}
//
//- (NSString *)fileSizeStrForImages
//{
//    long long num = 0;
//    for (NSString *str in _assetURLs) {
//        num += [self fileSizeAtPath:str];
//    }
//    num = num *0.7;
//    if(num<=1024)
//    {
//        return  [NSString stringWithFormat:ASLocalizedString(@"KDPhotoSignInPhtoCell_size_byte"),num];
//    }else if(num>1024 && num < 1024*1024)
//    {
//        CGFloat size = num/1024.0;
//        return [NSString stringWithFormat:ASLocalizedString(@"KDPhotoSignInPhtoCell_size_KB"),size];
//    }else {
//        CGFloat size = num/(1024.0*1024.0);
//        return [NSString stringWithFormat:ASLocalizedString(@"KDPhotoSignInPhtoCell_size_M"),size];
//        
//    }
//}
//
//- (void)addBtnClicked:(id)sender
//{
//    if ([self.previewCelldelegate respondsToSelector:@selector(imagePostPreviewDidTapAddedButton:)]) {
//        [self.previewCelldelegate imagePostPreviewDidTapAddedButton:YES];
//    }
//}

@end
