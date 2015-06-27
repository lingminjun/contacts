//
//  CNLocationViewController.m
//  contacts
//
//  Created by baidu on 13-4-15.
//  Copyright (c) 2013年 baidu. All rights reserved.
//
#import "CNLocationViewController.h"
#import <BaiduMapAPI/BMapKit.h>
#import "CNTableViewCell.h"

@interface CNLocationViewController () <BMKMapViewDelegate,UIGestureRecognizerDelegate,UISearchBarDelegate>
{
    BMKMapView* _mapView;
    
    BMKPointAnnotation* _pointAnnotation;
    CLLocationCoordinate2D _coor;//经纬度
    
    
}

@property (nonatomic,strong) BMKPointAnnotation *pointAnnotation;
@property (nonatomic) CLLocationCoordinate2D coor;

//搜索
@property (nonatomic,strong) UISearchBar *searchBar;

@property (nonatomic,strong) UIView *bottomPanel;//显示选中地址信息

@property (nonatomic,strong) UITableView *searchTable;
@property (nonatomic,strong) NSMutableArray *pointAnnotations;//搜索出来的地址信息
@property (nonatomic,strong) NSMutableArray *searchPoints;
//@property (nonatomic,strong) SSNTableViewConfigurator *searchConfigurator;

@end

@implementation CNLocationViewController

- (UIView *)bottomPanel {
    if (_bottomPanel) {
        return _bottomPanel;
    }
    
    CGRect frame = CGRectMake(0, 0, self.view.ssn_width, 120);
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
            SSNUITableLayout *layout = [backgroud ssn_tableLayoutWithRowCount:3 columnCount:1];
            layout.contentInset = cn_panel_edge;
            
            UILabel *label = [UILabel ssn_labelWithWidth:backgroud.ssn_width - (cn_left_edge_width + cn_right_edge_width)
                                                    font:cn_normal_font
                                                   color:cn_text_assist_color
                                               backgroud:[UIColor clearColor]
                                               alignment:NSTextAlignmentLeft
                                               multiLine:NO];
            [layout setRowInfo:ssn_layout_table_row(label.ssn_height) atRow:0];
            ssn_layout_add_v2(layout, label, 0, ssn_layout_table_cell_v2(SSNUIContentModeCenter), title);
            
            label = [UILabel ssn_labelWithWidth:backgroud.ssn_width - (cn_left_edge_width + cn_right_edge_width)
                                           font:cn_title_font
                                          color:cn_text_normal_color
                                      backgroud:[UIColor clearColor]
                                      alignment:NSTextAlignmentLeft
                                      multiLine:NO];
            ssn_layout_add_v2(layout, label, 1, ssn_layout_table_cell_v2(SSNUIContentModeCenter), content);
            
            UIButton *btn = [UIButton cn_normal_button];
            btn.ssn_normalTitle = cn_localized(@"common.submit.button");
            [btn ssn_addTarget:self touchAction:@selector(doneAction:)];
            btn.ssn_width = backgroud.ssn_width - (cn_left_edge_width + cn_right_edge_width);
            
            [layout setRowInfo:ssn_layout_table_row(btn.ssn_height) atRow:2];
            ssn_layout_add_v2(layout, btn, 2, ssn_layout_table_cell_v2(SSNUIContentModeCenter), done);
        }
        
        self.bottomPanel.hidden = YES;
        
    }
    
    return _bottomPanel;
}

- (void)showBottomPanelWithTitle:(NSString *)title detail:(NSString *)detail {
    if (self.bottomPanel.hidden) {
        self.bottomPanel.ssn_bottom = self.view.ssn_bottom - cn_bottom_edge_height;
        self.bottomPanel.ssn_center_x = ssn_center(self.view.bounds).x;
        [self.view addSubview:self.bottomPanel];
        
        _bottomPanel.hidden = NO;
    }
    
    UIView *backgroud = ssn_panel_get(UIView, _bottomPanel, backgroud);
    
    UILabel *label = ssn_panel_get(UILabel, backgroud, title);
    label.text = title;
    
    label = ssn_panel_get(UILabel, backgroud, content);
    label.text = detail;
}

- (void)dismissBottomPanel {
    _bottomPanel.hidden = YES;
}

- (UITableView *)searchTable {
    if (_searchTable) {
        return _searchTable;
    }
    
    CGRect frame = CGRectMake(0, 0, self.view.ssn_width, 200);
    _searchTable = [[UITableView alloc] initWithFrame:frame];
    _searchTable.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    
//    _searchConfigurator = [[SSNTableViewConfigurator alloc] init];
//    _searchConfigurator.delegate = self;
//    _searchConfigurator.tableView = _searchTable.table;
//    _searchConfigurator.listFetchController.isMandatorySorting = YES;
    
    return _searchTable;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = cn_localized(@"location.header.title");
    
    if ([self.addrtitle length] == 0) {
        self.addrtitle = cn_localized(@"location.selected.button");
    }
    
    _searchPoints = [NSMutableArray array];
    _pointAnnotations = [NSMutableArray array];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:cn_localized(@"common.submit.button") style:UIBarButtonItemStylePlain target:self action:@selector(listViewAction:)];
    
    _mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_mapView];
    
    //    UISearchController
    self.searchBar = [[UISearchBar alloc] init];
    [self.searchBar sizeToFit];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = cn_localized(@"friends.search.placeholder");
    self.searchBar.backgroundImage = [UIImage ssn_imageWithColor:cn_bar_color];
    self.searchBar.searchBarStyle = UISearchBarStyleProminent;
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.searchBar];
    
    //加载经纬度
    [self loadCoor];
}

- (void)loadCoor {
    if ([_addrdes length] > 0) {
        
        if (_longitude != 0 && _latitude != 0) {
            self.coor = CLLocationCoordinate2DMake(_latitude, _longitude);
            [self showAnnotationsWithZoom:0.04f];
        }
        else {
            __weak typeof(self) w_self = self;
            [[CNBMKMapDelegate delegate] geoCodeWithAddress:_addrdes city:_addr.city completion:^(CLLocationCoordinate2D coor, NSError *error) {
                __strong typeof(w_self) self = w_self;
                self.coor = coor;
                [self showAnnotationsWithZoom:0.04f];
            }];
        }
    }
    else {
        __weak typeof(self) w_self = self;
        [[CNBMKMapDelegate delegate] locationWithCopletion:^(CLLocationCoordinate2D coor, NSError *error) {
            __strong typeof(w_self) self = w_self;
            
            self.coor = coor;
            [self showAnnotationsWithZoom:0.04f];
        }];
    }
}

- (void)listViewAction:(id)sender {
    
}

- (void)doneAction:(id)sender {
    if ([_addrdes length] == 0) {
        [self ssn_showToast:cn_localized(@"location.select.error")];
        return ;
    }
    
    if ([_url length]) {
        NSMutableDictionary*query = [NSMutableDictionary dictionaryWithCapacity:4];
        [query setValue:_addrdes forKey:@"addrdes"];
        [query setValue:_addr forKey:@"addr"];
        [query setValue:@(_coor.longitude) forKey:@"longitude"];
        [query setValue:@(_coor.latitude) forKey:@"latitude"];
        [self.ssn_router noticeURL:[NSURL URLWithString:_url] query:query];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    
    NSLog(@"<<<<<<%f,%f>>>>>>>",cn_screen_height,self.view.ssn_height);
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
}

- (void)dealloc {
    if (_mapView) {
        _mapView = nil;
    }
}
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

#pragma mark - UISearchBarDelegate
- (void)delaySearch {
    NSString *city = _addr.city;
    if (![city ssn_non_empty]) {
        city = @"上海";
    }
    
    __weak typeof(self) w_self = self;
    [[CNBMKMapDelegate delegate] pointsSearchWithCity:city searchText:_searchBar.text pageIndex:0 pageSize:10 completion:^(NSArray *list, NSError *error) {
        __strong typeof(w_self) self = w_self;
        if (list) {
            [self.searchPoints setArray:list];
            
            if (self.pointAnnotations) {
                [self.pointAnnotations removeObject:self.pointAnnotation];//选中不需要移除
                [self->_mapView removeAnnotations:self.pointAnnotations];
                [self.pointAnnotations removeAllObjects];
            }
            
            //显示新的气泡
            [self.searchPoints enumerateObjectsUsingBlock:^(CNLocationPoint *point, NSUInteger idx, BOOL *stop) {
                NSString *subtitle = [NSString stringWithFormat:@"%@%@",point.name,point.address];
                BMKPointAnnotation *annotation = [self loadPointAnnotationWithTitle:self.addrtitle subTitle:subtitle coor:point.pt];
                [self.pointAnnotations addObject:annotation];
                
                if (idx == 0) {
                    if (self.pointAnnotation) {
                        [self->_mapView removeAnnotation:self.pointAnnotation];
                    }
                    self.coor = point.pt;
                    self.pointAnnotation = annotation;
                    [self showAnnotationsWithZoom:0];
                }
            }];
            
            [self->_mapView addAnnotations:self.pointAnnotations];
        }
    }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delaySearch) object:nil];
    if ([searchText length] > 0) {
        [self performSelector:@selector(delaySearch) withObject:nil afterDelay:1.5];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    searchBar.showsCancelButton = YES;
    for (UIView *v in searchBar.subviews) {
        for (UIView *sbv in v.subviews) {
            if ([sbv isKindOfClass:[UIButton class]]) {
                [(UIButton *)sbv setSsn_normalTitleColor:cn_button_title_color];
            }
        }
    }
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delaySearch) object:nil];
    searchBar.showsCancelButton = NO;
    searchBar.text = nil;
    [searchBar resignFirstResponder];

    
    if (self.pointAnnotations) {
        [self.pointAnnotations enumerateObjectsUsingBlock:^(BMKPointAnnotation *annotation, NSUInteger idx, BOOL *stop) {
            if (annotation != self.pointAnnotation) {
                [self->_mapView removeAnnotation:annotation];
            }
        }];
        
        [self.pointAnnotations removeAllObjects];
    }
    [self.searchPoints removeAllObjects];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delaySearch) object:nil];
    if ([searchBar.text length] > 0) {
        [self performSelector:@selector(delaySearch) withObject:nil afterDelay:0.1];
    }
    [searchBar resignFirstResponder];
}

//
//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
//    self.searchTable.hidden = YES;
//    [self.searchTable removeFromSuperview];
//
//    searchBar.showsCancelButton = NO;
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
//    [searchBar resignFirstResponder];
//}

#pragma mark - page url
//是否可以响应，默认返回NO，已存在界面如果可以响应，将重新被打开
- (BOOL)ssn_canRespondURL:(NSURL *)url query:(NSDictionary *)query {
    return YES;
}

- (void)ssn_handleOpenURL:(NSURL *)url query:(NSDictionary *)query {
    self.addrtitle = [query objectForKey:@"addrtitle"];
    self.addrdes = [query objectForKey:@"addrdes"];
    self.addr = [query objectForKey:@"addr"];
    self.longitude = [[query objectForKey:@"longitude"] floatValue];//经度
    self.latitude = [[query objectForKey:@"latitude"] floatValue];//纬度
    self.url = [[query objectForKey:@"url"] ssn_urlDecode];
}

#pragma mark - BMKMapViewDelegate
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    SSNLog(@"BMKMapView控件初始化完成");
}

- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate {
    _coor = coordinate;
    
    SSNLog(@"选择精度维度%f,%f",_coor.longitude,_coor.latitude);
    [self showAnnotationsWithZoom:0];
}

- (void)mapview:(BMKMapView *)mapView onDoubleClick:(CLLocationCoordinate2D)coordinate {
    NSLog(@"map view: double click");
//    [self dismissBottomPanel];
}

#pragma mark 添加标注

- (BMKPointAnnotation *)loadPointAnnotationWithTitle:(NSString *)title subTitle:(NSString *)subTitle coor:(CLLocationCoordinate2D)coor {
    
    BMKPointAnnotation *point = [[BMKPointAnnotation alloc]init];
    point.title = self.addrtitle;
    point.subtitle = self.addrdes;
    point.coordinate = coor;
    
    return point;
}

- (void)showAnnotationsWithZoom:(CGFloat)zoom {
    if (_pointAnnotation == nil) {
        _pointAnnotation = [self loadPointAnnotationWithTitle:self.addrtitle subTitle:self.addrdes coor:_coor];
    }
    _pointAnnotation.coordinate = _coor;
    [_mapView addAnnotation:_pointAnnotation];
    

    if (zoom > 0) {
        BMKCoordinateRegion region = BMKCoordinateRegionMake(_coor, BMKCoordinateSpanMake(zoom, zoom));
        [_mapView setRegion:region animated:YES];
    }
    else {
        [_mapView setCenterCoordinate:_coor animated:YES];
    }
    
    __weak typeof(self) w_self = self;
    [[CNBMKMapDelegate delegate] reverseGeoCodeWithLocationCoordinate:_coor completion:^(CNAddress *addr, NSString *addrDes, NSError *error) {
        __strong typeof(w_self) self = w_self;
        
        if (addr) {
            self.addr = addr;
            self.addrdes = addrDes;
            self.pointAnnotation.subtitle = addrDes;
            [self showBottomPanelWithTitle:_pointAnnotation.title detail:addrDes];
        }
    }];
}

// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    NSString *AnnotationViewID = @"renameMark";
    BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        // 设置颜色
        annotationView.pinColor = BMKPinAnnotationColorPurple;
        // 从天上掉下效果
//        annotationView.animatesDrop = YES;
        // 设置可拖拽
        annotationView.draggable = YES;
        annotationView.canShowCallout = NO;
    }
    return annotationView;
    
}

/**
 *当选中一个annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 选中的annotation views
 */
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
    SSNLog(@"didSelectAnnotationView");
    if (view.annotation == _pointAnnotation) {
        return ;
    }
    
    _coor = view.annotation.coordinate;
//    if (_pointAnnotation) {
//        [mapView removeAnnotation:_pointAnnotation];
//    }
    if ([view.annotation isKindOfClass:[BMKPointAnnotation class]]) {
        _pointAnnotation = view.annotation;
    }
    else {
        _pointAnnotation = [self loadPointAnnotationWithTitle:self.addrtitle subTitle:view.annotation.subtitle coor:_coor];
    }
    [self showAnnotationsWithZoom:0];
//    [self showBottomPanelWithTitle:view.annotation.title detail:view.annotation.subtitle];
}

// 当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view
{
    SSNLog(@"paopaoclick");
}

/**
 *拖动annotation view时，若view的状态发生变化，会调用此函数。ios3.2以后支持
 *@param mapView 地图View
 *@param view annotation view
 *@param newState 新状态
 *@param oldState 旧状态
 */
- (void)mapView:(BMKMapView *)mapView annotationView:(BMKAnnotationView *)view didChangeDragState:(BMKAnnotationViewDragState)newState
   fromOldState:(BMKAnnotationViewDragState)oldState {
    SSNLog(@"didChangeDragState:");
    //if dragging ended
    if (oldState == BMKAnnotationViewDragStateDragging && newState == BMKAnnotationViewDragStateEnding) {
        
        CLLocationCoordinate2D location;
        location.latitude = view.annotation.coordinate.latitude;
        location.longitude = view.annotation.coordinate.longitude;
        _coor = location;
        
        SSNLog(@"选择精度维度%f,%f",_coor.longitude,_coor.latitude);
        [self showAnnotationsWithZoom:0];
    }

}

@end
