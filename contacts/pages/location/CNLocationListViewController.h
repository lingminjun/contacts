//
//  CNLocationListViewController.h
//  contacts
//
//  Created by lingminjun on 15/6/22.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNTableViewController.h"
#import "CNAddress.h"

@interface CNLocationListViewController : CNTableViewController

@property (nonatomic,copy) NSString *addrtitle;//自己命名
@property (nonatomic,copy) NSString *addrdes;//地址描述
@property (nonatomic,copy) CNAddress *addr;
@property (nonatomic) float longitude;//经度
@property (nonatomic) float latitude;//纬度

@property (nonatomic,copy) NSString *url;//请求的url，等待响应的url

@end
