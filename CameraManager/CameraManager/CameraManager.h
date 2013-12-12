//
//  CameraManager.h
//  CameraManager
//
//  Created by Amatsu on 2013/12/01.
//  Copyright (c) 2013年 Amatsu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMBufferQueue.h>

@class CameraManager;
@protocol CameraManagerDelegate <NSObject>
@optional

-(void)videoFrameUpdate:(CGImageRef)cgImage from:(CameraManager*)manager;
                          
@end

@interface CameraManager : NSObject<AVCaptureAudioDataOutputSampleBufferDelegate,
                                    AVCaptureVideoDataOutputSampleBufferDelegate>

/*///////////////////////////////////////////
 初期化
 presetに以下の値を設定して初期化(デフォルトは1280x720)
 AVCaptureSessionPresetLow
 AVCaptureSessionPresetHigh
 AVCaptureSessionPresetMedium
 AVCaptureSessionPresetPhoto
 AVCaptureSessionPreset352x288
 AVCaptureSessionPreset640x480
 AVCaptureSessionPreset1920x1080
 AVCaptureSessionPresetiFrame960x540
 AVCaptureSessionPresetiFrame1280x720
 /////////////////////////////////////////////*/

- (id)init;
- (id)initWithPreset:(NSString *)preset;

@property (nonatomic,assign) id <CameraManagerDelegate> delegate;

- (AVCaptureDeviceInput *) getInputDevice;

//--------------------------------
//プレビュー制御
//--------------------------------
//プレビューレイヤを直接設定できます
//表示の ON/OFFは　previewLayer.hidden = YES/NO
@property AVCaptureVideoPreviewLayer* previewLayer;
- (void)setPreview:(UIView *) view;

//-------------------------------
//ライト制御
//-------------------------------
//yes:ライト点灯 no:ライト消灯
- (void)light:(BOOL)yesno;
//ライト制御反転
- (void)lightToggle;
//ライト点灯確認
//YES:点灯 NO:消灯
- (BOOL)isLightOn;

//-------------------------------
//カメラ制御
//-------------------------------
//yes:フロントカメラ no:バックカメラ
- (void)useFrontCamera:(BOOL)yesno;
//フロントカメラとバックカメラを切り替え
- (void)flipCamera;
//YES:フロントカメラを使用中 NO:バックカメラを使用中
- (BOOL)isUsingFrontCamera;

//バックカメラデバイス取得
@property AVCaptureDevice* backCameraDevice;
//フロントカメラデバイス取得
@property AVCaptureDevice* frontCameraDevice;

//------------------------------
//フォーカス制御
//------------------------------
- (void)autoFocusAtPoint:(CGPoint)point;
- (void)continuousFocusAtPoint:(CGPoint)point;

//------------------------------
//露光制御
//------------------------------
- (void)autoExposureAtPoint:(CGPoint)point;

//------------------------------
//カメラ撮影
//------------------------------
typedef void (^takePhotoBlock)(UIImage *image, NSError *error);
-(void)takePhoto:(takePhotoBlock) block;

//------------------------------
//撮影制御
//------------------------------
@property UIImage* videoImage;
@property UIDeviceOrientation videoOrientaion;

//------------------------------
//ズーム制御
//------------------------------
-(void)setScale:(CGFloat)scale;

//静止画取得
- (UIImage*)rotatedVideoImage;

//------------------------------
//公開メソッド
//------------------------------
//SampleBuffer ->　CGImageRef変換
//画像回転
+ (CGImageRef) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
+ (UIImage*)rotateImage:(UIImage*)img angle:(int)angle;

@end
