//
//  PhotoViewController.m
//  CameraManager
//
//  Created by Amatsu on 2014/01/16.
//  Copyright (c) 2014年 Amatsu. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)showPhoto {
    
    NSLog(@"%@",self.imageURL);
    NSURL *imageURL = (NSURL*)self.imageURL;
    
    ALAssetsLibrary *assetLibrary =  [[ALAssetsLibrary alloc] init];
    [assetLibrary assetForURL:imageURL
                  resultBlock:^(ALAsset *asset) {
                      // 結果取得時に実行されるブロック
                      ALAssetRepresentation *defaultRepresentation = [asset defaultRepresentation];
                      self.photoImageView.image = [[UIImage alloc] initWithCGImage:[defaultRepresentation fullResolutionImage]];
                  }
                 failureBlock:^(NSError *error) {
                     // 結果取得時に実行されるブロック
                 }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
