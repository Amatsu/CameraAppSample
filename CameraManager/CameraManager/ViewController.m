//
//  ViewController.m
//  CameraManager
//
//  Created by Amatsu on 2013/12/01.
//  Copyright (c) 2013年 Amatsu. All rights reserved.
//

#import "ViewController.h"
#import "PrintScreenViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.cameraManager = CameraManager.new;
    [self.cameraManager setPreview:self.photoPreview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)prtScreen:(id)sender {
    
//    //StoryboardからViewControllerを呼び出し
//    PrintScreenViewController *prtScrView = [[self storyboard] instantiateViewControllerWithIdentifier:@"PrintScreenViewController"];
//    [self presentViewController:prtScrView animated:YES completion:nil];
    
    //self.prtSampleView.image = self.cameraManager.rotatedVideoImage;
    
    //StoryboardからViewControllerを呼び出し
    
    //シャッター音あり
//    [self.cameraManager takePhoto:^(UIImage *image, NSError *error) {
//        //self.prtSampleView.image = image;
//        PrintScreenViewController *prtScrView = [[self storyboard] instantiateViewControllerWithIdentifier:@"PrintScreenViewController"];
//        prtScrView.printScreenImage = image;
//        [self presentViewController:prtScrView animated:YES completion:nil];
//    }];
    
    //シャッター音なし
    PrintScreenViewController *prtScrView = [[self storyboard] instantiateViewControllerWithIdentifier:@"PrintScreenViewController"];
    prtScrView.printScreenImage = self.cameraManager.rotatedVideoImage;
    [self presentViewController:prtScrView animated:YES completion:nil];

}

@end
