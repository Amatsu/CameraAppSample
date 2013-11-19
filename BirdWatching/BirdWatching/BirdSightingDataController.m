//
//  BirdSightingDataController.m
//  BirdWatching
//
//  Created by Amatsu on 13/11/18.
//  Copyright (c) 2013年 Amatsu. All rights reserved.
//

#import "BirdSightingDataController.h"
#import "BirdSighting.h"

@interface BirdSightingDataController()
    - (void)initializeDefaltDataList;
@end

@implementation BirdSightingDataController

- (void)initializeDefaltDataList {
    NSMutableArray *sightingList = [[NSMutableArray alloc]init];
    self.masterBirdSightingList = sightingList;
    BirdSighting *sighting;
    NSDate *today = [NSDate date];
    sighting = [[BirdSighting alloc]initWithName:@"Pigeon" location:@"Everywhere" date:today];
    [self addBirdSightingWithSighting:sighting];
}

- (void)setMasterBirdSightingList:(NSMutableArray *)newList {
    if(_masterBirdSightingList != newList) {
        _masterBirdSightingList = [newList mutableCopy];
    }
}

-(id)init {
    if (self = [super init]) {
        [self initializeDefaltDataList];
        return self;
    }
    return nil;
}

- (NSUInteger)countOfList {
    return [self.masterBirdSightingList count];
}

- (BirdSighting *)objectInListAtIndex:(NSUInteger)theIndex {
    return [self.masterBirdSightingList objectAtIndex:theIndex];
}

- (void)addBirdSightingWithSighting:(BirdSighting *)sighting {
    [self.masterBirdSightingList addObject:sighting];
}

@end
