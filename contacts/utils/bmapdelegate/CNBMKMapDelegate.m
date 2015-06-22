//
//  CNBMKMapDelegate.m
//  contacts
//
//  Created by lingminjun on 15/5/31.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNBMKMapDelegate.h"
#import "SSNLogger.h"
#import <BaiduMapAPI/BMapKit.h>

NSString *const BMKMapAppKey = @"CqbrjsjvEIfnRyILq9ZoiZhK";
NSString *const BMKMapErrorDomain = @"CNBMKMap";

const CLLocationCoordinate2D cn_default_location_coordinate = {116.403981f,39.915101f};

@interface CNBMKMapRequsetDelegate : NSObject<BMKGeoCodeSearchDelegate,BMKLocationServiceDelegate,BMKPoiSearchDelegate>

@property (nonatomic,strong) id service;
@property (nonatomic,copy) id completion;
@property (nonatomic,copy) NSDictionary *userInfo;

+ (instancetype)geoCodeSearchDelegate;

@end


@interface CNBMKMapDelegate () <BMKGeneralDelegate> {
    BMKMapManager* _mapManager;
    NSMutableDictionary *_requestQueue;
}

@property (nonatomic,strong,readonly) NSMutableDictionary *requestQueue;

@end


@implementation CNBMKMapDelegate

+ (instancetype)delegate {
    static CNBMKMapDelegate *delegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        delegate = [[CNBMKMapDelegate alloc] init];
    });
    return delegate;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _requestQueue = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return self;
}

#pragma mark - 实现的协议方法
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc] init];
    BOOL ret = [_mapManager start:BMKMapAppKey generalDelegate:self];
    
    if (!ret) {
        SSNLogError(@"BMKMapManager start failed!");
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [BMKMapView willBackGround];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [BMKMapView didForeGround];
}

#pragma mark - BMKGeneralDelegate
/**
 *返回网络错误
 *@param iError 错误号
 */
- (void)onGetNetworkState:(int)iError {
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
}

/**
 *返回授权验证错误
 *@param iError 错误号 : 为0时验证通过，具体参加BMKPermissionCheckResultCode
 */
- (void)onGetPermissionState:(int)iError {
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}

#pragma mark - 地址与经纬度转化
/**
 *  地址转换成经纬度
 *
 *  @param address    地址信息
 *  @param city       城市
 *  @param completion 回调
 */
- (void)geoCodeWithAddress:(NSString *)address city:(NSString *)city completion:(void (^)(CLLocationCoordinate2D coor,NSError *error))completion {
    
    if ([address length] == 0) {
        if (completion) {
            completion(cn_default_location_coordinate,cn_error(BMKMapErrorDomain,-1,@"参数错误"));
        }
        return ;
    }
    
    BMKGeoCodeSearchOption *geocodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
    if ([city length] == 0) {
        NSArray *arry = [address componentsSeparatedByString:@" "];
        if ([arry count]) {
            city = [arry firstObject];
        }
    }
    geocodeSearchOption.city= city;
    geocodeSearchOption.address = address;
    
    void (^inner_completion)(CNAddress *address,NSString *addr, CLLocationCoordinate2D coor, NSError *error) = ^(CNAddress *address,NSString *addr, CLLocationCoordinate2D coor, NSError *error) {
        if (completion) {
            completion(coor,error);
        }
    };
    
    CNBMKMapRequsetDelegate *delegate = [CNBMKMapRequsetDelegate geoCodeSearchDelegate];
    delegate.completion = inner_completion;
    
    BMKGeoCodeSearch *geoCodeSearch = [[BMKGeoCodeSearch alloc] init];
    geoCodeSearch.delegate = delegate;
    delegate.service = geoCodeSearch;
    
    BOOL flag = [geoCodeSearch geoCode:geocodeSearchOption];
    if(flag)
    {
        SSNLog(@"geo检索发送成功 %@",delegate);
        [self.requestQueue setObject:delegate forKey:[NSString stringWithFormat:@"%p",delegate]];
    }
    else
    {
        SSNLog(@"geo检索发送失败");
        if (completion) {
            completion(cn_default_location_coordinate,cn_error(BMKMapErrorDomain, -1, @"eo检索发送失败"));
        }
    }

}

/**
 *  坐标转化成精度
 *
 *  @param coor       坐标
 *  @param completion 回调
 */
- (void)reverseGeoCodeWithLocationCoordinate:(CLLocationCoordinate2D)coor completion:(void (^)(CNAddress *address,NSString *addr,NSError *error))completion; {
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeocodeSearchOption.reverseGeoPoint = coor;
    
    void (^inner_completion)(CNAddress *address,NSString *addr, CLLocationCoordinate2D coor, NSError *error) = ^(CNAddress *address,NSString *addr, CLLocationCoordinate2D coor, NSError *error) {
        if (completion) {
            completion(address,addr,error);
        }
    };
    
    CNBMKMapRequsetDelegate *delegate = [CNBMKMapRequsetDelegate geoCodeSearchDelegate];
    delegate.completion = inner_completion;
    
    BMKGeoCodeSearch *geoCodeSearch = [[BMKGeoCodeSearch alloc] init];
    geoCodeSearch.delegate = delegate;
    delegate.service = geoCodeSearch;
    
    BOOL flag = [geoCodeSearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        SSNLog(@"反geo检索发送成功 %@",delegate);
        [self.requestQueue setObject:delegate forKey:[NSString stringWithFormat:@"%p",delegate]];
    }
    else
    {
        SSNLog(@"反geo检索发送失败");
        if (completion) {
            completion(nil,nil,cn_error(BMKMapErrorDomain, -1, @"反geo检索发送失败"));
        }
    }
}

#pragma mark - 定位服务
/**
 *  定位服务，查找当前所在位置
 *
 *  @param completion 回调
 */
- (void)locationWithCopletion:(void (^)(CLLocationCoordinate2D coor,NSError *error))completion {
    
    void (^inner_completion)(CNAddress *address,NSString *addr, CLLocationCoordinate2D coor, NSError *error) = ^(CNAddress *address,NSString *addr, CLLocationCoordinate2D coor, NSError *error) {
        if (completion) {
            completion(coor,error);
        }
    };
    
    CNBMKMapRequsetDelegate *delegate = [CNBMKMapRequsetDelegate geoCodeSearchDelegate];
    delegate.completion = inner_completion;
    
    BMKLocationService *localService = [[BMKLocationService alloc] init];
    localService.delegate = delegate;
    delegate.service = localService;
    
    SSNLog(@"开启定位服务 %@",delegate);
    [self.requestQueue setObject:delegate forKey:[NSString stringWithFormat:@"%p",delegate]];
    [localService startUserLocationService];
}

#pragma mark - pio服务
/**
 *  搜索服务
 *
 *  @param city       城市，必填
 *  @param searchText 搜索内容，不能为空
 *  @param index      页码
 *  @param size       页大小
 *  @param completion 回调
 */
- (void)pointsSearchWithCity:(NSString *)city searchText:(NSString *)searchText pageIndex:(NSUInteger)index pageSize:(NSUInteger)size completion:(void (^)(NSArray *list,NSError *error))completion {
    
    void (^inner_completion)(NSArray *list,NSError *error) = ^(NSArray *list,NSError *error) {
        if (completion) {
            completion(list,error);
        }
    };
    
    CNBMKMapRequsetDelegate *delegate = [CNBMKMapRequsetDelegate geoCodeSearchDelegate];
    delegate.completion = inner_completion;
    delegate.userInfo = @{@"city":city};
    
    BMKPoiSearch *localService = [[BMKPoiSearch alloc] init];
    
    BMKCitySearchOption *citySearchOption = [[BMKCitySearchOption alloc] init];
    citySearchOption.pageIndex = (int)index;
    citySearchOption.pageCapacity = (int)size;
    citySearchOption.city= city;
    citySearchOption.keyword = searchText;
    localService.delegate = delegate;
    
    delegate.service = localService;
    
    BOOL flag = [localService poiSearchInCity:citySearchOption];
    if(flag)
    {
        [self.requestQueue setObject:delegate forKey:[NSString stringWithFormat:@"%p",delegate]];
        SSNLog(@"城市内检索发送成功%@",delegate);
    }
    else
    {
        SSNLog(@"城市内检索发送失败%@",delegate);
    }
}

#pragma mark - 距离计算
/**
 *  返回两个坐标之间的距离
 *
 *  @param fcoor 起始坐标
 *  @param tcoor 终点坐标
 *
 *  @return 距离（km）
 */
- (double)kilometersFromCoordinate:(CLLocationCoordinate2D)fcoor toCoordinate:(CLLocationCoordinate2D)tcoor {
    //
    BMKMapPoint a = BMKMapPointForCoordinate(fcoor);
    BMKMapPoint b = BMKMapPointForCoordinate(tcoor);
    CLLocationDistance distance = BMKMetersBetweenMapPoints(a, b);
    return distance/1000.0f;
}

@end


@implementation CNBMKMapRequsetDelegate

+ (instancetype)geoCodeSearchDelegate {
    CNBMKMapRequsetDelegate *delegate = [[CNBMKMapRequsetDelegate alloc] init];
    return delegate;
}

/*
 BMK_SEARCH_NO_ERROR =0,///<检索结果正常返回
 BMK_SEARCH_AMBIGUOUS_KEYWORD,///<检索词有岐义
 BMK_SEARCH_AMBIGUOUS_ROURE_ADDR,///<检索地址有岐义
 BMK_SEARCH_NOT_SUPPORT_BUS,///<该城市不支持公交搜索
 BMK_SEARCH_NOT_SUPPORT_BUS_2CITY,///<不支持跨城市公交
 BMK_SEARCH_RESULT_NOT_FOUND,///<没有找到检索结果
 BMK_SEARCH_ST_EN_TOO_NEAR,///<起终点太近
 BMK_SEARCH_KEY_ERROR,///<key错误
 */

- (NSError *)getGeoCodeErrorWithErrorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        return  nil;
    }
    NSString *msg  = nil;
    switch (error) {
        case BMK_SEARCH_AMBIGUOUS_KEYWORD:
            msg = @"检索词有岐义";
            break;
        case BMK_SEARCH_AMBIGUOUS_ROURE_ADDR:
            msg = @"检索地址有岐义";
            break;
        case BMK_SEARCH_NOT_SUPPORT_BUS:
            msg = @"该城市不支持公交搜索";
            break;
        case BMK_SEARCH_NOT_SUPPORT_BUS_2CITY:
            msg = @"不支持跨城市公交";
            break;
        case BMK_SEARCH_RESULT_NOT_FOUND:
            msg = @"没有找到检索结果";
            break;
        case BMK_SEARCH_ST_EN_TOO_NEAR:
            msg = @"起终点太近";
            break;
        case BMK_SEARCH_KEY_ERROR:
            msg = @"key错误";
            break;
        default:
            msg = @"检索失败";
            break;
    }
    return cn_error(@"CNBMKMap", error, msg);
}

- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    
    if (self.completion) {
        void (^inner_completion)(CNAddress *address,NSString *addr, CLLocationCoordinate2D coor, NSError *error) = (void (^)(CNAddress *address,NSString *addr, CLLocationCoordinate2D coor, NSError *error))self.completion;
        inner_completion(nil, result.address, result.location, [self getGeoCodeErrorWithErrorCode:error]);
    }
    
    SSNLog(@"geo检索处理完成 %@",self);
    NSString *key = [NSString stringWithFormat:@"%p",self];
    [[CNBMKMapDelegate delegate].requestQueue removeObjectForKey:key];//必须放在最后一条语句
}

-(void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    
        
    if (self.completion) {
        CLLocationCoordinate2D coor = result.location;
        if (coor.latitude <= 0.00001f && coor.latitude >= -0.00001f) {
            coor = cn_default_location_coordinate;
        }
        CNAddress *address = [[CNAddress alloc] init];
        [address ssn_setObject:result.addressDetail];
        //修正几个数据，百度地图坑爹，直辖市带“省”字
        if ([result.addressDetail.province hasPrefix:@"北京"]) {
            address.province = @"北京";
        }
        else if ([result.addressDetail.province hasPrefix:@"上海"]) {
            address.province = @"上海";
        }
        else if ([result.addressDetail.province hasPrefix:@"天津"]) {
            address.province = @"天津";
        }
        else if ([result.addressDetail.province hasPrefix:@"重庆"]) {
            address.province = @"重庆";
        }
        
        void (^inner_completion)(CNAddress *address,NSString *addr, CLLocationCoordinate2D coor, NSError *error) = (void (^)(CNAddress *address,NSString *addr, CLLocationCoordinate2D coor, NSError *error))self.completion;
        inner_completion(address, result.address, coor, [self getGeoCodeErrorWithErrorCode:error]);
    }
    
    SSNLog(@"反geo检索处理完成 %@ address:%@",self,result.address);
    NSString *key = [NSString stringWithFormat:@"%p",self];
    [[CNBMKMapDelegate delegate].requestQueue removeObjectForKey:key];//必须放在最后一条语句
}

#pragma mark - BMKLocationServiceDelegate
/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)willStartLocatingUser
{
    SSNLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
/*
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [(BMKLocationService *)(self.service) setDelegate:nil];
    [(BMKLocationService *)(self.service) stopUserLocationService];
    
    if (self.completion) {
        self.completion(nil, nil, userLocation.location.coordinate, nil);
    }
    
    SSNLog(@"heading is %@",userLocation.heading);
    NSString *key = [NSString stringWithFormat:@"%p",self];
    [[CNBMKMapDelegate delegate].requestQueue removeObjectForKey:key];
    
    SSNLog(@"定位服务完成 %@",self);
}
 */

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [(BMKLocationService *)(self.service) setDelegate:nil];
    [(BMKLocationService *)(self.service) stopUserLocationService];

    if (self.completion) {
        void (^inner_completion)(CNAddress *address,NSString *addr, CLLocationCoordinate2D coor, NSError *error) = (void (^)(CNAddress *address,NSString *addr, CLLocationCoordinate2D coor, NSError *error))self.completion;
        inner_completion(nil, nil, userLocation.location.coordinate, nil);
    }
    
    SSNLog(@"定位服务完成 %@ lat %f,long %f",self, userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    NSString *key = [NSString stringWithFormat:@"%p",self];
    [[CNBMKMapDelegate delegate].requestQueue removeObjectForKey:key];
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)didStopLocatingUser
{
    [(BMKLocationService *)(self.service) setDelegate:nil];
    
    if (self.completion) {
        void (^inner_completion)(CNAddress *address,NSString *addr, CLLocationCoordinate2D coor, NSError *error) = (void (^)(CNAddress *address,NSString *addr, CLLocationCoordinate2D coor, NSError *error))self.completion;
        inner_completion(nil, nil, cn_default_location_coordinate, cn_error(BMKMapErrorDomain, -1, @"终止定位"));
    }
    
    SSNLog(@"定位服务停止 %@",self);
    NSString *key = [NSString stringWithFormat:@"%p",self];
    [[CNBMKMapDelegate delegate].requestQueue removeObjectForKey:key];
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    [(BMKLocationService *)(self.service) setDelegate:nil];
    
    if (self.completion) {
        void (^inner_completion)(CNAddress *address,NSString *addr, CLLocationCoordinate2D coor, NSError *error) = (void (^)(CNAddress *address,NSString *addr, CLLocationCoordinate2D coor, NSError *error))self.completion;
        inner_completion(nil, nil, cn_default_location_coordinate, cn_error(BMKMapErrorDomain, error.code, error.localizedFailureReason));
    }
    
    SSNLog(@"定位服务失败 %@",self);
    NSString *key = [NSString stringWithFormat:@"%p",self];
    [[CNBMKMapDelegate delegate].requestQueue removeObjectForKey:key];
}

#pragma mark poi服务
/**
 *返回POI搜索结果
 *@param searcher 搜索对象
 *@param poiResult 搜索结果列表
 *@param errorCode 错误号，@see BMKSearchErrorCode
 */
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResult errorCode:(BMKSearchErrorCode)errorCode {
    [(BMKPoiSearch *)(self.service) setDelegate:nil];
    
    if (self.completion) {
        void (^inner_completion)(NSArray *list,NSError *error) = (void (^)(NSArray *list,NSError *error))self.completion;
        
        NSMutableArray *list = [NSMutableArray array];
        NSString *city = [self.userInfo objectForKey:@"city"];
        [poiResult.poiInfoList enumerateObjectsUsingBlock:^(BMKPoiInfo *obj, NSUInteger idx, BOOL *stop) {
            if ([obj.city hasPrefix:city] || [city hasPrefix:obj.city]) {
                CNLocationPoint *point = [[CNLocationPoint alloc] init];
                [point ssn_setObject:obj];
                [list addObject:point];
            }
        }];
        
        inner_completion(list, cn_error(BMKMapErrorDomain, errorCode, [self getGeoCodeErrorWithErrorCode:errorCode]));
    }
    
    SSNLog(@"POI搜索结果 %@",self);
    NSString *key = [NSString stringWithFormat:@"%p",self];
    [[CNBMKMapDelegate delegate].requestQueue removeObjectForKey:key];
}

/**
 *返回POI详情搜索结果
 *@param searcher 搜索对象
 *@param poiDetailResult 详情搜索结果
 *@param errorCode 错误号，@see BMKSearchErrorCode
 */
- (void)onGetPoiDetailResult:(BMKPoiSearch*)searcher result:(BMKPoiDetailResult*)poiDetailResult errorCode:(BMKSearchErrorCode)errorCode {
}

@end

