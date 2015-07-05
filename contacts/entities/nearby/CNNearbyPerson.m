//
//  CNNearbyPerson.m
//  contacts
//
//  Created by lingminjun on 15/7/5.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNNearbyPerson.h"

@implementation CNNearbyPerson

- (id)copyWithZone:(NSZone *)zone {
    return [self ssn_copy];
}


- (NSComparisonResult)compareByNearbyDistance:(CNNearbyPerson *)other {
    if (self.nearbyDistance > other.nearbyDistance) {
        return NSOrderedDescending;
    }
    else if (self.nearbyDistance < other.nearbyDistance) {
        return NSOrderedAscending;
    }
    else {
        return NSOrderedSame;
    }
}

@end
