//
//  PhotoListTabBarController.m
//  CameraManager
//
//  Created by Amatsu on 2013/12/15.
//  Copyright (c) 2013年 Amatsu. All rights reserved.
//

#import "PhotoListTabBarController.h"

@interface PhotoListTabBarController ()
@end

@implementation PhotoListTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // 自分自身をデリゲートに設定
    self.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    // プロトコルを実装しているかのチェック
    if ([viewController conformsToProtocol:@protocol(PhotoListTabBarControllerDelegate)]) {
        // 各UIViewControllerのデリゲートメソッドを呼ぶ
        [(UIViewController<PhotoListTabBarControllerDelegate>*)viewController didSelect:self];
    }
    
}

- (void)showTabBar:(BOOL)show
{
    UITabBar* tabBar = self.tabBar;
    if (show != tabBar.hidden)
        return;
    // This relies on the fact that the content view is the first subview
    // in a UITabBarController's normal view, and so is fragile in the face
    // of updates to UIKit.
    UIView* subview = (self.view.subviews)[0];
    CGRect frame = subview.frame;
    if (show) {
        frame.size.height -= tabBar.frame.size.height;
    } else {
        frame.size.height += tabBar.frame.size.height;
    }
    subview.frame = frame;
    tabBar.hidden = !show;

}

/*
 * 画面回転可否
 */
#define ORIENTATION [[UIDevice currentDevice] orientation]
- (BOOL)shouldAutorotate
{
    //許可しない。
    return NO;
}


@end
