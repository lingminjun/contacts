//
//  CNBMKMapDelegate.h
//  contacts
//
//  Created by lingminjun on 15/5/31.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import <UIKit/UIKit.h>

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

@end
