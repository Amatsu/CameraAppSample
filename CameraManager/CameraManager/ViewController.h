//
//  ViewController.h
//  CameraManager
//
//  Created by Amatsu on 2013/12/01.
//  Copyright (c) 2013年 Amatsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraManager.h"

@interface ViewController : UIViewController<CameraManagerDelegate>
//,PhotoListTabBarControllerDelegate

@property CameraManager* cameraManager;
@property (weak, nonatomic) IBOutlet UIImageView *photoPreview;
@property (weak, nonatomic) IBOutlet UIView *cameraConfigView;

//フォーカスをあわせる時のフレーム
@property (nonatomic, strong) CALayer* foucusSetFrameView;

- (IBAction)prtScreen:(id)sender;
- (IBAction)showCameraConfig:(id)sender;
- (IBAction)hideCameraConfig:(id)sender;
- (IBAction)toggleLight:(id)sender;
- (IBAction)toggleCamera:(id)sender;
- (IBAction)toggleSilentMode:(id)sender;
- (IBAction)showPhotoList:(id)sender;

@end
