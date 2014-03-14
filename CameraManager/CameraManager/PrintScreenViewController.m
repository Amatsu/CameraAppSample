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

////選択中のオブジェクト名称
//NSString *choiceObjNm;
//選択中の吹き出し
UIImageView *fukidashiView;
//選択中のマークView
UIView *selectedMarkView;

//NSString *const MARK_FUKIDASHI_1 = @"MARK_FUKIDASHI_1";
//NSString *const MARK_FUKIDASHI_2 = @"MARK_FUKIDASHI_2";
//NSString *const MARK_FUKIDASHI_3 = @"MARK_FUKIDASHI_3";
//NSString *const MARK_FUKIDASHI_4 = @"MARK_FUKIDASHI_4";
//NSString *const MARK_FUKIDASHI_5 = @"MARK_FUKIDASHI_5";
//NSString *const MARK_FUKIDASHI_6 = @"MARK_FUKIDASHI_6";

NSInteger markCnt = 0;

#pragma mark - 初期化
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //写真を表示
    self.printScreenImageView.image = self.printScreenImage;
    
    //吹き出し画像を読み込み
    NSMutableArray* imageList = [NSMutableArray array];
    for (int i=0; ; i++) {
        UIImage* image = [UIImage imageNamed:
                          [NSString stringWithFormat:@"fukidashi%d.png", i+1]];
        if (image == nil)
            break;
        
        [imageList addObject:image];
    }
    ThumbnailView* imageView = [[ThumbnailView alloc] initWithFrame:CGRectMake(0, 0, 60 * (float)imageList.count, 70)];
    imageView.imageList = imageList;
    self.fukidashiImgListView.contentSize = imageView.bounds.size;
    [self.fukidashiImgListView addSubview:imageView];
    
    //画像選択イベントを登録
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(onFukidashiTap:) name:@"FUKIDASHI_TAP" object:nil];
    
    //タップジェスチャーを追加
    self.printScreenImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(didTapGesture:)];
    [self.printScreenImageView addGestureRecognizer: tapGesture];
    //回転ジェスチャーを追加
    //UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget: self action: @selector(didRotationGesture:)];
    //[self.printScreenImageView addGestureRecognizer:rotationGesture];
    //パン（ドラッグ）ジェスチャーを追加
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanGesture:)];
    [self.printScreenImageView addGestureRecognizer:panGesture];
    //ピンチジェスチャーを追加
    //UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinchGesture:)];
    //[self.printScreenImageView addGestureRecognizer:pinchGesture];
    
    
    //アルバムを作製
    //ALAssetLibraryのインスタンスを作成
    _library = [[ALAssetsLibrary alloc] init];
    _AlbumName = @"TestAppPhoto";

    //アルバムを検索してなかったら新規作成、あったらアルバムのURLを保持
    [_library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                            usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                if (group) {
                                    if ([_AlbumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
                                        //URLをクラスインスタンスに保持
                                        _groupURL = [group valueForProperty:ALAssetsGroupPropertyURL];
                                    }
                                } else {
                                    if (_groupURL == nil) {
                                        ALAssetsLibraryGroupResultBlock resultBlock = ^(ALAssetsGroup *group) {
                                            _groupURL = [group valueForProperty:ALAssetsGroupPropertyURL];
                                        };
                                        
                                        //新しいアルバムを作成
                                        [_library addAssetsGroupAlbumWithName:_AlbumName
                                                                  resultBlock:resultBlock
                                                                 failureBlock: nil];
                                    }
                                }
                            } failureBlock:nil];
    
    
}

//吹き出しを表示
- (void)showFukidashi:(CGFloat)x y:(CGFloat)y w:(CGFloat)w h:(CGFloat)h {
    
    UIView *fukidashi = [[UIView alloc] initWithFrame:CGRectMake(x,y,w,h)];
    fukidashi.clipsToBounds = true;
    markCnt += 1;
    fukidashi.tag = markCnt;
    
    //テキストフィールド追加
    UITextField *msg =[[UITextField alloc] initWithFrame:CGRectMake(0,
                                                                    fukidashi.bounds.size.height / 2 - 30,
                                                                    fukidashi.bounds.size.width ,
                                                                    60)];
    [msg setTextAlignment:NSTextAlignmentCenter];
    [msg setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    msg.returnKeyType = UIReturnKeyDone;
    [msg setDelegate: self];
    [fukidashi addSubview:msg];
    
    //背景画像を設定
    UIImage* bgimg = fukidashiView.image;
    UIGraphicsBeginImageContext(fukidashi.bounds.size);
    [bgimg drawInRect:fukidashi.bounds];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    fukidashi.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    msg.textColor = [UIColor blackColor];
    fukidashi.alpha  = 0.8;
    
    //サブビューとして追加
    [self.printScreenImageView addSubview:fukidashi];
    
    //各種ジェスチャを追加
    UITapGestureRecognizer *markTapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(didMarkTapGesture:)];
    [fukidashi addGestureRecognizer:markTapGesture];
    UIPanGestureRecognizer *markPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget: self action: @selector(didMarkPanGesture:)];
    [fukidashi addGestureRecognizer:markPanGesture];
    
    //選択なし
    fukidashiView = nil;
}

#pragma mark - イベント関連
//タッチイベント
- (void)didTapGesture:(UITapGestureRecognizer*)sender {
    if (fukidashiView != nil) {
        //タッチポイントに吹き出しを貼り付け
        markCnt += 1;
        CGPoint point = [sender locationInView:sender.view];
        //吹き出しを表示
        [self showFukidashi:point.x y:point.y w:200 h:80];
    }
}

//回転イベント
//- (void)didRotationGesture:(UIRotationGestureRecognizer*)sender {
//    
//    //選択中のオブジェクトが存在しない場合は何もしない。
//    if (selectedMarkView == nil)
//        return;
//    
//    //選択中のオブジェクトを回転
//    selectedMarkView.transform = CGAffineTransformRotate(selectedMarkView.transform,sender.rotation);
//    NSLog(@"printScreenImageViewのdidRotationGesture:%f",sender.rotation);
//    
//    //ラジアンを初期化
//    [sender setRotation:0.0];
//}

//ピンチイベント
//CGAffineTransform currentTransForm;
//- (void)didPinchGesture:(UIPinchGestureRecognizer*)sender {
//    
//    //選択中のオブジェクトが存在しない場合は何もしない。
//    if (selectedMarkView == nil)
//        return;
//    
//    // ピンチジェスチャー発生時に、アフィン変形の状態を保存する
//    if (sender.state == UIGestureRecognizerStateBegan) {
//        currentTransForm = selectedMarkView.transform;
//    }
//	
//    // ピンチジェスチャー発生時から、どれだけ拡大率が変化したかを取得する
//    // 2本の指の距離が離れた場合には、1以上の値、近づいた場合には、1以下の値が取得できる
//    CGFloat scale = [sender scale];
//    
//    // ピンチジェスチャー開始時からの拡大率の変化を、imgViewのアフィン変形の状態に設定する事で、拡大する。
//    selectedMarkView.transform = CGAffineTransformConcat(currentTransForm, CGAffineTransformMakeScale(scale, scale));
//}

//ドラッグイベント
CGPoint lastTouchPoint;
- (void)didPanGesture:(UIPanGestureRecognizer*)sender {
    
    if (fukidashiView != nil) {
       
        //タッチ座標を取得
        CGPoint point = [sender locationInView:self.view];
        
        
        if (sender.state == UIGestureRecognizerStateBegan){
            lastTouchPoint = point;
            UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(point.x,
                                                                       point.y,
                                                                       fabsf([sender translationInView:sender.view].x),
                                                                       fabsf([sender translationInView:sender.view].y))];
            [self.printScreenImageView addSubview:tmpView];
            [self selectedMarkObject:tmpView];
            
        } else if (sender.state == UIGestureRecognizerStateEnded) {
            
            //サイズ確認用に一時作成したtmpViewフレームを削除
            if (selectedMarkView != nil) {
                [selectedMarkView removeFromSuperview];
            }
            
            //吹き出しの設置座業を算出
            float x = lastTouchPoint.x;
            float y = lastTouchPoint.y;
            if (point.x < x)
                x = point.x;
            if (point.y < y)
                y = point.y;
            
            //吹き出しを表示
            [self showFukidashi:x y:y w:fabsf([sender translationInView:sender.view].x) h:fabsf([sender translationInView:sender.view].y)];
            
        } else {
            //吹き出しの設置座業を算出
            float x = lastTouchPoint.x;
            float y = lastTouchPoint.y;
            if (point.x < x)
                x = point.x;
            if (point.y < y)
                y = point.y;
            selectedMarkView.frame = CGRectMake(x,
                                                y,
                                                fabsf([sender translationInView:sender.view].x),
                                                fabsf([sender translationInView:sender.view].y));
        }
        
    }else {
        
        //選択中のオブジェクトが存在しない場合は何もしない。
        if (selectedMarkView == nil)
            return;

        //原点　viewの中心
        CGPoint markPoint = selectedMarkView.center;
        //NSLog(@"オブジェクト座標 x：%f　y：%f", markPoint.x, markPoint.y);

        //タッチ座標を取得
        CGPoint point = [sender locationInView:self.view];

        if (sender.state == UIGestureRecognizerStateBegan)
            lastTouchPoint = point;
            
        //NSLog(@"最終タッチ座標 x：%f　y：%f", lastTouchPoint.x, lastTouchPoint.y);
        //NSLog(@"タッチ座標 x：%f　y：%f", point.x, point.y);

        //座標の差を求める
        //x,yに対して変化が大きい方を回転率として採用
        float x = point.x - lastTouchPoint.x;
        if (markPoint.y < point.y) {
            x *= -1;
        }
        float y = point.y - lastTouchPoint.y;
        if (markPoint.x > point.x) {
            y *= -1;
        }
        float rotation;
        if (fabs(x) > fabs(y))
            rotation = x * 0.01;
        else
            rotation = y * 0.01;

        //変化した値分回転
        selectedMarkView.transform = CGAffineTransformRotate(selectedMarkView.transform,rotation);

        //最終タッチ座標を保持
        lastTouchPoint = point;

        //累積値を初期化
        [sender setTranslation:CGPointZero inView:self.view];
    }
}

//選択中のオブジェクトを設定
- (void)selectedMarkObject:(UIView*)selectView {
    
    //選択中のオブエジェクトに枠線をつける
    if (selectedMarkView != nil) {
        [[selectedMarkView layer] setBorderWidth:0.0];
    }
    
    if (selectView != nil) {
        selectedMarkView = selectView;
        [[selectedMarkView layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[selectedMarkView layer] setBorderWidth:2.0];
    }
}
//マークタッチイベント
- (void)didMarkTapGesture:(UITapGestureRecognizer*)sender
{
    //選択中のオブジェクトを設定
    [self selectedMarkObject:sender.view];
    
    //NSLog(@"吹き出しがタッチされました。%d",sender.view.tag);
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
    
    //NSLog(@"吹き出しがドラッグされました。%d",sender.view.tag);
    
    //イベント終了時にゴミ箱Viewに重なっている場合は選択されているViewを削除する。
    if (sender.state == UIGestureRecognizerStateEnded) {
        //NSLog(@"selectedMarkView:%@",NSStringFromCGRect(selectedMarkView.frame));
        //NSLog(@"trashImgView:%@",NSStringFromCGRect(self.trashImgView.frame));
        CGRect checkFrame = CGRectMake(selectedMarkView.frame.origin.x + selectedMarkView.frame.size.width / 2,
                                       selectedMarkView.frame.origin.y + selectedMarkView.frame.size.height / 2,
                                       50,
                                       50);
        
        //ゴミ箱に移動されたかを判定
        if (CGRectIntersectsRect(checkFrame, self.btnTrash.frame)){
            //ゴミ箱に重なったので該当レイヤを削除し、選択オブジェクトを破棄
            [selectedMarkView removeFromSuperview];
            [self selectedMarkObject:nil];
            //NSLog(@"重なりを検出しました。");
        }
    }
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
    
    //オブジェクトの選択を解除
    [self selectedMarkObject:nil];
    
    //UIviewを画像として取得
    UIImage* img = [self convertUIImage:self.printScreenImageView];
    
    //コメントを取得
    NSString* cmt = @"";
    for (NSObject *obj in self.printScreenImageView.subviews) {
        //UIViewか？
        if([obj isMemberOfClass:[UIView class]]){
            UIView* markView = (UIView*)obj;
            for (NSObject *textObj in markView.subviews) {
                
                //UITextFieldか？
                if([textObj isMemberOfClass:[UITextField class]]){
                    
                    UITextField* markTxt = (UITextField*)textObj;
                    cmt = [NSString stringWithFormat:@"%@ %@",cmt,markTxt.text];
                }
            }
        }
    }
    
    //画像のExif情報を付与して保存
    NSMutableDictionary *metadata;
    metadata = [[NSMutableDictionary alloc]init];
    
    // コメントをExif情報として設定
    NSDictionary *exif = [NSDictionary dictionaryWithObjectsAndKeys:
                          cmt,
                          (NSString*)kCGImagePropertyExifUserComment,
                          nil];
    [metadata setObject:exif
                 forKey:(NSString*)kCGImagePropertyExifDictionary];
    
    //ファイル名を設定
    //[UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", [self stringWithUUID]]];
    
    //カメラロールにUIImageを保存する。保存完了後、completionBlockで「NSURL* assetURL」が取得できる
    [_library writeImageToSavedPhotosAlbum:img.CGImage
                                  metadata:metadata
                           completionBlock:^(NSURL* assetURL, NSError* error) {
                               //アルバムにALAssetを追加するメソッド
                               [self addAssetURL:assetURL
                                        AlbumURL:_groupURL];
                               NSLog(@"%@",assetURL);
                           }];
    
}

//アルバムにALAssetを追加するメソッド
- (void)addAssetURL:(NSURL*)assetURL AlbumURL:(NSURL *)albumURL{
    
    //URLからGroupを取得
    [_library groupForURL:albumURL
              resultBlock:^(ALAssetsGroup *group){
                  //URLからALAssetを取得
                  [_library assetForURL:assetURL
                            resultBlock:^(ALAsset *asset) {
                                if (group.editable) {
                                    //GroupにAssetを追加
                                    [group addAsset:asset];
                                    
                                    //一覧を表示
                                    PhotoListViewController *photoListView = [[self storyboard] instantiateViewControllerWithIdentifier:@"PhotoListViewController"];
                                    [self presentViewController:photoListView animated:YES completion:nil];
                                    
                                }
                            } failureBlock: nil];
              } failureBlock:nil];
}

//画像合成
//- (UIImage*)createPhotoImage:(UIView*)view {
//    
//    // グラフィックスコンテキストを作る
//    UIGraphicsBeginImageContext(view.bounds.size);
//    
//    //メイン画面を描画
//    UIImage *mainImg = [self convertUIImage:view];
//    CGRect rect;
//    rect.origin = CGPointZero;
//    rect.size = mainImg.size;
//    [mainImg drawInRect:rect];
//    
//    //subviewをすべて合成
//    NSArray* subViews = [view subviews];
//    for (UIView *sv in subViews) {
//        
//        //subViewをUIImageに変換し描画
//        UIImage *subImg = [self convertUIImage:sv];
//        
//        //重ね合わせる画像を描画
//        rect.origin = sv.frame.origin;
//        rect.size = subImg.size;
//        [subImg drawInRect:rect];
//    }
//    
//    // 描画した画像を取得する
//    UIImage* img;
//    img = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return img;
//}

//UIViewからUIImageに変換
-(UIImage*)convertUIImage:(UIView*)view {
    
    //ViewをUIImageに変換し描画
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

//UUIDを利用しランダムのファイル名を用意
//- (NSString*) stringWithUUID {
//    CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID
//    //get the string representation of the UUID
//    NSString *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
//    CFRelease(uuidObj);
//    return uuidString;
//}


//一覧へ遷移
//- (IBAction)showPhotoList:(id)sender {
//    //StoryboardからViewControllerを呼び出し
//    PrintScreenViewController *prtScrView = [[self storyboard] instantiateViewControllerWithIdentifier:@"PhotoListViewController"];
//    [self presentViewController:prtScrView animated:YES completion:nil];
//}


//#pragma mark - 吹出関連
//- (IBAction)choiceFukidashi1:(id)sender {
//    choiceObjNm = MARK_FUKIDASHI_1;
//}
//
//- (IBAction)choiceFukidashi2:(id)sender {
//    choiceObjNm = MARK_FUKIDASHI_2;
//}
//
//- (IBAction)choiceFukidashi3:(id)sender {
//    choiceObjNm = MARK_FUKIDASHI_3;
//}
//
//- (IBAction)choiceFukidashi4:(id)sender {
//    choiceObjNm = MARK_FUKIDASHI_4;
//}
//
//- (IBAction)choiceFukidashi5:(id)sender {
//    choiceObjNm = MARK_FUKIDASHI_5;
//}
//
//- (IBAction)choiceFukidashi6:(id)sender {
//    choiceObjNm = MARK_FUKIDASHI_6;
//}


# pragma mark - ScrollView Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint locationPoint = [[touches anyObject] locationInView:self.view];
    NSLog(@"touchesBegan = %lf,%lf\n", locationPoint.x, locationPoint.y);
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint locationPoint = [[touches anyObject] locationInView:self.view];
    NSLog(@"touchesEnded = %lf,%lf\n", locationPoint.x, locationPoint.y);
}

// 通知と値を受けるhogeメソッド
-(void)onFukidashiTap:(NSNotification *)notification{
    // 通知の送信側から送られた値を取得する
    UIImageView *iv = (UIImageView *)[notification object];
    fukidashiView = iv;
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
