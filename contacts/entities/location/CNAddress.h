//
//  CNAddress.h
//  contacts
//
//  Created by lingminjun on 15/6/22.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import <Foundation/Foundation.h>

///此类表示地址结果的层次化信息
@interface CNAddress : NSObject <NSCopying>

/// 街道号码
@property (nonatomic, copy) NSString* streetNumber;
/// 街道名称
@property (nonatomic, copy) NSString* streetName;
/// 区县名称
@property (nonatomic, copy) NSString* district;
/// 城市名称
@property (nonatomic, copy) NSString* city;
/// 省份名称
@property (nonatomic, copy) NSString* province;

@end
