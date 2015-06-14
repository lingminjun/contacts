//
//  CNUserCenter.h
//  contacts
//
//  Created by lingminjun on 15/5/27.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNPerson.h"
#import "SSNDataStore.h"

FOUNDATION_EXTERN NSString *const CN_USER_AVATAR_KEY;

/**
 *  用户
 */
@interface CNUserCenter : NSObject

/**
 *  唯一实例
 *
 *  @return 单例
 */
+ (instancetype)center;

/**
 *  是否在此设备上签署 (既是否完成个人信息注册)
 *
 *  @return 是否在此设备上签署
 */
- (BOOL)isSign;

/**
 *  在此设备上签署
 *
 *  @param uid 签署uid
 *
 *  @return 操作是否成功
 */
- (BOOL)signWithUID:(NSString *)uid;

/**
 *  当前用户的id （id唯一，自动分配）
 *
 *  @return 当前用户id
 */
- (NSString *)currentUID;

/**
 *  当前用户
 *
 *  @return 当前用户
 */
- (CNPerson *)currentUser;

/**
 *  当前用户的数据库
 *
 *  @return 当前用户的数据库
 */
- (SSNDB *)currentDatabase;

/**
 *  当前用户头像存储
 *
 *  @return 头像存储
 */
- (SSNDataStore *)currentStore;

/**
 *  uid生成器，暂时没有联网，为了保证uid的唯一性，uid采用设备uuid+时间+自增数组合
 *
 *  @return uid生成器
 */
+ (NSString *)uidGenerator;

@end
