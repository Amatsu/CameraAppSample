//
//  PhotoListViewController.m
//  CameraManager
//
//  Created by Amatsu on 2014/01/04.
//  Copyright (c) 2014年 Amatsu. All rights reserved.
//

#import "PhotoListViewController.h"
#import "ViewController.h"

@interface PhotoListViewController ()

@end

@implementation PhotoListViewController

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
    
    //タブバーのデリゲート処理を設定
    self.menuTabBar.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - メニューバー
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item.tag == 1) {
        //カメラ画面呼び出し
        ViewController *cameraView = [[self storyboard] instantiateViewControllerWithIdentifier:@"MainViewController"];
        [self presentViewController:cameraView animated:YES completion:nil];
    }
}

@end
