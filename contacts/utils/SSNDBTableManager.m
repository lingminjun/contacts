//
//  SSNDBTableManager.m
//  contacts
//
//  Created by lingminjun on 15/5/29.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "SSNDBTableManager.h"
#import "CNPerson.h"

@implementation SSNDBTableManager

+ (SSNDBTable *)personTable {
    SSNDB *db = [CNUserCenter center].currentDatabase;
    if (!db) {
        return nil;
    }
    return [SSNDBTable tableWithDB:db name:NSStringFromClass([CNPerson class]) templateName:nil];
}

@end
