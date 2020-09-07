//
//  KDPostPhotoPreviewController.h
//  kdweibo
//

#import <UIKit/UIKit.h>

@protocol KDPostPhotoPreviewDelegate;
@interface KDPostPhotoPreviewController : UIViewController
{
    CALayer *transitionLayer;
}

@property (nonatomic, assign) id<KDPostPhotoPreviewDelegate> delegate;

@property (nonatomic, copy)   NSMutableArray *cachedImageURLs; //选择的图片在缓存的URL

@property (nonatomic, copy)   NSMutableArray *cachedAssetURLs; //选择的图片在相册里的URL

@property (nonatomic, assign) NSUInteger currentIndex;
 
@end


@protocol KDPostPhotoPreviewDelegate <NSObject>

- (void)postPhotoPreview:(KDPostPhotoPreviewController *)preview done:(BOOL)done userInfo:(NSDictionary *)info;

@end