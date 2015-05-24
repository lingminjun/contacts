//
//  SSNRouter+CNCategory.h
//  hitaoq
//
//  Created by lingminjun on 15/5/13.
//  Copyright (c) 2015年 SSN. All rights reserved.
//

#import "SSNRouter.h"

FOUNDATION_EXTERN NSString *const cn_app_schame;

@interface SSNRouter (CNCategory)<UIApplicationDelegate>

//初始化
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

//外部或者内部跳转捕获
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end
