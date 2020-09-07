//
//  KDDocumentCell.h
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-4-25.
//
//

#import <UIKit/UIKit.h>
#import "KDDownload.h"

@interface KDDocumentCell : UITableViewCell{
@private
    KDDownload *download_;
    
    UIImageView *kindImageView_;
    UILabel *filenameLabel_;
}

@property(nonatomic, retain) KDDownload *download;
@property(nonatomic, retain) UIImageView *kindImageView;
@property(nonatomic, retain) UILabel *filenameLabel;


+ (CGFloat)optimalHeight;

@end
