//
//  BirdSighting.m
//  BirdWatching
//
//  Created by Amatsu on 13/11/18.
//  Copyright (c) 2013年 Amatsu. All rights reserved.
//

#import "BirdSighting.h"

@implementation BirdSighting
- (id)initWithName:(NSString *)name location:(NSString *)location date:(NSDate *)date {
    self = [super init];
    if(self) {
        _name = name;
        _location = location;
        _date = date;
        return self;
    }
    return nil;
}
@end
