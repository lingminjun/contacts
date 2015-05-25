//
//  HTURLDispatcher.m
//  hitaoq
//
//  Created by lingminjun on 15/5/13.
//  Copyright (c) 2015年 SSN. All rights reserved.
//

#import "CNURLDispatcher.h"

@implementation CNURLDispatcher

+ (instancetype)dispatcher {
    static CNURLDispatcher *dispatcher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatcher = [[CNURLDispatcher alloc] init];
    });
    return dispatcher;
}



#pragma mark open url delegate
//所有的分发控制
- (NSURL *)ssn_router:(SSNRouter *)router redirectURL:(NSURL *)url query:(NSDictionary *)query
{
    if ([[url scheme] isEqualToString:cn_app_schame]) {//页面跳转可进行配置
        
        NSString *latestVS = [SSNAppInfo latestLaunchAppVersion];
        NSString *currentVS = [SSNAppInfo appWholeVersion];
        if ([currentVS ssn_compareAppVersion:latestVS] == NSOrderedDescending) {//表示有更新
            [SSNAppInfo updateLaunchAppVersion];
            
            NSString *path = [NSString stringWithFormat:@"welcome?animated=NO&url=%@",[url.absoluteString ssn_urlEncode]];
            
            return [NSURL URLWithString:cn_combine_path(path)];
        }
        
        //若要去登录的
        if ([url.absoluteString isEqualToString:cn_combine_path(@"login")])
        {
            [self.ssn_router open:cn_combine_path(@"nav")];
            
            return [NSURL URLWithString:cn_combine_path(@"nav/login?root=yes")];
        }
        
        //直接进入主页
        if ([url.absoluteString isEqualToString:cn_combine_path(@"home")])
        {
        
            [self.ssn_router open:cn_combine_path(@"nav")];
            
            if (![self.ssn_router canOpenURL:[NSURL URLWithString:cn_combine_path(@"nav/main/friends")]]) {
                
                [self.ssn_router open:cn_combine_path(@"nav/main?root=yes&animated=NO")];
                
                [self.ssn_router open:cn_combine_path(@"nav/main/friends?animated=NO")];
                
                [self.ssn_router open:cn_combine_path(@"nav/main/nearby?animated=NO")];
                
                [self.ssn_router open:cn_combine_path(@"nav/main/setting?animated=NO")];
                
            }
            
            return [NSURL URLWithString:cn_combine_path(@"nav/main/friends")];
        }
    }
    
    return nil;
}


@end
