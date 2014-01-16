//
//  PhotoListTableViewController.h
//  CameraManager
//
//  Created by Amatsu on 2014/01/16.
//  Copyright (c) 2014年 Amatsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import "PhotoListCell.h"
#import "PhotoViewController.h"

@interface PhotoListTableViewController : UITableViewController{
    ALAssetsLibrary *_library;
    NSURL *_groupURL;
    NSString *_AlbumName;
    NSMutableArray *_AlAssetsArr;
}


@end
