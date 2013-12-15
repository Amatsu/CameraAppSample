//
//  PrintScreenViewController.m
//  CameraManager
//
//  Created by Amatsu on 2013/12/05.
//  Copyright (c) 2013年 Amatsu. All rights reserved.
//

#import "PrintScreenViewController.h"

@interface PrintScreenViewController ()

@end

@implementation PrintScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.printScreenImageView.image = self.printScreenImage;
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
    
    //ファイル名を設定
     [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", [self stringWithUUID]]];
    
    //アプリを使用して保存した画像と認識させるため、DBへ保存（ファイル名やコメント等の画像以外の付属情報）
    //TODO
    
    //フォトアルバムに保存
    UIImageWriteToSavedPhotosAlbum(self.printScreenImage,
                                   self,
                                   @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:), nil);
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

@end
