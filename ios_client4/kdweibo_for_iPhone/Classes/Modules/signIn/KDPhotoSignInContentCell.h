//
//  KDPhotoSignInContentCell.h
//  kdweibo
//
//  Created by lichao_liu on 9/23/15.
//  Copyright © 2015 www.kingdee.com. All rights reserved.
//

#import "KDTableViewCell.h"
#import "HPTextViewInternal.h"
@interface KDPhotoSignInContentCell : KDTableViewCell<UITextViewDelegate>
@property (nonatomic, strong) HPTextViewInternal *textView;
@end
