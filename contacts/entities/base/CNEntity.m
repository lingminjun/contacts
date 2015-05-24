//
//  CNEntity.m
//  contacts
//
//  Created by lingminjun on 15/5/24.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNEntity.h"

@implementation CNEntity

@synthesize ssn_dbfetch_rowid = _ssn_dbfetch_rowid;


- (NSUInteger)hash {
    return self.ssn_dbfetch_rowid;
}

- (BOOL)isEqual:(CNEntity *)object {
    if (![object isKindOfClass:[CNEntity class]]) {
        return NO;
    }
    return self.ssn_dbfetch_rowid == object.ssn_dbfetch_rowid;
}

- (id)copyWithZone:(NSZone *)zone {
    return [self ssn_copy];
}

@end
