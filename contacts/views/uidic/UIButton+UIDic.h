//
//  UIButton+UIDic.h
//  contacts
//
//  Created by lingminjun on 15/6/9.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (UIDic)

/**
 *  普通button，size:300x40
 *
 *  @return size:300x40
 */
+ (instancetype)cn_normal_button;


/**
 *  done button，size:50x30
 *
 *  @return size:50x30
 */
+ (instancetype)cn_done_button;


/**
 *  done button，size:90x30
 *
 *  @return size:90x30
 */
+ (instancetype)cn_location_button;

@end
