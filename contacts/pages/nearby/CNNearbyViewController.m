//
//  CNNearbyViewController.m
//  contacts
//
//  Created by lingminjun on 15/5/24.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNNearbyViewController.h"
#import <BaiduMapAPI/BMapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CNNearbyServer.h"
#import "CNNearbyPerson.h"
#import "CNPerson.h"
#import "CNPointAnnotation.h"

@interface CNNearbyViewController ()<BMKMapViewDelegate,UIGestureRecognizerDelegate>
{
}

@property (nonatomic,strong) BMKMapView *mapView;

@property (nonatomic) CLLocationCoordinate2D here;//当前位置

@property (nonatomic,strong) CNNearbyPerson *selectdPerson;
@property (nonatomic,strong) BMKPointAnnotation *pointAnnotation;//选中
@property (nonatomic) CLLocationCoordinate2D coor;//选中

@property (nonatomic,strong) NSMutableArray *nearbyPersons;//附近的小伙伴
@property (nonatomic,strong) NSMutableArray *annotations;//附近的小伙伴

@property (nonatomic,strong) UIView *bottomPanel;//显示选中地址信息

@property (nonatomic,strong) UIButton *atHereButton;
@property (nonatomic,strong) UIView *zoomPanel;//放大缩小按钮

@end

@implementation CNNearbyViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _nearbyPersons = [[NSMutableArray alloc] initWithCapacity:1];
        _annotations = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}

- (UIView *)bottomPanel {
    if (_bottomPanel) {
        return _bottomPanel;
    }
    
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, 90);
    _bottomPanel = [[UIView alloc] initWithFrame:frame];
    _bottomPanel.backgroundColor = [UIColor clearColor];
    _bottomPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    {
        UIImageView *backgroud = [[UIImageView alloc] initWithFrame:_bottomPanel.bounds];
        backgroud.ssn_width = _bottomPanel.ssn_width - (cn_left_edge_width + cn_right_edge_width);
        backgroud.image = [[UIImage ssn_imageWithColor:cn_backgroud_white_color cornerRadius:2] ssn_centerStretchImage];
        backgroud.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        backgroud.userInteractionEnabled = YES;
        backgroud.center = ssn_center(_bottomPanel.bounds);
        ssn_panel_set(_bottomPanel, backgroud, backgroud);
        
        {
            SSNUITableLayout *layout = [backgroud ssn_tableLayoutWithRowCount:4 columnCount:1];
            layout.contentInset = UIEdgeInsetsMake(0, cn_left_edge_width, 0, cn_right_edge_width);
            
            UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, backgroud.ssn_width - (cn_left_edge_width + cn_right_edge_width), 30)];
            {
                int local_width = 100;
                SSNUITableLayout *ly = [topView ssn_tableLayoutWithRowCount:1 columnCount:2];
                [ly setColumnInfo:ssn_layout_table_column_v2(local_width) atColumn:1];
                
                UILabel *label = [UILabel ssn_labelWithWidth:topView.ssn_width - local_width
                                                        font:cn_title_font
                                                       color:cn_text_normal_color
                                                   backgroud:[UIColor clearColor]
                                                   alignment:NSTextAlignmentLeft
                                                   multiLine:NO];
                ssn_layout_add_v2(ly, label, 0, ssn_layout_table_cell_v2(SSNUIContentModeCenter), name);
                
                label = [UILabel ssn_labelWithWidth:local_width
                                               font:cn_assist_font
                                              color:cn_text_assist_color
                                          backgroud:[UIColor clearColor]
                                          alignment:NSTextAlignmentRight
                                          multiLine:NO];
                ssn_layout_add_v2(ly, label, 1, ssn_layout_table_cell_v2(SSNUIContentModeCenter), distance);
            }
            ssn_layout_add_v2(layout, topView, 0, ssn_layout_table_cell_v2(SSNUIContentModeCenter), topView);
            
            UILabel *label = [UILabel ssn_labelWithWidth:backgroud.ssn_width - (cn_left_edge_width + cn_right_edge_width)
                                                    font:cn_normal_font
                                                   color:cn_text_assist_color
                                               backgroud:[UIColor clearColor]
                                               alignment:NSTextAlignmentLeft
                                               multiLine:NO];
            ssn_layout_add_v2(layout, label, 1, ssn_layout_table_cell_v2(SSNUIContentModeTop), content);
            
            //划线
            [layout setRowInfo:ssn_layout_table_row(1) atRow:2];
            UIImageView *line = [UIImageView ssn_lineWithWidth:backgroud.ssn_width - (cn_left_edge_width + cn_right_edge_width) color:cn_separator_line_color orientation:UIInterfaceOrientationPortraitUpsideDown];
            ssn_layout_add_v2(layout, line, 2, ssn_layout_table_cell_v2(SSNUIContentModeCenter), line);

            UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, backgroud.ssn_width - (cn_left_edge_width + cn_right_edge_width), 30)];
            {
                SSNUITableLayout *ly = [bottomView ssn_tableLayoutWithRowCount:1 columnCount:3];
                [ly setColumnInfo:ssn_layout_table_column_v2(1) atColumn:1];

                UIButton *btn = [UIButton cn_transparent_button];
                btn.ssn_normalTitle = cn_localized(@"location.call.label");
                btn.ssn_normalImage = cn_image(@"icon_call");
                [btn ssn_addTarget:self touchAction:@selector(callAction:)];
                ssn_layout_add_v2(ly, btn, 0, ssn_layout_table_cell_v2(SSNUIContentModeCenter), call);
                
                UIImageView *line = [UIImageView ssn_lineWithWidth:24 color:cn_separator_line_color orientation:UIInterfaceOrientationLandscapeLeft];
                ssn_layout_add_v2(ly, line, 1, ssn_layout_table_cell_v2(SSNUIContentModeCenter), line);
                
                btn = [UIButton cn_transparent_button];
                btn.ssn_normalTitle = cn_localized(@"location.gps.label");
                btn.ssn_normalImage = cn_image(@"icon_gps");
                [btn ssn_addTarget:self touchAction:@selector(gpsAction:)];
                
                ssn_layout_add_v2(ly, btn, 2, ssn_layout_table_cell_v2(SSNUIContentModeCenter), gps);
            }
            
            [layout setRowInfo:ssn_layout_table_row(bottomView.ssn_height) atRow:3];
            ssn_layout_add_v2(layout, bottomView, 3, ssn_layout_table_cell_v2(SSNUIContentModeCenter), bottomView);
        }
        
        self.bottomPanel.hidden = YES;
        
    }
    
    return _bottomPanel;
}

- (UIButton *)atHereButton {
    if (_atHereButton) {
        return _atHereButton;
    }
    
    UIButton *btn = [UIButton ssn_buttonWithSize:CGSizeMake(40, 40)
                                            font:cn_assist_font
                                           color:cn_text_assist_color
                                        selected:nil
                                        disabled:nil
                                       backgroud:cn_image(@"icon_me_location")
                                        selected:nil
                                        disabled:nil];
    [btn ssn_addTarget:self touchAction:@selector(here:)];
    _atHereButton = btn;
    
    SSNUITableLayout *layout = [self.view ssn_tableLayoutWithRowCount:1 columnCount:1];
    [layout setLayoutID:@"atHereButtonLayout"];
    layout.contentInset = UIEdgeInsetsMake(0, cn_left_edge_width, cn_bottom_edge_height, 0);
    layout.contentMode = SSNUIContentModeBottomLeft;
    
    ssn_layout_add(layout, _atHereButton, 0, atHereButton);
    
    return _atHereButton;
}
- (UIView *)zoomPanel {
    if (_zoomPanel) {
        return _zoomPanel;
    }
    
    _zoomPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 81)];
    {
        SSNUITableLayout *layout = [_zoomPanel ssn_tableLayoutWithRowCount:3 columnCount:1];
        
        UIButton *btn = [UIButton ssn_buttonWithSize:CGSizeMake(40, 40)
                                                font:cn_assist_font
                                               color:cn_text_assist_color
                                            selected:nil
                                            disabled:nil
                                           backgroud:cn_image(@"icon_scal_up")
                                            selected:nil
                                            disabled:nil];
        [btn ssn_addTarget:self touchAction:@selector(addAction:)];
        ssn_layout_add_v2(layout, btn, 0, ssn_layout_table_cell_v2(SSNUIContentModeCenter), addZoomButton);
        
        //划线
        [layout setRowInfo:ssn_layout_table_row(1) atRow:1];
        UIImageView *line = [UIImageView ssn_lineWithWidth:_zoomPanel.ssn_width - (cn_left_edge_width + cn_right_edge_width) color:cn_separator_line_color orientation:UIInterfaceOrientationPortraitUpsideDown];
        ssn_layout_add_v2(layout, line, 1, ssn_layout_table_cell_v2(SSNUIContentModeCenter), line);
        
        btn = [UIButton ssn_buttonWithSize:CGSizeMake(40, 40)
                                                font:cn_assist_font
                                               color:cn_text_assist_color
                                            selected:nil
                                            disabled:nil
                                           backgroud:cn_image(@"icon_scal_down")
                                            selected:nil
                                            disabled:nil];
        [btn ssn_addTarget:self touchAction:@selector(reduceAction:)];
        ssn_layout_add_v2(layout, btn, 2, ssn_layout_table_cell_v2(SSNUIContentModeCenter), reduceZoomButton);
        
    }
    
    SSNUITableLayout *layout = [self.view ssn_tableLayoutWithRowCount:1 columnCount:1];
    [layout setLayoutID:@"zoomPanelLayout"];
    layout.contentInset = UIEdgeInsetsMake(0, 0, 2*cn_bottom_edge_height, cn_right_edge_width);
    layout.contentMode = SSNUIContentModeBottomRight;
    
    ssn_layout_add(layout, _zoomPanel, 0, zoomPanel);
    
    return _zoomPanel;

}

- (void)showBottomPanelWithTitle:(NSString *)title distance:(NSString *)distance detail:(NSString *)detail {
    if (self.bottomPanel.hidden) {
        self.bottomPanel.ssn_bottom = self.view.bounds.size.height - cn_bottom_edge_height;
        self.bottomPanel.ssn_center_x = ssn_center(self.view.bounds).x;
        [self.view addSubview:self.bottomPanel];
        
        _bottomPanel.hidden = NO;
    }
    
    SSNUILayout *layout = [self.view ssn_layoutForID:@"zoomPanelLayout"];
    UIEdgeInsets insert = layout.contentInset;
    insert.bottom = 2*cn_bottom_edge_height + _bottomPanel.ssn_height + cn_bottom_edge_height;
    layout.contentInset = insert;
    
    layout = [self.view ssn_layoutForID:@"atHereButtonLayout"];
    insert = layout.contentInset;
    insert.bottom = cn_bottom_edge_height + _bottomPanel.ssn_height + cn_bottom_edge_height;
    layout.contentInset = insert;
    
    UIView *backgroud = ssn_panel_get(UIView, _bottomPanel, backgroud);
    
    UIView *topView = ssn_panel_get(UIView, backgroud, topView);
    
    UILabel *nameLabel = ssn_panel_get(UILabel, topView, name);
    nameLabel.text = title;
    
    UILabel *distanceLabel = ssn_panel_get(UILabel, topView, distance);
    distanceLabel.text = distance;
    
    UILabel *label = ssn_panel_get(UILabel, backgroud, content);
    label.text = detail;
}

- (void)dismissBottomPanel {
    _bottomPanel.hidden = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = cn_localized(@"nearby.header.title");
    self.tabBarItem.image = cn_image(@"icon_nearby_normal");
    self.tabBarItem.selectedImage = cn_image(@"icon_nearby_selected");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:cn_image(@"location_list") style:UIBarButtonItemStylePlain target:self action:@selector(gotoList:)];
    
    _mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_mapView];
    
    [self loadCoor];
    
    [self flushLocation];
    
    [self atHereButton];
    [self zoomPanel];
}

- (void)gotoList:(id)sender {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setValue:[NSArray arrayWithArray:self.nearbyPersons] forKey:@"results"];
    [dic setValue:[NSString stringWithFormat:@"%lf", self.here.latitude] forKey:@"latitude"];
    [dic setValue:[NSString stringWithFormat:@"%lf", self.here.longitude] forKey:@"longitude"];
    
    [self.ssn_router open:cn_combine_path(@"nav/nearbylist") query:dic];
}

- (void)here:(id)sender {
    if (self.here.latitude != 0.0 && self.here.longitude != 0.0) {
        [_mapView setCenterCoordinate:_here animated:YES];
    }
}

- (void)addAction:(id)sender {
    BMKCoordinateRegion region = self.mapView.region;
    region.span.latitudeDelta -= 0.01;
    region.span.longitudeDelta -= 0.01;
    [self.mapView setRegion:region animated:YES];
}

- (void)reduceAction:(id)sender {
    BMKCoordinateRegion region = self.mapView.region;
    region.span.latitudeDelta += 0.01;
    region.span.longitudeDelta += 0.01;
    [self.mapView setRegion:region animated:YES];
}

- (void)loadCoor {
    __weak typeof(self) w_self = self;
    [[CNBMKMapDelegate delegate] locationWithCopletion:^(CLLocationCoordinate2D coor, NSError *error) {
        __strong typeof(w_self) self = w_self;
        
        self.coor = coor;
        self.here = coor;
        
        BMKCoordinateRegion region = BMKCoordinateRegionMake(self.coor, BMKCoordinateSpanMake(0.04f, 0.04f));
        [self.mapView setRegion:region animated:YES];
    }];
}

- (void)flushLocation {
    
    __weak typeof(self) w_self = self;
    [[CNNearbyServer server] setFlush:^(NSArray *persons, CLLocationCoordinate2D here,NSError *error) {
        __strong typeof(w_self) self = w_self;
        
        if (error) {
            [self ssn_showToast:cn_localized(@"location.gps.error")];
            return ;
        }
        
        NSMutableArray *temList = [NSMutableArray array];
        [persons enumerateObjectsUsingBlock:^(CNPerson *obj, NSUInteger idx, BOOL *stop) {
            CNNearbyPerson *person = [[CNNearbyPerson alloc] init];
            [person ssn_setObject:obj];
            CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(person.latitude, person.longitude);
            person.nearbyDistance = [[CNBMKMapDelegate delegate] kilometersFromCoordinate:_here toCoordinate:coor];
            [temList addObject:person];
        }];
        [temList sortUsingSelector:@selector(compareByNearbyDistance:)];
        [temList enumerateObjectsUsingBlock:^(CNNearbyPerson *obj, NSUInteger idx, BOOL *stop) {
            obj.nearbyIndex = idx + 1;
        }];
        
        if (self.annotations) {
            [self.annotations removeObject:self.pointAnnotation];//选中不需要移除
            [self.mapView removeAnnotations:self.annotations];
            [self.annotations removeAllObjects];
        }
        
        if (temList) {
            [self.nearbyPersons setArray:temList];
        }
        
        //显示新的气泡
        [self.nearbyPersons enumerateObjectsUsingBlock:^(CNNearbyPerson *person, NSUInteger idx, BOOL *stop) {
            
            CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(person.latitude, person.longitude);
            CNPointAnnotation *annotation = [self loadPointAnnotationWithTitle:person.name subTitle:person.street coor:coor];
            annotation.person = person;
            annotation.index = person.nearbyIndex;
            
            [self.annotations addObject:annotation];
            
            if ((_selectdPerson == nil && idx == 0) || [_selectdPerson.uid isEqualToString:person.uid]) {
                if (self.pointAnnotation) {
                    [self->_mapView removeAnnotation:self.pointAnnotation];
                }
                self.coor = coor;
                self.selectdPerson = person;
                self.pointAnnotation = annotation;
                [self showAnnotationsWithZoom:0.0f];
            }
            
        }];
        
        [self.mapView addAnnotations:self.annotations];
        
        //定位
        BMKUserLocation *userLocation = [[BMKUserLocation alloc] init];
        userLocation.title = cn_localized(@"location.me.location");
//        userLocation.subtitle
        [userLocation setValue:[[CLLocation alloc] initWithLatitude:here.latitude longitude:here.longitude] forKey:@"location"];
//        userLocation.location = ;
        [self.mapView updateLocationData:userLocation];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _mapView.userTrackingMode = BMKUserTrackingModeNone;
    _mapView.showsUserLocation = YES;
    
    [[CNNearbyServer server] start];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _mapView.showsUserLocation = NO;
    
    [[CNNearbyServer server] stop];
}

#pragma mark - action
- (void)callAction:(id)sender {
    if (self.selectdPerson == nil) {
        return ;
    }
    
    NSString *mobile = self.selectdPerson.mobile;
    NSString *msg = [NSString stringWithFormat:@"确定呼叫%@:%@吗？",self.selectdPerson.name,[mobile ssn_mobile344FormatSeparatedByCharacter:'-']];
    
    [UIAlertView ssn_showConfirmationDialogWithTitle:@""
                                             message:msg
                                              cancel:cn_localized(@"common.cancel.button")
                                             confirm:cn_localized(@"common.call.button")
                                             handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:cn_localized(@"common.call.button")]) {
            
            //打点，呼叫次数
            
            NSString *url = [NSString stringWithFormat:@"tel:%@",mobile];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }];
}

- (void)gpsAction:(id)sender {
    
    if (self.selectdPerson == nil) {
        return ;
    }
    
    NSString *msg = [NSString stringWithFormat:@"确定导航到%@%@的位置？",self.selectdPerson.name,(_selectdPerson.addressLabel == CNCompanyAddressLabel ?cn_localized(@"user.company.address.label") : cn_localized(@"user.home.address.label"))];
    [UIAlertView ssn_showConfirmationDialogWithTitle:@""
                                             message:msg
                                              cancel:cn_localized(@"common.cancel.button")
                                             confirm:cn_localized(@"common.submit.button")
                                             handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                 NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
                                                 if ([title isEqualToString:cn_localized(@"common.submit.button")]) {
                                                     
                                                     //打点，导航次数
                                                     
                                                     if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
                                                         [self nativeNavi];
                                                     }
                                                     else {
                                                         [self webNavi];
                                                     }
                                                 }
                                             }];
}

- (IBAction)nativeNavi
{
    //初始化调启导航时的参数管理类
    BMKNaviPara* para = [[BMKNaviPara alloc]init];
    //指定导航类型
    para.naviType = BMK_NAVI_TYPE_NATIVE;
    
    //初始化终点节点
    BMKPlanNode* end = [[BMKPlanNode alloc] init];
    
    //指定终点经纬度
    CLLocationCoordinate2D coor2;
    coor2.latitude = self.selectdPerson.latitude;
    coor2.longitude = self.selectdPerson.longitude;
    end.pt = coor2;
    //指定终点名称
    NSString *title = [NSString stringWithFormat:@"%@%@的位置",_selectdPerson.name,(_selectdPerson.addressLabel == CNCompanyAddressLabel ?cn_localized(@"user.company.address.label") : cn_localized(@"user.home.address.label"))];
    end.name = title;
    //指定终点
    para.endPoint = end;
    
    //指定返回自定义scheme
    para.appScheme = @"baidumapsdk://mapsdk.baidu.com";
    
    //调启百度地图客户端导航
    [BMKNavigation openBaiduMapNavigation:para];
}

- (IBAction)webNavi
{
    //初始化调启导航时的参数管理类
    BMKNaviPara* para = [[BMKNaviPara alloc]init];
    //指定导航类型
    para.naviType = BMK_NAVI_TYPE_WEB;
    
    //初始化起点节点
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    
    //指定起点经纬度
    CLLocationCoordinate2D coor1 = _here;
    start.pt = coor1;
    //指定起点名称
    start.name = cn_localized(@"location.me.location");
    //指定起点
    para.startPoint = start;
    
    
    //初始化终点节点
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    CLLocationCoordinate2D coor2;
    coor2.latitude = self.selectdPerson.latitude;
    coor2.longitude = self.selectdPerson.longitude;
    end.pt = coor2;
    para.endPoint = end;
    //指定终点名称
    NSString *title = [NSString stringWithFormat:@"%@%@的位置",_selectdPerson.name,(_selectdPerson.addressLabel == CNCompanyAddressLabel ?cn_localized(@"user.company.address.label") : cn_localized(@"user.home.address.label"))];
    end.name = title;
    //指定调启导航的app名称
    para.appName = [SSNAppInfo appLocalizedName];
    //调启web导航
    [BMKNavigation openBaiduMapNavigation:para];
}

#pragma mark - Annotation
- (CNPointAnnotation *)loadPointAnnotationWithTitle:(NSString *)title subTitle:(NSString *)subTitle coor:(CLLocationCoordinate2D)coor {
    
    CNPointAnnotation *point = [[CNPointAnnotation alloc]init];
    point.title = title;
    point.subtitle = subTitle;
    point.coordinate = coor;
    
    return point;
}

- (void)showAnnotationsWithZoom:(CGFloat)zoom {
//    if (_pointAnnotation == nil) {
//        _pointAnnotation = [self loadPointAnnotationWithTitle:self.addrtitle subTitle:self.addrdes coor:_coor];
//    }
    if (_pointAnnotation) {
        _pointAnnotation.coordinate = _coor;
        [_mapView addAnnotation:_pointAnnotation];
    }
    
    if (zoom > 0) {
        BMKCoordinateRegion region = BMKCoordinateRegionMake(_coor, BMKCoordinateSpanMake(zoom, zoom));
        [_mapView setRegion:region animated:YES];
    }
//    else {
//        [_mapView setCenterCoordinate:_coor animated:YES];
//    }
    
//    __weak typeof(self) w_self = self;
//    [[CNBMKMapDelegate delegate] reverseGeoCodeWithLocationCoordinate:_coor completion:^(CNAddress *addr, NSString *addrDes, NSError *error) {
//        __strong typeof(w_self) self = w_self;
//    
//        if (addr) {
    self.pointAnnotation.subtitle = self.selectdPerson.street;
    NSString *distanceStr = [NSString stringWithFormat:@"距离:%.2fkm",self.selectdPerson.nearbyDistance];
    NSString * addressLabel = self.selectdPerson.addressLabel == CNCompanyAddressLabel ? @"公司" : @"家";
    NSString *showTitle = [NSString stringWithFormat:@"%ld.%@-%@",(long)(self.selectdPerson.nearbyIndex),self.selectdPerson.name,addressLabel];
    [self showBottomPanelWithTitle:showTitle distance:distanceStr detail:self.selectdPerson.street];
//        }
//    }];
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
        // 设置重天上掉下的效果(annotation)
        ((BMKPinAnnotationView*)annotationView).animatesDrop = NO;
    }
    
    if ([annotation isKindOfClass:[CNPointAnnotation class]]) {
        CNPointAnnotation *ann = (CNPointAnnotation *)annotation;
        if (annotation == _pointAnnotation) {
            annotationView.image = [self pointAnnotationImageWithIndex:ann.index selected:YES];
        }
        else {
            // 设置颜色
            annotationView.image = [self pointAnnotationImageWithIndex:ann.index selected:NO];
        }
    }
    else {
        if (annotation == _pointAnnotation) {
            annotationView.image = cn_image(@"icon_selected_nail");
        }
        else {
            // 设置颜色
            annotationView.image = cn_image(@"icon_normal_nail");
        }
    }
    
    // 设置位置
    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
    annotationView.canShowCallout = NO;
    annotationView.draggable = NO;
    
    return annotationView;
}

/**
 *点中底图标注后会回调此接口
 *@param mapview 地图View
 *@param mapPoi 标注点信息
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi*)mapPoi {
    
}

- (UIImage *)pointAnnotationImageWithIndex:(NSUInteger)idx selected:(BOOL)selected {
    if (idx > 10) {
        if (selected) {
            return cn_image(@"icon_selected_nail");
        }
        else {
            return cn_image(@"icon_normal_nail");
        }
    }
    else {
        if (selected) {
            return cn_image(([NSString stringWithFormat:@"blue_%ld", (long)idx]));
        }
        else {
            return cn_image(([NSString stringWithFormat:@"red_%ld", (long)idx]));
        }
    }
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    //我的位置不需要处理
    if ([[view.annotation title] isEqualToString:cn_localized(@"location.me.location")]) {
        return ;
    }
    
    if (view.annotation == _pointAnnotation) {
        return ;
    }
    
    _coor = view.annotation.coordinate;
    
    BMKAnnotationView *old = [mapView viewForAnnotation:_pointAnnotation];
    if ([old.annotation isKindOfClass:[CNPointAnnotation class]]) {
        CNPointAnnotation *ann = (CNPointAnnotation *)old.annotation;
        old.image = [self pointAnnotationImageWithIndex:ann.index selected:NO];
    }
    else {
        old.image = cn_image(@"icon_normal_nail");
    }
//    [(BMKPinAnnotationView *)old setPinColor:BMKPinAnnotationColorPurple];
    
    if ([view.annotation isKindOfClass:[BMKPointAnnotation class]]) {
        _pointAnnotation = (BMKPointAnnotation *)(view.annotation);
        NSInteger index = [self.annotations indexOfObject:_pointAnnotation];
        if (index < [self.nearbyPersons count]) {
            _selectdPerson = [self.nearbyPersons objectAtIndex:index];
        }
    }
    else {
//        _pointAnnotation = [self loadPointAnnotationWithTitle:self.addrtitle subTitle:view.annotation.subtitle coor:_coor];
    }
    
    if ([view.annotation isKindOfClass:[CNPointAnnotation class]]) {
        CNPointAnnotation *ann = (CNPointAnnotation *)view.annotation;
        view.image = [self pointAnnotationImageWithIndex:ann.index selected:YES];
    }
    else {
        view.image = cn_image(@"icon_selected_nail");
    }
    

    [self showAnnotationsWithZoom:0];
}
- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    NSLog(@"didAddAnnotationViews");
}

#pragma mark -
#pragma mark implement BMKSearchDelegate



#pragma mark - SSNPage
- (BOOL)ssn_canRespondURL:(NSURL *)url query:(NSDictionary *)query {
    return YES;
}

@end
