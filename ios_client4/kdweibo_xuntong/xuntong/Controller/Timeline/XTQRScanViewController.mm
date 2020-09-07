//
//  XTQRScanViewController.m
//  XT
//
//  Created by Gil on 13-8-23.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTQRScanViewController.h"
#import "UIButton+XT.h"
#import "BOSSetting.h"
#import "BOSUtils.h"
#import "ASIFormDataRequest.h"
#import "ZXingObjC.h"
//#import <QRCodeReader.h>
//#import <TwoDDecoderResult.h>
#import "KDQRScanView.h"
#import "KDScanHelper.h"

@interface XTQRScanViewController () <AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, KDQRScanDelegate,UIViewControllerTransitioningDelegate>
{
    // iOS 7 二维码Output
    AVCaptureMetadataOutput *_output;
    // ZXing 二维码Output
    AVCaptureVideoDataOutput *_captureOutput;
    
    BOOL _bIsIOS7Scanning;
}
@property (nonatomic, strong) KDQRScanView *overlayView;
@property (nonatomic, assign) BOOL isOpen;
@end

@implementation XTQRScanViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)init {
    self = [super init];
    if (self) {
        self.title = ASLocalizedString(@"XTTimelineViewController_Scan");
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
         self.overlayView = [[KDQRScanView alloc] initWithFrame:CGRectMake(.0, .0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) )];
        self.overlayView.delegate = self;
#if !(TARGET_IPHONE_SIMULATOR)
        self.overlayView.displayedMessage = ASLocalizedString(@"KDApplicationViewController_scan");
#else
        self.overlayView.displayedMessage = ASLocalizedString(@"KDApplicationViewController_un_support_scan");
#endif
        
        CGRect rect = self.overlayView.cropRect;
        rect.origin.y = 110.0;
        self.overlayView.cropRect = rect;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:ASLocalizedString(@"Global_Cancel")style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
//    self.navigationItem.leftBarButtonItems= @[cancelItem];
    
    //    UIButton *infoBtn = [UIButton buttonWithTitle:ASLocalizedString(@"登录网页版")];
    //    [infoBtn addTarget:self action:@selector(info:) forControlEvents:UIControlEventTouchUpInside];
    //    UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithCustomView:infoBtn];
    //    self.navigationItem.rightBarButtonItem = infoItem;
    
    
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:ASLocalizedString(@"Global_Cancel")];
    button.titleLabel.font = FS3;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buttonItem =  [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftItem.width = -15;
    self.navigationItem.leftBarButtonItems = @[leftItem, buttonItem];
    [self.navigationItem.leftBarButtonItem setTitlePositionAdjustment:UIOffsetMake([NSNumber kdLeftItemDistance], 0) forBarMetrics:UIBarMetricsDefault];
    
    if (isAboveiOS8) {
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton setTitle:ASLocalizedString(@"KDImagePickerController_Photo")];
        rightButton.titleLabel.font = FS3;
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rightButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        
        [rightButton addTarget:self action:@selector(presentImagePicker) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        rightItem.width = -15;
        
        self.navigationItem.rightBarButtonItems = @[rightItem, rightBtnItem];;
        [self.navigationItem.rightBarButtonItem setTitlePositionAdjustment:UIOffsetMake([NSNumber kdRightItemDistance], 0) forBarMetrics:UIBarMetricsDefault];
    }
    if (isiPad) {
        self.overlayView.startLight.hidden = YES;
        self.overlayView.lightLabel.hidden = YES;
    }
    [self changeToWhiteNavStyleWithColorStr];
}

- (void)changeToWhiteNavStyleWithColorStr{
    if (self.navigationController.navigationBar.hidden) {
        return;
    }
    
    [self setNavigationCustomStyleWithColor:[UIColor colorWithRGB:0x0C213F alpha:0.3]];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage kd_imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self.view addSubview:self.overlayView];
    //    [self.overlayView setPoints:nil];
    [self.view bringSubviewToFront:self.instructionLabel];
    
    self.isOpen = NO;
    [self.overlayView.startLight setBackgroundImage:[UIImage imageNamed:@"open_light"] forState:UIControlStateNormal];
    self.overlayView.lightLabel.text = ASLocalizedString(@"open_light");
#if !(TARGET_IPHONE_SIMULATOR)
    [self startCapture];
#endif

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if (!isiPad) {
        self.isOpen = NO;
        [self.overlayView.startLight setBackgroundImage:[UIImage imageNamed:@"open_light"] forState:UIControlStateNormal];
        self.overlayView.lightLabel.text = ASLocalizedString(@"open_light");
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    [self.overlayView removeFromSuperview];
#if !(TARGET_IPHONE_SIMULATOR)
    [self stopCapture];
#endif
    
}

- (void)startCapture
{
    _bIsIOS7Scanning = NO;
    
    // 1. 摄像头设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 2. 设置输入
    // 因为模拟器是没有摄像头的，因此在此最好做一个判断
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (error) {
        return;
    }
    
    // 3. 设置输出(Metadata元数据)
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    // 说明：使用主线程队列，相应比较同步，使用其他队列，相应不同步，容易让用户产生不好的体验
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 4. 拍摄会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    // 添加session的输入和输出
    [session addInput:input];
    [session addOutput:output];
    
    // 提示：一定要先设置会话的输出为output之后，再指定输出的元数据类型！
    NSArray *barCodeTypes = nil;
    
    if (isAboveiOS8) {
        barCodeTypes = @[AVMetadataObjectTypeUPCECode,
                         AVMetadataObjectTypeCode39Code,
                         AVMetadataObjectTypeCode39Mod43Code,
                         AVMetadataObjectTypeEAN13Code,
                         AVMetadataObjectTypeEAN8Code,
                         AVMetadataObjectTypeCode93Code,
                         AVMetadataObjectTypeCode128Code,
                         AVMetadataObjectTypePDF417Code,
                         AVMetadataObjectTypeQRCode,
                         AVMetadataObjectTypeAztecCode,
                         AVMetadataObjectTypeInterleaved2of5Code,
                         AVMetadataObjectTypeITF14Code,
                         AVMetadataObjectTypeDataMatrixCode];
    }
    else {
        barCodeTypes = @[AVMetadataObjectTypeUPCECode,
                         AVMetadataObjectTypeCode39Code,
                         AVMetadataObjectTypeCode39Mod43Code,
                         AVMetadataObjectTypeEAN13Code,
                         AVMetadataObjectTypeEAN8Code,
                         AVMetadataObjectTypeCode93Code,
                         AVMetadataObjectTypeCode128Code,
                         AVMetadataObjectTypePDF417Code,
                         AVMetadataObjectTypeQRCode,
                         AVMetadataObjectTypeAztecCode];
    }
    [output setMetadataObjectTypes:barCodeTypes];
    // 5. 设置预览图层（用来让用户能够看到扫描情况）
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    [preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [preview setFrame:self.view.bounds];
    [self.view.layer insertSublayer:preview atIndex:0];
    self.captureVideoPreviewLayer = preview;
    [output setRectOfInterest:self.view.bounds];
    
    // 6. 启动会话
    [session startRunning];
    self.captureSession = session;
}

- (void)stopCapture
{
    [self.captureSession stopRunning];
    _bIsIOS7Scanning = YES;
    AVCaptureInput* input = [self.captureSession.inputs objectAtIndex:0];
    [self.captureSession removeInput:input];
    AVCaptureVideoDataOutput* output = (AVCaptureVideoDataOutput*)[self.captureSession.outputs objectAtIndex:0];
    [self.captureSession removeOutput:output];
    [self.captureVideoPreviewLayer removeFromSuperlayer];
    
    self.captureVideoPreviewLayer = nil;
    self.captureSession = nil;
}

- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (!colorSpace)
    {
        NSLog(@"CGColorSpaceCreateDeviceRGB failure");
        return nil;
    }
    
    // Get the base address of the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // Get the data size for contiguous planes of the pixel buffer.
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    
    // Create a Quartz direct-access data provider that uses data we supply
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize,
                                                              NULL);
    // Create a bitmap image from data supplied by our data provider
    CGImageRef cgImage =
    CGImageCreate(width,
                  height,
                  8,
                  32,
                  bytesPerRow,
                  colorSpace,
                  kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
                  provider,
                  NULL,
                  true,
                  kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    // Create and return an image object representing the specified Quartz image
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return image;
}

- (void)decodeImage:(UIImage *)image
{
    //    NSMutableSet *qrReader = [[NSMutableSet alloc] init];
    //    QRCodeReader *qrcoderReader = [[QRCodeReader alloc] init];
    //    [qrReader addObject:qrcoderReader];
    //
    //    Decoder *decoder = [[Decoder alloc] init];
    //    decoder.delegate = self;
    //    decoder.readers = qrReader;
    //    [decoder decodeImage:image];
}

- (void)info:(UIButton *)btn
{
    [self.captureSession stopRunning];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:ASLocalizedString(@"在电脑浏览器中输入xt.kingdee.com，然后扫描网页上的二维码，即可登录网页版。")delegate:self cancelButtonTitle:ASLocalizedString(@"KDApplicationViewController_tips_i_know")otherButtonTitles:nil];
    [alert show];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if(!isAboveiOS7) {
        UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
        [self decodeImage:image];
    }
}

#pragma mark - DecoderDelegate
//// ZXing二维码回调
//- (void)decoder:(Decoder *)decoder didDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset withResult:(TwoDDecoderResult *)result
//{
//    [self.captureSession stopRunning];
//    self.qrUrl = result.text;
//    [self onCapture];
//}

- (void)onCapture
{
    NSString *url = [self.qrUrl lowercaseString];
    if ([[KDWeiboAppDelegate getAppDelegate] checkJoinByURL:url]) {
        return;
    }
    
    int qrLoginCode = QRLoginNO;
    if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"])
    {
        if ([url rangeOfString:@"qrlogin.do"].location != NSNotFound)
        {
            qrLoginCode = QRLoginXTWeb;
        }
        else if ([url rangeOfString:@"login.mykingdee.com/qrcode"].location != NSNotFound)
        {
            qrLoginCode = QRLoginMykingdee ;
        }
        //邀请加入
        else if ([url rangeOfString:@"kingdee_invite_eid"].location != NSNotFound)
        {
            qrLoginCode = QRInvite;
        }else if(([url rangeOfString:@"mid"].location != NSNotFound) && ([url rangeOfString:@"appid"].location != NSNotFound))
        {
            qrLoginCode = QRLoginThirdPart;
        }else if([url rangeOfString:@"qrcodecreate?ticket"].location != NSNotFound){
            qrLoginCode = QRPubAccScan;
        }else if ([url rangeOfString:@"yzjfuntion=lightapp"].location != NSNotFound) {
            qrLoginCode = KDQRCodeExternalGroup;
        }else
            qrLoginCode = QRLoginNO;
    }
    
    if (qrLoginCode > 0)
    {
        if (qrLoginCode == QRLoginXTWeb || qrLoginCode == QRLoginMykingdee || qrLoginCode == QRLoginThirdPart || qrLoginCode == QRPubAccScan) {
            if (_delegate && [_delegate respondsToSelector:@selector(qrScanViewController:loginCode:result:)]) {
                [self.delegate qrScanViewController:self loginCode:qrLoginCode result:self.qrUrl];
            }
        }
        else if (qrLoginCode == QRInvite) {
            //            if (_delegate && [_delegate respondsToSelector:@selector(loadWebViewControllerWithUrl:)]) {
            //                [self.delegate loadWebViewControllerWithUrl:self.qrUrl];
            //            }
            if (_delegate && [_delegate respondsToSelector:@selector(qrScanViewController:loginCode:result:)]) {
                [self.delegate qrScanViewController:self loginCode:QRLoginNO result:self.qrUrl];
            }
            if (_delegate && [_delegate respondsToSelector:@selector(loadWebViewControllerWithUrl:)]) {
                [self.delegate loadWebViewControllerWithUrl:self.qrUrl];
            }
            
        }
        else if (qrLoginCode == KDQRCodeExternalGroup){
            KDQRAnalyse *qrAnalyse = [KDQRAnalyse sharedManager];
            qrAnalyse.lastViewController = self.controller;
//            QRLoginCode qrCode = [qrAnalyse analyse:self.qrUrl] ;
            __weak __typeof(self) weakSelf = self;
            [qrAnalyse execute:self.qrUrl callbackBlock:^(QRLoginCode qrCode,NSString *qrResult){
                if (qrLoginCode != QRLoginNO) {
                    weakSelf.navigationController.transitioningDelegate = weakSelf;
                    weakSelf.modalTransitionStyle = UIModalPresentationCustom;
                    [weakSelf.controller dismissViewControllerAnimated:YES completion:^{
                        ((KDWeiboAppDelegate *)[UIApplication sharedApplication].delegate).tabBarController.selectedIndex = 0;
                        [qrAnalyse gotoResultVCInTargetVC:(((KDWeiboAppDelegate *)[UIApplication sharedApplication].delegate).timelineViewController) withQRResult:weakSelf.qrUrl andQRCode:KDQRCodeExternalGroup];
                    }];
                }
                else {
                    [weakSelf resumeCapture];
                }
            }];
        }

    }
    else
    {
        if (self.JSBridgeDelegate && [self.JSBridgeDelegate respondsToSelector:@selector(theURL:)]) {
            [self.controller dismissViewControllerAnimated:YES completion:^(void){
                [self.JSBridgeDelegate theURL:self.qrUrl];
            }];
            return;
        }
        
        UIAlertView *alert = nil;
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.qrUrl]]) {
            alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTQRScanViewController_Open_Url")message:self.qrUrl delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Cancel")otherButtonTitles:ASLocalizedString(@"Global_Sure"), nil];
        } else {
            alert = [[UIAlertView alloc] initWithTitle:ASLocalizedString(@"XTQRScanViewController_QR_Info")message:self.qrUrl delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:ASLocalizedString(@"BubbleTableViewCell_Tip_6"), nil];
            alert.tag = 9000;
        }
        [alert show];
    }
}
- (void)resumeCapture {
    [self.captureSession startRunning];
}
#pragma mark - Delegates
// iOS7 二维码回调
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (_bIsIOS7Scanning)
        return;
    
    for (AVMetadataObject *metadata in metadataObjects)
    {
        
        AVMetadataMachineReadableCodeObject *transformed = (AVMetadataMachineReadableCodeObject *)metadata;
        // Update the view with the decoded text
        NSString *decodedString = [transformed stringValue];
        
        self.qrUrl = decodedString;
        [self onCapture];
    }
    _bIsIOS7Scanning = YES;
}


- (void)cancel:(UIButton *)button
{
    [self.captureSession stopRunning];
    if (_delegate && [_delegate respondsToSelector:@selector(qrScanViewControllerDidCancel:)]) {
        [self.delegate qrScanViewControllerDidCancel:self];
    }
}

- (void)presentImagePicker {
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^ {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (image) {
            NSString *qrResult = [KDScanHelper scanQRWithImage:image];
            if (qrResult) {
                self.qrUrl = qrResult;
                [self onCapture];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:ASLocalizedString(@"XTQRScanViewController_NoFind_QR") delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
                [alert show];
            }
        }
    }];
    
}

#pragma mark - KDQRScanDelegate
- (void)changeLightStatue:(UIButton *)button {
    if (self.isOpen) {
        [button setBackgroundImage:[UIImage imageNamed:@"open_light" ] forState:UIControlStateNormal];
        self.overlayView.lightLabel.text = ASLocalizedString(@"open_light");
        [self turnOffLed];
    }
    else {
        [button setBackgroundImage:[UIImage imageNamed:@"close_light"] forState:UIControlStateNormal];
        self.overlayView.lightLabel.text = ASLocalizedString(@"close_light");
        [self turnOnLed];
    }
}

- (void)turnOffLed {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
    self.isOpen = NO;
}
- (void)turnOnLed {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOn];
        [device unlockForConfiguration];
    }
    self.isOpen = YES;
}

//- (void)sendpost:(NSString*)url
//{
//    NSArray *array = [url componentsSeparatedByString:@"?"];
//
//    NSString *ua = [NSString stringWithFormat:@"xuntong/%@;%@;%@;",[[UIDevice currentDevice] systemVersion],[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] model]];
//    NSString *deviceUa =[BOSUtils urlEncode:ua];
//    NSString *cust3gNo = [BOSSetting sharedSetting].cust3gNo;
//    NSString *postURL = [NSString stringWithFormat:@"%@?appkey=1&cust3gNo=%@&ua=%@",[array objectAtIndex:0],cust3gNo,deviceUa];
//
//    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:postURL]];
//
//    [request startSynchronous];
//
//    NSData *data = [[request responseString] dataUsingEncoding:NSUTF8StringEncoding];
//    NSDictionary *responeData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONWritingPrettyPrinted error:nil];
//    NSDictionary*dic=[responeData objectForKey:@"data"];
//    if ([[dic objectForKey:@"qrType"]isEqualToString:@"pubacc"]) {
//        if (_delegate && [_delegate respondsToSelector:@selector(publicDetailControllerWithperson:)]) {
//            [self.delegate publicDetailControllerWithperson:[dic objectForKey:@"pubaccId"]];
//        }
//    }
//    else if ([[dic objectForKey:@"qrType"]isEqualToString:@"lightapp"]) {
//        if (_delegate && [_delegate respondsToSelector:@selector(loadWebViewControllerWithUrl:)]) {
//            NSString*lightappUrl = [NSString stringWithFormat:@"%@",[dic objectForKey:@"url"]];
//            [self.delegate loadWebViewControllerWithUrl:lightappUrl];
//        }
//    }
//    else if ([[dic objectForKey:@"qrType"]isEqualToString:@"nativeapp"]) {
//        NSURL *url = [NSURL URLWithString:[dic objectForKey:@"url"]];
//        if ([[UIApplication sharedApplication] canOpenURL:url]) {
//            [[UIApplication sharedApplication] openURL:url];
//        }
//    }
//}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self stopCapture];
    if (buttonIndex == alertView.cancelButtonIndex) {
        [self startCapture];
    } else {
        if (alertView.tag == 9000) {
            if (alertView.message) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                [pasteboard setString:alertView.message];
            }
            [self startCapture];
            return;
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(qrScanViewController:loginCode:result:)]) {
            [self.delegate qrScanViewController:self loginCode:QRLoginNO result:self.qrUrl];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(loadWebViewControllerWithUrl:)]) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.delegate loadWebViewControllerWithUrl:self.qrUrl];
        }
        
    }
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [KDCustomTransition transitionWithType:KDCustomTransitionType_Dismiss_Transparent duration:0.2];
}

@end
