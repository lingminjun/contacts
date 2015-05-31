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


@interface CNPerson : CNEntity

@property (nonatomic,copy) NSString *uid;//用户唯一id

@property (nonatomic,copy) NSString *name;

@property (nonatomic,copy) NSString *mobile;

@property (nonatomic) CNPersonGender gender;

@property (nonatomic,copy) NSString *pinyin;//名字拼音，多音组合

@property (nonatomic) char firstSpell;//首拼字母

@property (nonatomic,copy) NSString *homeAddress;
@property (nonatomic) float homeLongitude;//经度
@property (nonatomic) float homeLatitude;//纬度

@property (nonatomic,copy) NSString *companyAddress;
@property (nonatomic) float companyLongitude;//经度
@property (nonatomic) float companyLatitude;//纬度

@property (nonatomic) float homeDistance;

@property (nonatomic) float companyDistance;

@end
