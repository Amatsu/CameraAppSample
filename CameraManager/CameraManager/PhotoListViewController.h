//
//  PhotoListViewController.h
//  CameraManager
//
//  Created by Amatsu on 2014/01/04.
//  Copyright (c) 2014年 Amatsu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoListViewController : UIViewController<UITabBarDelegate>

//メニュータブバー
@property (weak, nonatomic) IBOutlet UITabBar *menuTabBar;

@end
