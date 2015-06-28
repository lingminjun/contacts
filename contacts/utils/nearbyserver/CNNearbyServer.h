//
//  CNNearbyServer.h
//  contacts
//
//  Created by lingminjun on 15/6/27.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  附近需求的服务，以朋友为数据源进行搜索
 */
@interface CNNearbyServer : NSObject

/**
 *  唯一实例
 *
 *  @return
 */
+ (instancetype)server;

/**
 *  开启服务
 */
- (void)start;

/**
 *  停止服务
 */
- (void)stop;

/**
 *  服务是否开启
 *
 *  @return 是否开始
 */
- (BOOL)isStarting;

/**
 *  刷新间隔时间
 */
@property (nonatomic) NSTimeInterval interval;

/**
 *  范围限定
 */
@property (nonatomic) double kilometers;

/**
 *  模糊匹配，名字，拼音
 */
@property (nonatomic,copy) NSString *searchText;

/**
 *  结果刷新
 */
@property (nonatomic,copy) void(^flush)(NSArray *persons,NSError *error);

@end
