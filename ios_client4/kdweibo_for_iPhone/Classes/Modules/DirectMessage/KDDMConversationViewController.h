//
//  KDDMConversationViewController.h
//  kdweibo
//

#import <UIKit/UIKit.h>
#import "CommenMethod.h"

#import "KDThumbnailView.h"
#import "KDDMChatInputView.h"

#import "KDPhotoGalleryViewController.h"
#import "KDRequestWrapper.h"
//#import "KDDMParticipantPickerViewController.h"
#import "KDAudioBubbleCell.h"
#import "ChatBubbleCell.h"
#import "KDFrequentContactsPickViewController.h"

#import "KDRefreshTableView.h"

@protocol KDDMConversationViewControllerDelegate <NSObject>
@required
- (void)dmThread:(KDDMThread *)thread didChangeUnreadCount:(NSUInteger)unreadCount;
@optional
- (void)inboxPrivateMessageReset:(KDDMThread *)thread;
@end

@class KDDMThread;
@class KDAudioRecordView;

@interface KDDMConversationViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, KDRefreshTableViewDataSource, KDRefreshTableViewDelegate, KDRequestWrapperDelegate, KDThumbnailViewDelegate, KDDMChatInputViewDelegate, KDPhotoGalleryViewControllerDataSource,KDFrequentContactsPickViewControllerDelegate, KDAudioBubbleCellDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, ChatBubbleCellDelegate> {
@private
//    id<KDDMConversationViewControllerDelegate> delegate_;
    KDDMThread *dmThread_;
    NSString *dmThreadID_;
    NSMutableArray *messages_;
    NSMutableArray *messageIdToTag_;
    
    NSString *audioFilePath_;
    id curBubbleCell_;  //weak reference;
    
    KDRefreshTableView *messagesTableView_;
    CGPoint contentOffset_;
    
    UIView *tipView_; //weak reference;
    NSTimer *updateTimer_; //weak
    NSString *nextSinceDMId_;
    
    KDDMChatInputView *chatInputView_;
    KDAudioRecordView *recordView_;
    UIPanGestureRecognizer *panrecognizer_; //weak reference;
    CGPoint           panStartPoint_;
    BOOL              isRecording_;
    
    id<KDImageDataSource> tappedOnImageDataSource_;
    
    struct {
        unsigned int initialized:1;
        unsigned int initialWithID:1;
        unsigned int hasDMPostRequest:1;
        unsigned int didReceiveMemoryWarning:1;
        unsigned int navigateToPrevious:1;
        unsigned int couldNotAddParticipant:1;
        unsigned int showingImagePicker:1;
        unsigned int doAddingParticipiant;
        unsigned int showFromGallary:1;
        unsigned int shouldLoadMessage:1;
    }dmViewControllerFlags_;

}

@property(nonatomic, assign) id<KDDMConversationViewControllerDelegate> delegate;
@property(nonatomic, retain) KDDMThread *dmThread;
@property (nonatomic, copy)  NSString *dmThreadID;
@property(nonatomic, retain) NSArray *addedParicipants;

- (id)initWithDMThread:(KDDMThread *)dmThread;
- (id)initWithDMThreadID:(NSString *)dmThreadId;

- (id)initWithParticipants:(NSArray *)participants;

@end
