//
//  CNLocationPoint.h
//  contacts
//
//  Created by lingminjun on 15/6/22.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CNLocationPoint : NSObject<NSCopying>

///POI名称
@property (nonatomic, copy) NSString* name;
///POIuid
@property (nonatomic, copy) NSString* uid;
///POI地址
@property (nonatomic, copy) NSString* address;
///POI所在城市
@property (nonatomic, copy) NSString* city;
///POI电话号码
@property (nonatomic, copy) NSString* phone;
///POI邮编
@property (nonatomic, copy) NSString* postcode;
///POI类型，0:普通点 1:公交站 2:公交线路 3:地铁站 4:地铁线路
@property (nonatomic) int epoitype;
///POI坐标
@property (nonatomic) CLLocationCoordinate2D pt;

@end
