//
//  BirdSightingDataController.h
//  BirdWatching
//
//  Created by Amatsu on 13/11/18.
//  Copyright (c) 2013年 Amatsu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BirdSighting;
@interface BirdSightingDataController : NSObject

@property (nonatomic, copy) NSMutableArray *masterBirdSightingList;
- (NSUInteger)countOfList;
- (BirdSighting * )objectInListAtIndex:(NSUInteger)theIndex;
- (void)addBirdSightingWithSighting:(BirdSighting *)sighting;
@end
