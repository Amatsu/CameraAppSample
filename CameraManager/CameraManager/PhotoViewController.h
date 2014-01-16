//
//  PhotoViewController.h
//  CameraManager
//
//  Created by Amatsu on 2014/01/16.
//  Copyright (c) 2014年 Amatsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoViewController : UIViewController

@property (weak,nonatomic) NSURL *imageURL;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

- (void)showPhoto;

@end
