//
//  CNDetailViewController.h
//  contacts
//
//  Created by lingminjun on 15/5/24.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNViewController.h"

FOUNDATION_EXTERN NSString *const CN_DETAIL_SET_USER_OPTION;
FOUNDATION_EXTERN NSString *const CN_DETAIL_ADD_FRIEND_OPTION;

@interface CNDetailViewController : CNViewController

@property (nonatomic,copy) NSString *option;//setuser;addfriend;
@property (nonatomic,copy) NSString *uid;//当前需要展示用户的uid

@property (nonatomic,copy) NSString *url;

@end
