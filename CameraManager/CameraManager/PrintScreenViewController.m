//
//  PrintScreenViewController.m
//  CameraManager
//
//  Created by Amatsu on 2013/12/05.
//  Copyright (c) 2013年 Amatsu. All rights reserved.
//

#import "PrintScreenViewController.h"

@interface PrintScreenViewController ()<UIGestureRecognizerDelegate,UITextFieldDelegate>

@end

@implementation PrintScreenViewController

//選択中のオブジェクト名称
NSString *choiceObjNm;
//選択中のマークView
UIView *selectedMarkView;

NSString *const MARK_FUKIDASHI = @"MARK_FUKIDASHI";
NSInteger markCnt = 0;

#pragma mark - 初期化
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.printScreenImageView.image = self.printScreenImage;
    
    //タップジェスチャーを追加
    self.printScreenImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(didTapGesture:)];
    //<UIGestureRecognizerDelegate>
    //tapGesture.delegate = self;
    [self.printScreenImageView addGestureRecognizer: tapGesture];
    
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget: self action: @selector(didRotationGesture:)];
    [self.printScreenImageView addGestureRecognizer:rotationGesture];
    
    
}

#pragma mark - イベント関連
//タッチイベント
- (void)didTapGesture:(UITapGestureRecognizer*)sender {
    if (choiceObjNm == MARK_FUKIDASHI) {
        //タッチポイントに吹き出しを貼り付け
        markCnt += 1;
        CGPoint point = [sender locationInView:sender.view];
        UIView *fukidashi = [[UIView alloc] initWithFrame:CGRectMake(point.x,point.y,200,50)];
        fukidashi.layer.cornerRadius = 20;
        fukidashi.clipsToBounds = true;
        fukidashi.backgroundColor  = [UIColor blueColor];
        fukidashi.alpha  = 0.8f;
        fukidashi.tag = markCnt;
        
        //テキストフィールド追加
        UITextField *msg =[[UITextField alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
        [msg setDelegate: self];
        [fukidashi addSubview:msg];
        
        //サブビューとして追加
        [self.printScreenImageView addSubview:fukidashi];
        
        //各種ジェスチャを追加
        UITapGestureRecognizer *markTapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(didMarkTapGesture:)];
        [fukidashi addGestureRecognizer:markTapGesture];
        UIPanGestureRecognizer *markPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget: self action: @selector(didMarkPanGesture:)];
        [fukidashi addGestureRecognizer:markPanGesture];
        
        //選択なし
        choiceObjNm = nil;
    }
}

//パンイベント（ドラッグイベント）
- (void)didRotationGesture:(UIRotationGestureRecognizer*)sender {
    
    //選択中のオブジェクトが存在しない場合は何もしない。
    if (selectedMarkView == nil)
        return;
    
    //選択中のオブジェクトを回転
    selectedMarkView.transform = CGAffineTransformMakeRotation(sender.rotation);
    
    NSLog(@"printScreenImageViewのdidRotationGesture:%f",sender.rotation);
}

//選択中のオブジェクトを設定
- (void)selectedMarkObject:(UIView*)selectView {
    //選択中のオブエジェクトに枠線をつける
    if (selectedMarkView != nil) {
        [[selectedMarkView layer] setBorderWidth:0.0];
    }
    selectedMarkView = selectView;
    [[selectedMarkView layer] setBorderColor:[[UIColor whiteColor] CGColor]];
    [[selectedMarkView layer] setBorderWidth:2.0];
}
//マークタッチイベント
- (void)didMarkTapGesture:(UITapGestureRecognizer*)sender
{
    //選択中のオブジェクトを設定
    [self selectedMarkObject:sender.view];
    
    NSLog(@"吹き出しがタッチされました。%d",sender.view.tag);
}
//マークパンイベント（ドラッグ）
- (void)didMarkPanGesture:(UIPanGestureRecognizer*)sender
{

    //選択中のオブジェクトを設定
    [self selectedMarkObject:sender.view];
    
    // ドラッグで移動した距離を取得する
    CGPoint point = [sender translationInView:self.view];
	
    // 移動した距離だけ、centerポジションを移動させる
    CGPoint movedPoint = CGPointMake(sender.view.center.x + point.x, sender.view.center.y + point.y);
    sender.view.center = movedPoint;
	
    // ドラッグで移動した距離を初期化する
    // これを行わないと、[sender translationInView:]が返す距離は、ドラッグが始まってからの蓄積値となるため、
    // 今回のようなドラッグに合わせてImageを動かしたい場合には、蓄積値をゼロにする
    [sender setTranslation:CGPointZero inView:self.view];
    
    NSLog(@"吹き出しがドラッグされました。%d",sender.view.tag);
}

//キーボード非表示
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // ソフトウェアキーボードを閉じる
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//カメラ画面に戻る
- (IBAction)back:(id)sender {
    //StoryboardからViewControllerを呼び出し
    PrintScreenViewController *prtScrView = [[self storyboard] instantiateViewControllerWithIdentifier:@"MainViewController"];
    [self presentViewController:prtScrView animated:YES completion:nil];
}

//画像保存
- (IBAction)saveImage:(id)sender {
    
    //画像合成
    
    //ファイル名を設定
     [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", [self stringWithUUID]]];
    
    //アプリを使用して保存した画像と認識させるため、DBへ保存（ファイル名やコメント等の画像以外の付属情報）
    //TODO
    
    //フォトアルバムに保存
    UIImageWriteToSavedPhotosAlbum(self.printScreenImage,
                                   self,
                                   @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:), nil);
}

//一覧表示
- (IBAction)showPhotoList:(id)sender {
    //StoryboardからViewControllerを呼び出し
    PrintScreenViewController *prtScrView = [[self storyboard] instantiateViewControllerWithIdentifier:@"PhotoListTabController"];
    [self presentViewController:prtScrView animated:YES completion:nil];
}

#pragma mark - 吹出関連
//吹出を選択
- (IBAction)choiceFukidashi:(id)sender {
    choiceObjNm = MARK_FUKIDASHI;
}

//UUIDを利用しランダムのファイル名を用意
- (NSString*) stringWithUUID {
    CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID
    //get the string representation of the UUID
    NSString *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    CFRelease(uuidObj);
    return uuidString;
}


// 保存が完了したら呼ばれるメソッド
-(void)savingImageIsFinished:(UIImage*)image

    didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo{
    
    
    // Alertを表示する
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"保存しました" delegate:nil
                                          cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

/*
 * 画面回転可否
 */
- (BOOL)shouldAutorotate
{
    return YES;
}
/*
 * 画面回転をサポートする向き
 */
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

/*
 * 初期表示の画面向き
 */
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
