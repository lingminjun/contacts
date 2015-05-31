//
//  AppDelegate.m
//  contacts
//
//  Created by lingminjun on 15/5/24.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "AppDelegate.h"
#import "SSNRouter+CNCategory.h"
#import "CNURLDispatcher.h"
#import "NSObject+SSNTracking.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
#ifdef DEBUG
    //追踪一下viewWillAppear
    [NSObject ssn_tracking_class:[UIViewController class] selector:@selector(viewWillAppear:)];
#endif
    
    //初始化router
    [self.ssn_router application:application didFinishLaunchingWithOptions:launchOptions];
    
    //初始化百度地图
    [[CNBMKMapDelegate delegate] application:application didFinishLaunchingWithOptions:launchOptions];
    
    //设置转发代理，控制整个应用的page调度
    self.ssn_router.delegate = [CNURLDispatcher dispatcher];
    
    //进入首页，由CNURLDispatcher决定url页面的切换
    [self.ssn_router open:@"frenz://home"];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.ssn_router application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[CNBMKMapDelegate delegate] applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[CNBMKMapDelegate delegate] applicationDidBecomeActive:application];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
