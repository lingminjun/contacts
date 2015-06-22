//
//  CNLocationListViewController.m
//  contacts
//
//  Created by lingminjun on 15/6/22.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNLocationListViewController.h"

@implementation CNLocationListViewController

#pragma mark - page url
//是否可以响应，默认返回NO，已存在界面如果可以响应，将重新被打开
- (BOOL)ssn_canRespondURL:(NSURL *)url query:(NSDictionary *)query {
    return YES;
}

- (void)ssn_handleOpenURL:(NSURL *)url query:(NSDictionary *)query {
    self.addrtitle = [query objectForKey:@"addrtitle"];
    self.addrdes = [query objectForKey:@"addrdes"];
    self.addr = [query objectForKey:@"addr"];
    self.longitude = [[query objectForKey:@"longitude"] floatValue];//经度
    self.latitude = [[query objectForKey:@"latitude"] floatValue];//纬度
    self.url = [[query objectForKey:@"url"] ssn_urlDecode];
}


@end
