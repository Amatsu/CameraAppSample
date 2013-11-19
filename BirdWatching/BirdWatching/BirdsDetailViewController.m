//
//  BirdsDetailViewController.m
//  BirdWatching
//
//  Created by Amatsu on 13/11/18.
//  Copyright (c) 2013年 Amatsu. All rights reserved.
//

#import "BirdsDetailViewController.h"
#import "BirdSighting.h"

@interface BirdsDetailViewController ()
- (void)configureView;
@end

@implementation BirdsDetailViewController

#pragma mark - Managing the detail item

- (void)setSighting:(BirdSighting *)newSighting
{
    if(_sighting != newSighting) {
        _sighting  = newSighting;
        
        //ビューを更新する
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    BirdSighting *theSighting = self.sighting;
    static NSDateFormatter *formatter = nil;
    if(formatter == nil) {
        formatter = [[NSDateFormatter alloc]init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
    }
    if(theSighting) {
        self.birdNameLabel.text  = theSighting.name;
        self.locationLabel.text = theSighting.location;
        self.dateLabel.text = [formatter stringFromDate:theSighting.date];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
