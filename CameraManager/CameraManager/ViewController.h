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

@property CameraManager* cameraManager;
@property (weak, nonatomic) IBOutlet UIImageView *photoPreview;
@property (weak, nonatomic) IBOutlet UIImageView *prtSampleView;

//フォーカスをあわせる時のフレーム
@property (nonatomic, strong) CALayer* foucusSetFrameView;

- (IBAction)prtScreen:(id)sender;

@end
