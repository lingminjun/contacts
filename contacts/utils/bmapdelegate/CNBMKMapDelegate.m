//
//  CNBMKMapDelegate.m
//  contacts
//
//  Created by lingminjun on 15/5/31.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNBMKMapDelegate.h"
#import "SSNLogger.h"
#import <BaiduMapAPI/BMapKit.h>

NSString *const BMKMapAppKey = @"Z6hpdBmTWvs7YNbzth8cUEPW";//@"CqbrjsjvEIfnRyILq9ZoiZhK";

@interface CNBMKMapDelegate () <BMKGeneralDelegate> {
    BMKMapManager* _mapManager;
}

@end


@implementation CNBMKMapDelegate

+ (instancetype)delegate {
    static CNBMKMapDelegate *delegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        delegate = [[CNBMKMapDelegate alloc] init];
    });
    return delegate;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
    }
    return self;
}

#pragma mark - 实现的协议方法
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc] init];
    BOOL ret = [_mapManager start:BMKMapAppKey generalDelegate:self];
    
    if (!ret) {
        SSNLogError(@"BMKMapManager start failed!");
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [BMKMapView willBackGround];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [BMKMapView didForeGround];
}

#pragma mark - BMKGeneralDelegate
/**
 *返回网络错误
 *@param iError 错误号
 */
- (void)onGetNetworkState:(int)iError {
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
}

/**
 *返回授权验证错误
 *@param iError 错误号 : 为0时验证通过，具体参加BMKPermissionCheckResultCode
 */
- (void)onGetPermissionState:(int)iError {
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}

@end
