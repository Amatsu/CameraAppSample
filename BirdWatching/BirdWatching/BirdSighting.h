//
//  BirdSighting.h
//  BirdWatching
//
//  Created by Amatsu on 13/11/18.
//  Copyright (c) 2013年 Amatsu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BirdSighting : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSDate *date;

- (id)initWithName:(NSString *)name
          location:(NSString *)location
              date:(NSDate *)date;

@end
