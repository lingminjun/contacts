//
//  CNLocationViewController.h
//  contacts
//
//  Created by baidu on 13-4-15.
//  Copyright (c) 2013年 baidu. All rights reserved.
//
#import "CNViewController.h"

@interface CNLocationViewController :  CNViewController

@property (nonatomic,copy) NSString *addrtitle;
@property (nonatomic,copy) NSString *address;
@property (nonatomic) float longitude;//经度
@property (nonatomic) float latitude;//纬度

@property (nonatomic,copy) NSString *url;//请求的url，等待响应的url

@end

