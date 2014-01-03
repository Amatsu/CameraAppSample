//
//  PhotoListTabBarController.h
//  CameraManager
//
//  Created by Amatsu on 2013/12/15.
//  Copyright (c) 2013年 Amatsu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoListTabBarController : UITabBarController<UITabBarControllerDelegate>

- (void)showTabBar:(BOOL)show;

@end

@protocol PhotoListTabBarControllerDelegate

- (void) didSelect:(PhotoListTabBarController*) tabBarController;

@end    