//
//  PostViewController.h
//  TwitterFon
//
//  Created by kaz on 7/16/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "KDDraft.h"
#import "KDPostActionMenuView.h"
#import "KDTrendEditorViewController.h"

#import "KDExpressionInputView.h"

@class DraftViewController;
@class HPGrowingTextView;
@class PostViewController;
extern NSString * const kKDFriendSendingWeiboNotification;
extern NSString * const kKDFriendSendedWeiboNotification;

@interface PostViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIScrollViewDelegate, UITextViewDelegate, KDPostActionMenuViewDelegate, KDTrendEditorViewControllerDelegate,KDExpressionInputViewDelegate>
{
    HPGrowingTextView *textView_;
    NSRange caret;
    KDPostActionMenuView *actionMenuView_; 
    UIView *atFriendsContainerView_;
    
    KDExpressionInputView *expressionInputView_;
    
    NSOperationQueue *operationQueue_;
    NSMutableArray *pickedImageCachePath_;
    
    NSRange                     textRange;
    
    BOOL                        bLoadbyLongPress;
    
    // Now, The draft view controller will be retained, please change the solution in the future
    DraftViewController *draftViewController_;
    KDDraft *draft_;
    
    NSString *contentBackup_; // if did receive memory warning, backup content
    
    BOOL hasAtFlag;//是否已经@标志
    
    struct {
        unsigned int initialized:1;
        unsigned int imageFromUnsendDraft:1;
        unsigned int delayPresentThumbnail:1;
        unsigned int viewDidUnload:1;
        unsigned int didCancelPickImage:1;
    }postViewControllerFlags_;
}

@property(nonatomic, retain) DraftViewController *draftViewController;
@property(nonatomic, retain) KDDraft *draft;
@property(nonatomic, retain) KDStatus *originalStatus; //原始微博

@property(nonatomic, assign) BOOL bLoadbyLongPress;
// 是否可以选择微博发送范围
@property(nonatomic, assign) BOOL isSelectRange;
@property(nonatomic, retain) KDAttachment *attachment;
@property(nonatomic, retain) MessageFileDataModel *fileDataModel;// 分享文件

- (void)setPickedImage:(NSArray *)imagePaths;

- (void)setVideoThumbnail:(NSArray *)imagePaths;

- (void)showImagePicker:(BOOL)hasCamera;

- (void)setPostViewContent;

@end