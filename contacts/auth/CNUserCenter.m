//
//  CNUserCenter.m
//  contacts
//
//  Created by lingminjun on 15/5/27.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNUserCenter.h"

NSString *const CNUIDStoreKey   = @"cn.user.center.uid";

@interface CNUserCenter ()

@property (nonatomic) BOOL isSign;
@property (nonatomic,copy) NSString *uid;
@property (nonatomic,strong) CNPerson *user;

@property (nonatomic,strong) SSNDB *db;

@end


@implementation CNUserCenter

/**
 *  唯一实例
 *
 *  @return 单例
 */
+ (instancetype)center {
    static CNUserCenter *center = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[CNUserCenter alloc] init];
    });
    return center;
}

- (instancetype)init
{
    self = [super init];
    if (self) {//启动的时候读取uid情况
        self.uid = [[NSUserDefaults standardUserDefaults] stringForKey:CNUIDStoreKey];
        if ([self.uid length]) {
            _isSign = YES;
        }
    }
    return self;
}

/**
 *  当前用户的id （id唯一，自动分配）
 *
 *  @return 当前用户id
 */
- (NSString *)currentUID {
    return _uid;
}

/**
 *  当前用户
 *
 *  @return 当前用户
 */
- (CNPerson *)currentUser {
    if (_user) {
        return [_user copy];
    }
    
    if (!_isSign) {
        return nil;
    }
    
    @autoreleasepool {
        SSNDB *db = [self currentDatabase];
        Class person_class = [CNPerson class];
        SSNDBTable *tb = [SSNDBTable tableWithDB:db name:NSStringFromClass(person_class) templateName:nil];
        NSArray *list = [tb objectsWithClass:person_class forConditions:@{@"uid":_uid}];
        _user = [list firstObject];
    }
    
    return _user;
}

/**
 *  当前用户的数据库
 *
 *  @return 当前用户的数据库
 */
- (SSNDB *)currentDatabase {
    if (!_isSign) {
        return nil;
    }
    
    if (_db) {
        return _db;
    }
    
    _db = [[SSNDBPool shareInstance] dbWithScope:[_uid ssn_md5]];
    return _db;
}

/**
 *  uid生成器，暂时没有联网，为了保证uid的唯一性，uid采用设备uuid+时间+自增数组合
 *
 *  @return uid生成器
 */
+ (NSString *)uidGenerator {
    static NSString *deviceID = nil;
    static SSNSeqGen *seqGen = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIDevice *device = [UIDevice currentDevice];//创建设备对象
        NSUUID *UUID = [device identifierForVendor];
        deviceID = [UUID UUIDString];
        SSNLog(@"deviceID:%@",deviceID);
        seqGen = [[SSNSeqGen alloc] init];
    });
    
    NSString *uid = [NSString stringWithFormat:@"%@-%llx-%lx",deviceID,ssn_sec_timestamp(),[seqGen seq]];
    SSNLog(@"new uid = %@",uid);
    return uid;
}

@end
