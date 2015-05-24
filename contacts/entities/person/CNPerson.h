//
//  CNPerson.h
//  contacts
//
//  Created by lingminjun on 15/5/24.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNEntity.h"

@interface CNPerson : CNEntity

@property (nonatomic,copy) NSString *uid;//用户唯一id

@property (nonatomic,copy) NSString *name;

@property (nonatomic,copy) NSString *mobile;

@property (nonatomic) NSInteger gender;

@property (nonatomic,copy) NSString *pinyin;//名字拼音，多音组合

@property (nonatomic) char firstSpell;//首拼字母

@property (nonatomic,copy) NSString *homeAddress;

@property (nonatomic,copy) NSString *companyAddress;

@end
