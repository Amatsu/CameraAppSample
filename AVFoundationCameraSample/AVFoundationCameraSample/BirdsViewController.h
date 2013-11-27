//
//  BirdsViewController.h
//  AVFoundationCameraSample
//
//  Created by Amatsu on 13/11/26.
//  Copyright (c) 2013年 Amatsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface BirdsViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic,strong) AVCaptureSession* session;
@property (nonatomic,strong) IBOutlet UIImageView* imageView;

@end
