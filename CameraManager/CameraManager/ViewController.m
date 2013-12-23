//
//  ViewController.m
//  CameraManager
//
//  Created by Amatsu on 2013/12/01.
//  Copyright (c) 2013年 Amatsu. All rights reserved.
//

#import "ViewController.h"
#import "PrintScreenViewController.h"

@interface ViewController ()<UIGestureRecognizerDelegate>
@end

@implementation ViewController

//拡大倍率を保持する変数
float beginGestureScale;
float effectiveScale;

#pragma mark - 初期化
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //カメラマネージャ初期化
    self.cameraManager = CameraManager.new;
    [self.cameraManager setPreview:self.photoPreview];
    
    
    //露光調整プロパティ監視
    [self.cameraManager.getInputDevice addObserver:self
             forKeyPath:@"adjustingExposure"
                options:NSKeyValueObservingOptionNew
                context:nil];
    
    //タップジェスチャーを追加
    self.photoPreview.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(didTapGesture:)];
    //<UIGestureRecognizerDelegate>
    //tapGesture.delegate = self;
    [self.photoPreview addGestureRecognizer: tapGesture];
        
    // ピンチのジェスチャーを登録する
    UIGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
    //<UIGestureRecognizerDelegate>
    recognizer.delegate = self;
    [self.photoPreview addGestureRecognizer:recognizer];
    
    //設定Viewを非表示
    [self.cameraConfigView setHidden:YES];
    
}

//露光関連
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    AVCaptureDevice *device = self.cameraManager.getInputDevice.device;
    if ([keyPath isEqual:@"adjustingExposure"]) {
        if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue] == NO) {
            NSError *error = nil;
            if ([device lockForConfiguration:&error]) {
                [device setExposureMode:AVCaptureExposureModeLocked];
                [device unlockForConfiguration];
            }
        }
    }
}

#pragma mark - イベント関連
//タッチイベント
- (void)didTapGesture:(UITapGestureRecognizer*)tgr
{
    //タッチイベントから座標を取得
    CGPoint point = [tgr locationInView:tgr.view];
    
    //カメラのフォーカスを合わせる
    [self.cameraManager autoFocusAtPoint:point];
    [self.cameraManager autoExposureAtPoint:point];
}

//ピンチイベント
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        // 適用されているスケールを覚えておく
        beginGestureScale = effectiveScale;
    }
    return YES;
}

//ピンチイベント（ズーム制御）
- (void)handlePinchFrom:(UIPinchGestureRecognizer *)recognizer
{
    // 新しく適用するスケールを計算する (適用されているスケール x 新しくピンチしたスケール)
    effectiveScale = beginGestureScale * recognizer.scale;
    [self.cameraManager setScale:effectiveScale];
}

#pragma mark - 撮影
//撮影
- (IBAction)prtScreen:(id)sender {
    
    //Storyboardから遷移先画面を呼び出し
    PrintScreenViewController *prtScrView = [[self storyboard] instantiateViewControllerWithIdentifier:@"PrintScreenViewController"];
    
    //画面の向きを設定
    self.cameraManager.videoOrientaion  = self.interfaceOrientation;
    
    //撮影
    [self.cameraManager shotPhoto:^(UIImage *image, NSError *error) {
        prtScrView.printScreenImage = image;
        [self presentViewController:prtScrView animated:YES completion:nil];
    }];
}


#pragma mark - 設定画面設定
//設定画面表示
- (IBAction)showCameraConfig:(id)sender {
    //設定Viewを表示
    [self.cameraConfigView setHidden:NO];
}

//設定画面非表示
- (IBAction)hideCameraConfig:(id)sender {
    //設定Viewを非表示
    [self.cameraConfigView setHidden:YES];
}


#pragma mark - カメラ設定
//ライト点灯/消灯
- (IBAction)toggleLight:(id)sender {
    [self.cameraManager lightToggle];
}

//メインカメラ/フェイスカメラ
- (IBAction)toggleCamera:(id)sender {
    [self.cameraManager flipCamera];
}

//シャッター音あり/シャッター音なし
- (IBAction)toggleSilentMode:(id)sender {
    [self.cameraManager silentModeToggle];
}

#pragma mark - その他画面設定
//画面回転可否
- (BOOL)shouldAutorotate {
    //許可しない。
    return NO;
}

//タブバーコントローラーの遷移イベント
//- (void) didSelect:(PhotoListTabBarController *)tabBarController {
//    [tabBarController showTabBar:NO];
//}

#pragma mark - メモリ関連
//メモリ？
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
