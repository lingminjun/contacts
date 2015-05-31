//
//  CNBMKMapDelegate.h
//  contacts
//
//  Created by lingminjun on 15/5/31.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

FOUNDATION_EXTERN const CLLocationCoordinate2D cn_default_location_coordinate;
FOUNDATION_EXTERN NSString *const BMKMapErrorDomain;

@interface CNBMKMapDelegate : NSObject<UIApplicationDelegate>

/**
 *  唯一实例
 *
 *  @return 地图sdk委托
 */
+ (instancetype)delegate;

#pragma mark - 实现的协议方法
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;

#pragma mark - 经纬度转化
/**
 *  地址转换成经纬度
 *
 *  @param address    地址信息
 *  @param city       城市
 *  @param completion 回调
 */
- (void)geoCodeWithAddress:(NSString *)address city:(NSString *)city completion:(void (^)(CLLocationCoordinate2D coor,NSError *error))completion;

/**
 *  坐标转化成精度
 *
 *  @param coor       坐标
 *  @param completion 回调
 */
- (void)reverseGeoCodeWithLocationCoordinate:(CLLocationCoordinate2D)coor completion:(void (^)(NSString *addr,NSString *city,NSError *error))completion;

#pragma mark - 定位服务
/**
 *  定位服务，查找当前所在位置
 *
 *  @param completion 回调
 */
- (void)locationWithCopletion:(void (^)(CLLocationCoordinate2D coor,NSError *error))completion;

@end
