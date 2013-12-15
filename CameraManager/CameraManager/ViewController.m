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

float beginGestureScale;
float effectiveScale;

//フォーカスをあわせるときのフレームサイズ
#define INDICATOR_RECT_SIZE 50.0

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.cameraManager = CameraManager.new;
    [self.cameraManager setPreview:self.photoPreview];
    
    //フォーカス調整フレームを追加
    self.foucusSetFrameView = [CALayer layer];
    self.foucusSetFrameView.borderColor = [[UIColor whiteColor] CGColor];
    self.foucusSetFrameView.borderWidth = 1.0;
    self.foucusSetFrameView.frame = CGRectMake(self.view.bounds.size.width/2.0 - INDICATOR_RECT_SIZE/2.0,
                                               self.view.bounds.size.height/2.0 - INDICATOR_RECT_SIZE/2.0,
                                               INDICATOR_RECT_SIZE,
                                               INDICATOR_RECT_SIZE);
    self.foucusSetFrameView.hidden = YES;
    [self.photoPreview.layer addSublayer:self.foucusSetFrameView];
    
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
    
    // 初期のスケールを設定する
    effectiveScale = 1.0;
    // ピンチのジェスチャーを登録する
    UIGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
    //<UIGestureRecognizerDelegate>
    recognizer.delegate = self;
    [self.photoPreview addGestureRecognizer:recognizer];
    
}

//タブバーコントローラーの遷移イベント
- (void) didSelect:(PhotoListTabBarController *)tabBarController {
    [tabBarController showTabBar:NO];
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

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    // gestureをセットしたview以外がタッチされた場合はgestureを無視
//    if (touch.view != self.photoPreview)
//    {
//        return false;
//    }
//    return true;
//}

- (void)didTapGesture:(UITapGestureRecognizer*)tgr
{
    //タッチイベントから座標を取得
    CGPoint point = [tgr locationInView:tgr.view];
    
    //1) 0.0〜1.0 に正規化した値
    //(2) ランドスケープ（横向き/ホームボタン右）の時の左上を原点とする座標系
    CGSize viewSize = self.cameraManager.previewLayer.bounds.size;
    CGPoint pointOfInterest = CGPointMake(point.y / viewSize.height,
                                          1.0 - point.x / viewSize.width);
    
    self.foucusSetFrameView.frame = CGRectMake(point.x - INDICATOR_RECT_SIZE/2.0,
                                               point.y - INDICATOR_RECT_SIZE/2.0,
                                               INDICATOR_RECT_SIZE,
                                               INDICATOR_RECT_SIZE);
    self.foucusSetFrameView.hidden = NO;
    
    //点滅アニメーション
    [self blinkImage:self.foucusSetFrameView];
    
    //カメラのフォーカスを合わせる
    [self.cameraManager autoFocusAtPoint:pointOfInterest];
    [self.cameraManager autoExposureAtPoint:pointOfInterest];
}

//ピンチアクション中のデリゲート
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//点滅アニメーション
- (void)blinkImage:(CALayer *)target {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 1.0f;
    animation.repeatCount = HUGE_VAL;
    animation.values = [[NSArray alloc] initWithObjects:
                        [NSNumber numberWithFloat:1.0f],
                        [NSNumber numberWithFloat:0.0f],
                        [NSNumber numberWithFloat:1.0f],
                        nil];
    animation.repeatCount = 1;
    animation.delegate = self;
    [target addAnimation:animation forKey:@"blink"];

    
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.foucusSetFrameView.hidden = YES;
}


//撮影
- (IBAction)prtScreen:(id)sender {
    
    //StoryboardからViewControllerを呼び出し
    PrintScreenViewController *prtScrView = [[self storyboard] instantiateViewControllerWithIdentifier:@"PrintScreenViewController"];
    
    //シャッター音あり
    //[self.cameraManager takePhoto:^(UIImage *image, NSError *error) {
    //    //self.prtSampleView.image = image;
    //    prtScrView.printScreenImage = image;
    //    [self presentViewController:prtScrView animated:YES completion:nil];
    //}];
    
    //シャッター音なし
    prtScrView.printScreenImage = self.cameraManager.rotatedVideoImage;
    [self presentViewController:prtScrView animated:YES completion:nil];

}

@end
