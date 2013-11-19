//
//  BirdsMasterViewController.h
//  BirdWatching
//
//  Created by Amatsu on 13/11/18.
//  Copyright (c) 2013年 Amatsu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BirdSightingDataController;

@interface BirdsMasterViewController : UITableViewController

@property (strong,nonatomic) BirdSightingDataController *dataController;

@end
