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
}

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition)position;
- (AVCaptureDevice *) frontFacingCamera;
- (AVCaptureDevice *) backFacingCamera;
- (AVCaptureDevice *) audioDevice;

@end

@implementation CameraManager

#pragma mark -　カメラ切り替え
- (void)useFrontCamera:(BOOL)yesno
{
    if(yesno == YES)
        [self enableCamera:AVCaptureDevicePositionFront];
    else
        [self enableCamera:AVCaptureDevicePositionBack];
}

- (void)flipCamera
{
    if(self.isUsingFrontCamera)
        [self useFrontCamera:NO];
    else
        [self useFrontCamera:YES];
}
    
//カメラを有効化
- (void)enableCamera:(AVCaptureDevicePosition)desiredPosition
{
    [captureSession stopRunning];
    
    for(AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo])
    {
        if([d position] == desiredPosition)
        {
            [captureSession beginConfiguration];
            videoInput = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
            for(AVCaptureDeviceInput *oldDevice in [[self.previewLayer session] inputs])
            {
                [captureSession addInput:videoInput];
                [captureSession commitConfiguration];
                break;
            }
        }
    }
    
    [captureSession startRunning];
}

- (BOOL)isUsingFrontCamera
{
    if(videoInput.device.position == AVCaptureDevicePositionFront)
        return YES;
    else
        return NO;
}

#pragma mark - ライト制御
- (void)light:(BOOL)yesno
{
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

- (BOOL)isLightOn
{
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

- (void) autoFocusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = videoInput.device;
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:point];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
        }    }
}


- (void) continuousFocusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = videoInput.device;
	
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
		NSError *error;
		if ([device lockForConfiguration:&error]) {
			[device setFocusPointOfInterest:point];
			[device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
			[device unlockForConfiguration];
		}
	}
}

#pragma mark -　初期化

//初期化
- (id)init
{
    if(super.init)
    {
        [self setupAvCapture:AVCaptureSessionPreset1280x720];
        return self;
    }
    return nil;
}

//解像度を指定して初期化
- (id)initWithPreset:(NSString *)preset
{
    if(super.init)
    {
        [self setupAvCapture:preset];
        return self;
    }
    return nil;
}

//プレビューレイヤをビューに設定
- (void)setPreview:(UIView *)view
{
    self.previewLayer.frame = view.bounds;
    [view.layer addSublayer:self.previewLayer];
}

- (void)setupAvCapture:(NSString*)preset
{
    //カメラの一覧を取得しカメラデバイスを保存
    self.backCameraDevice = nil;
    self.frontCameraDevice = nil;
    NSArray* cameraArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for(AVCaptureDevice* camera in cameraArray)
    {
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
//      写真撮影
-(void)takePhoto:(takePhotoBlock) block{
    
    AVCaptureConnection* connection = [imageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    //      画像の向きを調整する
    if(connection.isVideoOrientationSupported){
        connection.videoOrientation = UIDevice.currentDevice.orientation;
    }
    
    //      UIImage化した画像を通知する
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
//  デバイスの向きに合わせたビデオイメージを作成
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
+ (UIImage*)rotateImage:(UIImage*)img angle:(int)angle
{
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

//
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    @autoreleasepool {
        
        //     キャプチャ画像からUIImageを作成する
        CGImageRef cgImage = [CameraManager imageFromSampleBuffer:sampleBuffer];
        UIImage* captureImage = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        
        ////////////////////////////////////////////
        //      メインスレッドでの処理
        ////////////////////////////////////////////
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.videoImage = captureImage;
            self.videoOrientaion = UIDevice.currentDevice.orientation;
            
            //      デリゲートの存在確認後画面更新
            if ([self.delegate respondsToSelector:@selector(videoFrameUpdate:from:)]) {
                [self.delegate videoFrameUpdate:self.videoImage.CGImage from:self];
            }
        });
        
    }
}

#pragma mark - ユーティリティ

- (NSUInteger) cameraCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (NSUInteger) micCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] count];
}

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *) frontFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *) backFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (AVCaptureDevice *) audioDevice
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    if ([devices count] > 0) {
        return [devices objectAtIndex:0];
    }
    return nil;
}

#pragma mark - クラス・メソッド

//SampleBufferをCGImageRefに変換する
+ (CGImageRef) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
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
