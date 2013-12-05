//
//  PrintScreenViewController.h
//  CameraManager
//
//  Created by Amatsu on 2013/12/05.
//  Copyright (c) 2013年 Amatsu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrintScreenViewController : UIViewController

@property (weak, nonatomic) UIImage* printScreenImage;
@property (weak, nonatomic) IBOutlet UIImageView *printScreenImageView;

@end
