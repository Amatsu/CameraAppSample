//
//  PrintScreenViewController.m
//  CameraManager
//
//  Created by Amatsu on 2013/12/05.
//  Copyright (c) 2013年 Amatsu. All rights reserved.
//

#import "PrintScreenViewController.h"

@interface PrintScreenViewController ()

@end

@implementation PrintScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.printScreenImageView.image = self.printScreenImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    //StoryboardからViewControllerを呼び出し
    PrintScreenViewController *prtScrView = [[self storyboard] instantiateViewControllerWithIdentifier:@"MainViewController"];
    [self presentViewController:prtScrView animated:YES completion:nil];
}
@end
