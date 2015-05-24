//
//  HTURLDispatcher.h
//  hitaoq
//
//  Created by lingminjun on 15/5/13.
//  Copyright (c) 2015年 SSN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSNRouter.h"

@interface CNURLDispatcher : NSObject<SSNRouterDelegate>

+ (instancetype)dispatcher;

@end
