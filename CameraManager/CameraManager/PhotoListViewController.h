//
//  PhotoListViewController.h
//  CameraManager
//
//  Created by Amatsu on 2014/01/04.
//  Copyright (c) 2014年 Amatsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "PhotoListCell.h"

@interface PhotoListViewController : UIViewController<UITabBarDelegate,UITableViewDelegate, UITableViewDataSource> {
    ALAssetsLibrary *_library;
    NSURL *_groupURL;
    NSString *_AlbumName;
    NSMutableArray *_AlAssetsArr;
}

//メニュータブバー
@property (weak, nonatomic) IBOutlet UITabBar *menuTabBar;
@property (weak, nonatomic) IBOutlet UITableView *photoListTableView;

@end
