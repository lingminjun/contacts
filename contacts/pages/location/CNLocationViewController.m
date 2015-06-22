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
@property (nonatomic,strong) SSNHorizontalTable *searchTable;
@property (nonatomic,strong) NSMutableArray *searchPoints;
@property (nonatomic,strong) SSNTableViewConfigurator *searchConfigurator;

@end

@implementation CNLocationViewController

- (SSNHorizontalTable *)searchTable {
    if (_searchTable) {
        return _searchTable;
    }
    
    CGRect frame = CGRectMake(0, 0, self.view.ssn_width, 200);
    _searchTable = [[SSNHorizontalTable alloc] initWithFrame:frame];
    _searchTable.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    
    _searchConfigurator = [[SSNTableViewConfigurator alloc] init];
    _searchConfigurator.delegate = self;
    _searchConfigurator.tableView = _searchTable.table;
    _searchConfigurator.listFetchController.isMandatorySorting = YES;
    
    return _searchTable;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = cn_localized(@"location.header.title");
    
    if ([self.addrtitle length] == 0) {
        self.addrtitle = cn_localized(@"location.selected.button");
    }
    
    _searchPoints = [NSMutableArray array];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:cn_localized(@"common.submit.button") style:UIBarButtonItemStylePlain target:self action:@selector(doneAction:)];
    
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
    
    //底部的搜索table
    self.searchTable.ssn_bottom = self.view.ssn_bottom;
    self.searchTable.ssn_center_x = ssn_center(self.view.bounds).x;
    [self.view addSubview:self.searchTable];
    
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
    [[CNBMKMapDelegate delegate] pointsSearchWithCity:city searchText:_searchBar.text pageIndex:0 pageSize:20 completion:^(NSArray *list, NSError *error) {
        __strong typeof(w_self) self = w_self;
        [self.searchConfigurator.listFetchController loadData];
        if (list) {
            [self.searchPoints setArray:list];
        }
    }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delaySearch) object:nil];
    if ([searchText length] > 0) {
        [self performSelector:@selector(delaySearch) withObject:nil afterDelay:1];
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
    [searchBar resignFirstResponder];
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

#pragma mark - SSNTableViewConfiguratorDelegate
//加载数据源
- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator controller:(id<SSNFetchControllerPrototol>)controller loadDataWithOffset:(NSUInteger)offset limit:(NSUInteger)limit userInfo:(NSDictionary *)userInfo completion:(void (^)(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished))completion {
    
    //已经有新的数据了
    NSArray *objs = [_searchPoints copy];
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:1];
    for (CNLocationPoint *point in objs) {
        CNCellModel *model = [[CNCellModel alloc] init];
        model.cellClass = [SSNHorizontalTableCell class];
        model.cellHeight = cn_screen_width;
//        CNPersonCellModel *cellModel = [[CNPersonCellModel alloc] init];
//        cellModel.person = person;
        [items addObject:model];
    }
    
    completion(items,NO,nil,YES);
}


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
}

#pragma mark 添加标注

- (void)showAnnotationsWithZoom:(CGFloat)zoom {
    if (_pointAnnotation == nil) {
        _pointAnnotation = [[BMKPointAnnotation alloc]init];
        _pointAnnotation.title = self.addrtitle;
        _pointAnnotation.subtitle = self.addrdes;
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
    }
    return annotationView;
    
}

// 当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view;
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
