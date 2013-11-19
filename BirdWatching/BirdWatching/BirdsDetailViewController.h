//
//  BirdsDetailViewController.h
//  BirdWatching
//
//  Created by Amatsu on 13/11/18.
//  Copyright (c) 2013年 Amatsu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BirdSighting;

@interface BirdsDetailViewController : UITableViewController

@property (strong,nonatomic) BirdSighting *sighting;
@property (weak, nonatomic) IBOutlet UILabel *birdNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
