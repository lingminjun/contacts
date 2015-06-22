//
//  CNAddress.m
//  contacts
//
//  Created by lingminjun on 15/6/22.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNAddress.h"

@implementation CNAddress

- (id)copyWithZone:(NSZone *)zone {
    return [self ssn_copy];
}

@end
