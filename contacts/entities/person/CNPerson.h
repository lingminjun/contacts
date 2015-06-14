//
//  CNPerson.h
//  contacts
//
//  Created by lingminjun on 15/5/24.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNEntity.h"

typedef NS_ENUM(NSUInteger, CNPersonGender) {
    CNPersonMaleGender,
    CNPersonFemaleGender,
};

//地址标签
typedef NS_ENUM(NSUInteger, CNAddressLabel) {
    CNHomeAddressLabel,
    CNCompanyAddressLabel,
};


@interface CNPerson : CNEntity

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
@property (nonatomic,copy) NSString *street;        //存储大厦，或者街道信息
@property (nonatomic,copy) NSString *addressDetail; //详情

@property (nonatomic) float longitude;              //经度
@property (nonatomic) float latitude;               //纬度

@property (nonatomic) float distance;               //距离

@property (nonatomic) NSUInteger callTimes;          //统计亲密度，呼叫次数
@property (nonatomic) NSUInteger GPSTimes;           //统计亲密度，导航次数

- (NSString *)addressCityDisplay;

@end
