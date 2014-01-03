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

- (IBAction)back:(id)sender;
- (IBAction)saveImage:(id)sender;
- (IBAction)showPhotoList:(id)sender;
//- (IBAction)choiceFukidashi:(id)sender;
//- (IBAction)choiceColorRed:(id)sender;
//- (IBAction)choiceColorBlue:(id)sender;
- (IBAction)choiceFukidashi1:(id)sender;
- (IBAction)choiceFukidashi2:(id)sender;
- (IBAction)choiceFukidashi3:(id)sender;
- (IBAction)choiceFukidashi4:(id)sender;
- (IBAction)choiceFukidashi5:(id)sender;
- (IBAction)choiceFukidashi6:(id)sender;

@end
