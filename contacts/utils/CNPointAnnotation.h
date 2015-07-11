//
//  CNPointAnnotation.h
//  contacts
//
//  Created by lingminjun on 15/7/12.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import <BaiduMapAPI/BMKPointAnnotation.h>

@interface CNPointAnnotation : BMKPointAnnotation

@property (nonatomic,strong) id person;
@property (nonatomic) NSInteger index;        //编号

@end
