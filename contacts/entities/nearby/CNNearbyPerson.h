//
//  CNNearbyPerson.h
//  contacts
//
//  Created by lingminjun on 15/7/5.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CNNearbyPerson : NSObject<NSCopying>

@property (nonatomic,copy) NSString *uid;           //用户唯一id

@property (nonatomic,copy) NSString *name;          //名字

@property (nonatomic,copy) NSString *avatarURL;     //头像

@property (nonatomic,copy) NSString *mobile;        //

@property (nonatomic) CNPersonGender gender;        //性别

@property (nonatomic,copy) NSString *pinyin;        //名字拼音，多音组合
@property (nonatomic) char firstSpell;              //首拼字母

@property (nonatomic) CNAddressLabel addressLabel;  //地址类型

@property (nonatomic,copy) NSString *province;      //省
@property (nonatomic,copy) NSString *city;          //城市
@property (nonatomic,copy) NSString *region;        //区

@property (nonatomic,copy) NSString *locationPointName;//地图点名称
@property (nonatomic,copy) NSString *street;        //存储大厦，或者街道信息
@property (nonatomic,copy) NSString *addressDetail; //详情(门牌或楼层)

@property (nonatomic) float longitude;              //经度
@property (nonatomic) float latitude;               //纬度

@property (nonatomic) float distance;               //距离

@property (nonatomic) NSUInteger callTimes;          //统计亲密度，呼叫次数
@property (nonatomic) NSUInteger GPSTimes;           //统计亲密度，导航次数


@property (nonatomic) float nearbyDistance;        //附近距离计算
@property (nonatomic) NSInteger nearbyIndex;        //编号

- (NSComparisonResult)compareByNearbyDistance:(CNNearbyPerson *)other;

@end
