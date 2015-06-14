//
//  CNNearbyViewController.m
//  contacts
//
//  Created by lingminjun on 15/5/24.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNNearbyViewController.h"
#import <BaiduMapAPI/BMapKit.h>

@interface CNNearbyViewController ()<BMKMapViewDelegate,UIGestureRecognizerDelegate>
{
    BMKMapView* _mapView;
//    
//    BMKPointAnnotation* _pointAnnotation;
//    CLLocationCoordinate2D _coor;//经纬度
}

@end

@implementation CNNearbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = cn_localized(@"nearby.header.title");
    self.tabBarItem.image = cn_image(@"icon_nearby_normal");
    self.tabBarItem.selectedImage = cn_image(@"icon_nearby_selected");
    
    _mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_mapView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark -
#pragma mark implement BMKMapViewDelegate

/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    // 生成重用标示identifier
    NSString *AnnotationViewID = @"xidanMark";
    
    // 检查是否有重用的缓存
    BMKAnnotationView* annotationView = [view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorRed;
        // 设置重天上掉下的效果(annotation)
        ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
    }
    
    // 设置位置
    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
    annotationView.canShowCallout = YES;
    // 设置是否可以拖拽
    annotationView.draggable = NO;
    
    return annotationView;
}
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    [mapView bringSubviewToFront:view];
    [mapView setNeedsDisplay];
}
- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    NSLog(@"didAddAnnotationViews");
}

#pragma mark -
#pragma mark implement BMKSearchDelegate

- (void)onGetCloudPoiResult:(NSArray*)poiResultList searchType:(int)type errorCode:(int)error
{
    // 清楚屏幕中所有的annotation
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    
    if (error == BMKErrorOk) {
        BMKCloudPOIList* result = [poiResultList objectAtIndex:0];
        for (int i = 0; i < result.POIs.count; i++) {
            BMKCloudPOIInfo* poi = [result.POIs objectAtIndex:i];
            //自定义字段
            if(poi.customDict!=nil&&poi.customDict.count>1)
            {
                NSString* customStringField = [poi.customDict objectForKey:@"custom"];
                NSLog(@"customFieldOutput=%@",customStringField);
                NSNumber* customDoubleField = [poi.customDict objectForKey:@"double"];
                NSLog(@"customDoubleFieldOutput=%f",customDoubleField.doubleValue);
                
            }
            
            BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
            CLLocationCoordinate2D pt = (CLLocationCoordinate2D){ poi.longitude,poi.latitude};
            item.coordinate = pt;
            item.title = poi.title;
            [_mapView addAnnotation:item];
            if(i == 0)
            {
                //将第一个点的坐标移到屏幕中央
                _mapView.centerCoordinate = pt;
            }
        }
    } else {
        NSLog(@"error ==%d",error);
    }
}
//- (void)onGetCloudPoiDetailResult:(BMKCloudPOIInfo*)poiDetailResult searchType:(int)type errorCode:(int)error
//{
//    // 清楚屏幕中所有的annotation
//    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
//    [_mapView removeAnnotations:array];
//    
//    if (error == BMKErrorOk) {
//        BMKCloudPOIInfo* poi = poiDetailResult;
//        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
//        CLLocationCoordinate2D pt = (CLLocationCoordinate2D){ poi.longitude,poi.latitude};
//        item.coordinate = pt;
//        item.title = poi.title;
//        [_mapView addAnnotation:item];
//        //将第一个点的坐标移到屏幕中央
//        _mapView.centerCoordinate = pt;
//    } else {
//        NSLog(@"error ==%d",error);
//    }
//}

#pragma mark - SSNPage
- (BOOL)ssn_canRespondURL:(NSURL *)url query:(NSDictionary *)query {
    return YES;
}

@end
