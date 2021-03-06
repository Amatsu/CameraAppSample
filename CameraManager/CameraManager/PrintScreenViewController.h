//
//  PrintScreenViewController.h
//  CameraManager
//
//  Created by Amatsu on 2013/12/05.
//  Copyright (c) 2013年 Amatsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import "PhotoListViewController.h"
#import "ThumbnailView.h"

@interface PrintScreenViewController : UIViewController{
    ALAssetsLibrary *_library;
    NSURL *_groupURL;
    NSString *_AlbumName;
    BOOL _albumWasFound;
    ThumbnailView* _fukidasiListView;
}

@property (weak, nonatomic) UIImage* printScreenImage;
@property (weak, nonatomic) IBOutlet UIScrollView *fukidashiImgListView;
@property (weak, nonatomic) IBOutlet UIImageView *printScreenImageView;
@property (weak, nonatomic) IBOutlet UIButton *btnTrash;

- (IBAction)back:(id)sender;
- (IBAction)saveImage:(id)sender;
//- (IBAction)choiceFukidashi1:(id)sender;
//- (IBAction)choiceFukidashi2:(id)sender;
//- (IBAction)choiceFukidashi3:(id)sender;
//- (IBAction)choiceFukidashi4:(id)sender;
//- (IBAction)choiceFukidashi5:(id)sender;
//- (IBAction)choiceFukidashi6:(id)sender;

@end
