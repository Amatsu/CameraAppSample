//
//  CameraManager.m
//  CameraManager
//
//  Created by Amatsu on 2013/12/01.
//  Copyright (c) 2013年 Amatsu. All rights reserved.
//

#import "CameraManager.h"
#import <MediaPlayer/MediaPlayer.h>

@interface CameraManager(){
    //AVセッション
    AVCaptureSession* captureSession;
    //使用中の入力デバイス
    AVCaptureDeviceInput* videoInput;
    //静止画出力デバイス
    AVCaptureStillImageOutput* imageOutput;
    //オーディオ出力デバイス
    AVCaptureAudioDataOutput* audioOutput;
    //オーディオ出力用スレッド
    dispatch_queue_t audioOutputQueue;
    //デオ出力デバイス
    AVCaptureVideoDataOutput* videoOutput;
    //ビデオ出力用スレッド
    dispatch_queue_t videoOutputQueue;
    //拡大倍率
    CGFloat effectiveScale;
    //消音設定
    BOOL silent;
    //フォーカスをあわせる時のフレーム
    CALayer* foucusSetFrameView;
    //フォーカスをあわせるときのフレームサイズ
    #define INDICATOR_RECT_SIZE 50.0
}

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition)position;
- (AVCaptureDevice *) frontFacingCamera;
- (AVCaptureDevice *) backFacingCamera;
- (AVCaptureDevice *) audioDevice;

@end

@implementation CameraManager

- (AVCaptureDeviceInput *) getInputDevice{
    return videoInput;
}

#pragma mark -　カメラ切り替え
- (void)useFrontCamera:(BOOL)yesno{
    if(yesno == YES)
        [self enableCamera:AVCaptureDevicePositionFront];
    else
        [self enableCamera:AVCaptureDevicePositionBack];
}

- (void)flipCamera{
    if(self.isUsingFrontCamera)
        [self useFrontCamera:NO];
    else
        [self useFrontCamera:YES];
}
    
//カメラを有効化
-(void)enableCamera:(AVCaptureDevicePosition)desiredPosition{
    [captureSession stopRunning];
    
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([d position] == desiredPosition) {
            [captureSession beginConfiguration];
            videoInput= [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
            for (AVCaptureInput *oldInput in [[self.previewLayer session] inputs]) {
                [captureSession removeInput:oldInput];
            }
            [captureSession addInput:videoInput];
            [captureSession commitConfiguration];
            break;
        }
    }
    [captureSession startRunning];
}

- (BOOL)isUsingFrontCamera{
    if(videoInput.device.position == AVCaptureDevicePositionFront)
        return YES;
    else
        return NO;
}

#pragma mark - ライト制御
- (void)light:(BOOL)yesno{
    if(![self.backCameraDevice hasTorch])
        return;
    
    //フロントカメラ使用中ばらバックカメラに切り替え
    if(self.isUsingFrontCamera)
        [self useFrontCamera:NO];
    
    NSError * error;
    [self.backCameraDevice lockForConfiguration:&error];
    
    if(yesno)
        self.backCameraDevice.torchMode = AVCaptureTorchModeOn;
    else
        self.backCameraDevice.torchMode = AVCaptureTorchModeOff;
    
    [self.backCameraDevice unlockForConfiguration];
}

- (BOOL)isLightOn{
    if(![self.backCameraDevice hasTorch])
        return YES;
    if(self.backCameraDevice.isTorchActive)
        return YES;
    return NO;
}

-(void)lightToggle{
    if(self.isLightOn)
        [self light:NO];
    else
        [self light:YES];
}

#pragma mark - フォーカス制御
/*
 AVCaptureFocusModeLocked 焦点距離ロックモード
 AVCaptureFocusModeAutoFocus 焦点がシーンの中心から外れても焦点維持
 AVCaptureFocusModeContinuousAutoFocus 必要に応じてオートフォーカスになるモード
 */

- (void) autoFocusAtPoint:(CGPoint)point{
    
    //(1) 0.0〜1.0 に正規化した値
    //(2) ランドスケープ（横向き/ホームボタン右）の時の左上を原点とする座標系
    CGSize viewSize = self.previewLayer.bounds.size;
    CGPoint pointOfInterest = CGPointMake(point.y / viewSize.height,1.0 - point.x / viewSize.width);
    
    AVCaptureDevice *device = videoInput.device;
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:pointOfInterest];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
            [self setFoucusAnimation:point];
        }
    }
}

- (void) continuousFocusAtPoint:(CGPoint)point{
    
    //(1) 0.0〜1.0 に正規化した値
    //(2) ランドスケープ（横向き/ホームボタン右）の時の左上を原点とする座標系
    CGSize viewSize = self.previewLayer.bounds.size;
    CGPoint pointOfInterest = CGPointMake(point.y / viewSize.height,1.0 - point.x / viewSize.width);
    
    AVCaptureDevice *device = videoInput.device;
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
		NSError *error;
		if ([device lockForConfiguration:&error]) {
			[device setFocusPointOfInterest:pointOfInterest];
			[device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
			[device unlockForConfiguration];
            [self setFoucusAnimation:point];
		}
	}
}

#pragma mark - 露出制御
//露光処理開始フラグ(device.adjustingExposureを手動では変更できないため）
BOOL adjustingExposure;

//露光調整
- (void) autoExposureAtPoint:(CGPoint)point{
    
    //(1) 0.0〜1.0 に正規化した値
    //(2) ランドスケープ（横向き/ホームボタン右）の時の左上を原点とする座標系
    CGSize viewSize = self.previewLayer.bounds.size;
    CGPoint pointOfInterest = CGPointMake(point.y / viewSize.height,1.0 - point.x / viewSize.width);
    
    AVCaptureDevice *device = videoInput.device;
    if( [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            adjustingExposure = YES;
            device.exposurePointOfInterest = pointOfInterest;
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            [device addObserver:self
                     forKeyPath:@"adjustingExposure"
                        options:NSKeyValueObservingOptionNew
                        context:nil];
            [device unlockForConfiguration];
            NSLog(@"2:%d",device.adjustingExposure);
            
        }
    }
}

//露光調整終了時
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    AVCaptureDevice *device = videoInput.device;
    if (!adjustingExposure) {
        return;
    }
    NSLog(@"3:%d",device.adjustingExposure);
    if ([keyPath isEqual:@"adjustingExposure"]) {
        NSLog(@"4:%d",device.adjustingExposure);
        if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue] == NO) {
            adjustingExposure = NO;
            NSError *error = nil;
            if ([device lockForConfiguration:&error]) {
                [device setExposureMode:AVCaptureExposureModeLocked];
                [device unlockForConfiguration];
            }
        }
    }
}

#pragma mark - フォーカスアニメーション
//フォーカス設定位置にフォーカスレイヤをアニメーション表示
- (void) setFoucusAnimation:(CGPoint)point {
    foucusSetFrameView.frame = CGRectMake(point.x - INDICATOR_RECT_SIZE/2.0,
                                          point.y - INDICATOR_RECT_SIZE/2.0,
                                          INDICATOR_RECT_SIZE,
                                          INDICATOR_RECT_SIZE);
    
    //ポイントをアニメーション表示
    [self blinkImage:foucusSetFrameView];
}

//点滅アニメーション
- (void)blinkImage:(CALayer *)target {
    
    target.hidden = NO;
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 0.1f;
    animation.autoreverses = YES;
    animation.repeatCount = 3; //infinite loop -> HUGE_VAL
    animation.fromValue = [NSNumber numberWithFloat:1.0f]; //MAX opacity
    animation.toValue = [NSNumber numberWithFloat:0.1f]; //MIN opacity
    animation.delegate = self;
    [target addAnimation:animation forKey:@"blink"];
    
}

//アニメーション停止
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag)
        foucusSetFrameView.hidden = YES;
}

#pragma mark - ズーム制御
- (void) setScale:(CGFloat)scale{
    effectiveScale = scale;
    if (effectiveScale < 1.0)
        effectiveScale = 1.0;
    //拡大可能最大倍率の場合は最大値で固定
    CGFloat maxScaleAndCropFactor = [[imageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
    if (effectiveScale > maxScaleAndCropFactor)
        effectiveScale = maxScaleAndCropFactor;
    //消音撮影の場合は拡大非対応(UIImage取得後の拡大処理の最適化処理が遅いため）
    if (silent == YES)
        effectiveScale = 1.0;
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025];
    //プレビューレイヤに拡大倍率を適用
    [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(effectiveScale, effectiveScale)];
    [CATransaction commit];
    
}
#pragma mark - 消音設定
//消音ONOFF
- (void)silent:(BOOL)yesno {
    silent = yesno;
    //消音撮影の場合は拡大倍率を初期化する
    if (silent == YES)
        [self setScale:effectiveScale];
}

//消音設定反転
- (void)silentModeToggle {
    silent = !silent;
    //消音撮影の場合は拡大倍率を初期化する
    if (silent == YES)
        [self setScale:effectiveScale];
}

#pragma mark -　初期化
//初期化
- (id)init{
    if(super.init)
    {
        [self setupAvCapture:AVCaptureSessionPreset1280x720];
        [self initSetting];
        return self;
    }
    return nil;
}

//解像度を指定して初期化
- (id)initWithPreset:(NSString *)preset{
    if(super.init)
    {
        [self setupAvCapture:preset];
        [self initSetting];
        return self;
    }
    return nil;
}

//画面サイズ以外の初期パラメタを設定
- (void) initSetting {
    //消音OFF
    silent = NO;
    //拡大倍率
    effectiveScale = 1.0;
}

//プレビューレイヤをビューに設定
- (void)setPreview:(UIView *)view{
    self.previewLayer.frame = view.bounds;
    [view.layer addSublayer:self.previewLayer];
    [self setFoucusLayer];
}

//フォーカス用のレイヤを追加
- (void)setFoucusLayer {
    foucusSetFrameView = [CALayer layer];
    foucusSetFrameView.borderColor = [[UIColor whiteColor] CGColor];
    foucusSetFrameView.borderWidth = 1.0;
    foucusSetFrameView.frame = CGRectMake(self.previewLayer.bounds.size.width/2.0 - INDICATOR_RECT_SIZE/2.0,
                                          self.previewLayer.bounds.size.height/2.0 - INDICATOR_RECT_SIZE/2.0,
                                          INDICATOR_RECT_SIZE,
                                          INDICATOR_RECT_SIZE);
    foucusSetFrameView.hidden = YES;
    [self.previewLayer addSublayer:foucusSetFrameView];
}

- (void)setupAvCapture:(NSString*)preset{
    //カメラの一覧を取得しカメラデバイスを保存
    self.backCameraDevice = nil;
    self.frontCameraDevice = nil;
    NSArray* cameraArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for(AVCaptureDevice* camera in cameraArray){
        if(camera.position == AVCaptureDevicePositionBack)
            self.backCameraDevice = camera;
        if(camera.position == AVCaptureDevicePositionFront)
            self.frontCameraDevice = camera;
    }
    
    //デフォルトはバックカメラ
    videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.backCameraDevice error:nil];
    
    //セッション作成
    captureSession = AVCaptureSession.new;
    [captureSession setSessionPreset:preset];
    [captureSession addInput:videoInput];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    [self.previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    
    [self setupImageCapture];
    [self setupVideoCapture];
    
    [captureSession startRunning];
    
}

//静止画キャプチャの初期化
//設定後captureOutputが呼ばれる
- (BOOL)setupImageCapture{
    imageOutput = AVCaptureStillImageOutput.new;
    if(imageOutput)
    {
        if([captureSession canAddOutput:imageOutput])
        {
            [captureSession addOutput:imageOutput];
            return YES;
        }
    }
    return NO;
}

//ビデオキャプチャの初期化
//設定後:captureOutputが呼ばれる
-(BOOL)setupVideoCapture{

    //ビデオ出力デバイスの設定
	NSDictionary *rgbOutputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCMPixelFormat_32BGRA)};
    videoOutput = AVCaptureVideoDataOutput.new;
	[videoOutput setVideoSettings:rgbOutputSettings];
	[videoOutput setAlwaysDiscardsLateVideoFrames:YES];     //  NOだとコマ落ちしないが重い処理には向かない
  	videoOutputQueue = dispatch_queue_create("VideoData Output Queue", DISPATCH_QUEUE_SERIAL);
	[videoOutput setSampleBufferDelegate:self queue:videoOutputQueue];
    
	if(videoOutput){
        if ([captureSession canAddOutput:videoOutput]){
            [captureSession addOutput:videoOutput];
            return YES;
        }
    }
    return NO;
}

//オーディオキャプチャの初期化
-(BOOL)setupAudioCapture{
    audioOutput = AVCaptureAudioDataOutput.new;
    audioOutputQueue = dispatch_queue_create("Audio Capture Queue", DISPATCH_QUEUE_SERIAL);
	[audioOutput setSampleBufferDelegate:self queue:audioOutputQueue];
    if(audioOutput){
        
        if ([captureSession canAddOutput:audioOutput]){
            [captureSession addOutput:audioOutput];
            return YES;
        }
    }
    return NO;
}

#pragma  mark - 撮影
- (void)shotPhoto:(takePhotoBlock) block{
    
    if (silent == YES) {
        [self takePhoto:block];
    }else {
        [self rotatedVideoImage:block];
    }
}

//写真撮影
-(void)takePhoto:(takePhotoBlock) block{
    
    AVCaptureConnection* connection = [imageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    //画像の向きを調整する
    if(connection.isVideoOrientationSupported){
        connection.videoOrientation = UIDevice.currentDevice.orientation;
    }
    
    //拡大倍率を適用
    [connection setVideoScaleAndCropFactor:effectiveScale];
    
    //UIImage化した画像を通知する
    [imageOutput captureStillImageAsynchronouslyFromConnection:connection
                                             completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                 if(imageDataSampleBuffer == nil){
                                                     block(nil,error);
                                                     return;
                                                 }
                                                 NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                 UIImage *image = [UIImage imageWithData:data];
                                                 block(image,error);
                                             }];
}

//静音撮影
-(void)rotatedVideoImage:(takePhotoBlock) block {
    block([self rotatedVideoImage],nil);
}

//デバイスの向きに合わせたビデオイメージを作成
-(UIImage*)rotatedVideoImage{
    
    if(self.videoImage == nil)
        return nil;
    
    UIImage* image = nil;
    UIDeviceOrientation orientation = _videoOrientaion;
    BOOL isMirrored = self.isUsingFrontCamera;
    
    if (orientation == UIDeviceOrientationPortrait) {
        image = [CameraManager rotateImage:self.videoImage angle:270];
    } else if (orientation == UIDeviceOrientationPortraitUpsideDown) {
        image = [CameraManager rotateImage:self.videoImage angle:90];
    } else if (orientation == UIDeviceOrientationLandscapeRight) {
        if(isMirrored)
            image = self.videoImage;
        else
            image = [CameraManager rotateImage:self.videoImage angle:180];
    }else {
        if(isMirrored)
            image = [CameraManager rotateImage:self.videoImage angle:180];
        else
            image = self.videoImage;
    }
    
    return image;
}

+ (UIImage*)rotateImage:(UIImage*)img angle:(int)angle{
    CGImageRef      imgRef = [img CGImage];
    CGContextRef    context;
    
    switch (angle) {
        case 90:
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(img.size.height, img.size.width), YES, img.scale);
            context = UIGraphicsGetCurrentContext();
            CGContextTranslateCTM(context, img.size.height, img.size.width);
            CGContextScaleCTM(context, 1, -1);
            CGContextRotateCTM(context, M_PI_2);
            break;
        case 180:
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(img.size.width, img.size.height), YES, img.scale);
            context = UIGraphicsGetCurrentContext();
            CGContextTranslateCTM(context, img.size.width, 0);
            CGContextScaleCTM(context, 1, -1);
            CGContextRotateCTM(context, -M_PI);
            break;
        case 270:
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(img.size.height, img.size.width), YES, img.scale);
            context = UIGraphicsGetCurrentContext();
            CGContextScaleCTM(context, 1, -1);
            CGContextRotateCTM(context, -M_PI_2);
            break;
        default:
            return img;
            break;
    }
    
    CGContextDrawImage(context, CGRectMake(0, 0, img.size.width, img.size.height), imgRef);
    UIImage*    result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

//ビデオキャプチャ時、 新しいフレームが書き込まれた際に通知を受けるデリゲートメソッド
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    @autoreleasepool {
        
        //スケールの適用
        //[connection setVideoScaleAndCropFactor:effectiveScale];
        
        //キャプチャ画像からUIImageを作成する
        CGImageRef cgImage = [CameraManager imageFromSampleBuffer:sampleBuffer];
        UIImage* captureImage = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        
        //メインスレッドでの処理
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.videoImage = captureImage;
            self.videoOrientaion = UIDevice.currentDevice.orientation;
            
            // デリゲートの存在確認後画面更新
            if ([self.delegate respondsToSelector:@selector(videoFrameUpdate:from:)]) {
                [self.delegate videoFrameUpdate:self.videoImage.CGImage from:self];
            }
            
        });
        
    }
}

#pragma mark - ユーティリティ

- (NSUInteger) cameraCount{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (NSUInteger) micCount{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] count];
}

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *) frontFacingCamera{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *) backFacingCamera{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (AVCaptureDevice *) audioDevice{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    if ([devices count] > 0) {
        return [devices objectAtIndex:0];
    }
    return nil;
}

#pragma mark - クラス・メソッド

//SampleBufferをCGImageRefに変換する
+ (CGImageRef) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);        //バッファをロック
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);      //バッファをアンロック
    
    return newImage;
}

@end
