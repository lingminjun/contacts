//
//  CNNearbyServer.m
//  contacts
//
//  Created by lingminjun on 15/6/27.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNNearbyServer.h"
#import <BaiduMapAPI/BMapKit.h>
#import "CNBMKMapDelegate.h"
#import "SSNDBTableManager.h"
#import "CNPerson.h"

#define CN_NEARLY_MIN_INTERVAL  5
#define CN_NEARLY_MAX_INTERVAL  (5*60)

#define CN_NEARLY_MIN_KILOMETERS  0.5
#define CN_NEARLY_MAX_KILOMETERS  500

@interface CNNearbyServer ()

@property (nonatomic,strong) NSTimer *timer;//循环引用，因为是单例，无所谓

@end

@implementation CNNearbyServer

/**
 *  唯一实例
 *
 *  @return 地图sdk委托
 */
+ (instancetype)server {
    static CNNearbyServer *server = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        server = [[CNNearbyServer alloc] init];
    });
    return server;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _interval = 30;//一分钟更新一次
        _kilometers = 2.0f;
    }
    return self;
}

- (void)setTimer:(NSTimer *)timer {
    if (_timer != timer) {
        [_timer invalidate];
    }
    _timer = timer;
}

/**
 *  开启服务
 */
- (void)start {
    if (_timer) {
        return ;
    }
    
    [self restart];
}

- (void)restart {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:_interval target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    [self.timer fire];
}


/**
 *  停止服务
 */
- (void)stop {
    self.timer = nil;
}

/**
 *  服务是否开启
 *
 *  @return 是否开始
 */
- (BOOL)isStarting {
    return self.timer;
}

/**
 *  刷新间隔时间
 */
- (void)setInterval:(NSTimeInterval)interval {
    NSTimeInterval ainterval = interval;
    if (ainterval < CN_NEARLY_MIN_INTERVAL) {
        ainterval = CN_NEARLY_MIN_INTERVAL;
    }
    else if (ainterval > CN_NEARLY_MAX_INTERVAL) {
        ainterval = CN_NEARLY_MAX_INTERVAL;
    }
    if (_interval != ainterval) {
        _interval = ainterval;
        
        if (self.timer) {
            [self restart];
        }
    }
}

/**
 *  范围限定
 */
- (void)setKilometers:(double)kilometers {
    double akil = kilometers;
    if (akil < CN_NEARLY_MIN_KILOMETERS) {
        akil = CN_NEARLY_MIN_KILOMETERS;
    }
    else if (akil > CN_NEARLY_MAX_KILOMETERS) {
        akil = kilometers;
    }
    if (_kilometers != akil) {
        _kilometers = akil;
        
        if (self.timer) {
            [self restart];
        }
    }
}

/**
 *  模糊匹配，名字，拼音
 */
- (void)setSearchText:(NSString *)searchText {
    if (!ssn_is_equal_to_string(_searchText, searchText)) {
        _searchText = [searchText copy];
        
        if (self.timer) {
            [self restart];
        }
    }
}


- (void)timerAction:(NSTimer *)timer {
    if (timer != _timer) {
        [timer invalidate];
        return ;
    }
    
    //开始出发事件
    //1、先定位
    [[CNBMKMapDelegate delegate] locationWithCopletion:^(CLLocationCoordinate2D coor, NSError *error) {
        if (error) {
//            [SSNToast showToastMessage:cn_localized(@"location.locate.error")];
            if (_flush) {_flush(nil,coor,error);}
            return ;
        }
        
//        //2、计算范围
//        BMKMapPoint point = BMKMapPointForCoordinate(coor);
//        point.x -= _kilometers*1000;
//        double min_latitude = BMKCoordinateForMapPoint(point).latitude;
//        point.x += 2*(_kilometers*1000);
//        double max_latitude = BMKCoordinateForMapPoint(point).latitude;
//        point.x -= (_kilometers*1000);
//        
//        point.y -= _kilometers*1000;
//        double min_longitude = BMKCoordinateForMapPoint(point).longitude;
//        point.y += 2*(_kilometers*1000);
//        double max_longitude = BMKCoordinateForMapPoint(point).longitude;
        
        NSString *sql = nil;
        NSString *text = _searchText;
        SSNDBTable *tb = [SSNDBTableManager personTable];
        if ([text ssn_non_empty]) {
            sql = [NSString stringWithFormat:@"select * from %@ where uid <> '%@' and (name like '%%%@%%' or pinyin like '%%%@%%')",tb.name,[CNUserCenter center].currentUID,text,text];
        }
        else {
            sql = [NSString stringWithFormat:@"select * from %@ where uid <> '%@'",tb.name,[CNUserCenter center].currentUID];
        }
        
        NSArray *persons = [[CNUserCenter center].currentDatabase objects:[CNPerson class] sql:sql arguments:nil];
        if (_flush) {_flush(persons,coor,nil);}
    }];
    
}


@end
