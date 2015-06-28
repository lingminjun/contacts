//
//  CNNearbyViewController.m
//  contacts
//
//  Created by lingminjun on 15/5/24.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNNearbyViewController.h"
#import <BaiduMapAPI/BMapKit.h>
#import "CNNearbyServer.h"

@interface CNNearbyViewController ()<BMKMapViewDelegate,UIGestureRecognizerDelegate>
{
}

@property (nonatomic,strong) BMKMapView *mapView;

@property (nonatomic,strong) BMKPointAnnotation *pointAnnotation;//选中
@property (nonatomic) CLLocationCoordinate2D coor;//选中

@property (nonatomic,strong) NSMutableArray *nearbyPersons;//附近的小伙伴
@property (nonatomic,strong) NSMutableArray *annotations;//附近的小伙伴

@property (nonatomic,strong) UIView *bottomPanel;//显示选中地址信息

@end

@implementation CNNearbyViewController

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
            
            UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, backgroud.ssn_width - (cn_left_edge_width + cn_right_edge_width), 30)];
            {
                int local_width = 100;
                SSNUITableLayout *ly = [topView ssn_tableLayoutWithRowCount:1 columnCount:2];
                [ly setColumnInfo:ssn_layout_table_column_v2(local_width) atColumn:1];
                
                UILabel *label = [UILabel ssn_labelWithWidth:topView.ssn_width - local_width
                                                        font:cn_normal_font
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
                ssn_layout_add_v2(ly, label, 0, ssn_layout_table_cell_v2(SSNUIContentModeCenter), distance);
            }
            ssn_layout_add_v2(layout, topView, 0, ssn_layout_table_cell_v2(SSNUIContentModeCenter), topView);
            
            UILabel *label = [UILabel ssn_labelWithWidth:backgroud.ssn_width - (cn_left_edge_width + cn_right_edge_width)
                                                    font:cn_title_font
                                                   color:cn_text_normal_color
                                               backgroud:[UIColor clearColor]
                                               alignment:NSTextAlignmentLeft
                                               multiLine:NO];
            ssn_layout_add_v2(layout, label, 1, ssn_layout_table_cell_v2(SSNUIContentModeCenter), content);
            
            UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, backgroud.ssn_width - (cn_left_edge_width + cn_right_edge_width), 40)];
            {
                int btn_width = 100;
                SSNUITableLayout *ly = [topView ssn_tableLayoutWithRowCount:1 columnCount:3];
                [ly setColumnInfo:ssn_layout_table_column_v2(1) atColumn:1];

                UIButton *btn = [UIButton cn_normal_button];
                btn.ssn_normalTitle = cn_localized(@"common.submit.button");
                [btn ssn_addTarget:self touchAction:@selector(doneAction:)];
                btn.ssn_width = backgroud.ssn_width - (cn_left_edge_width + cn_right_edge_width);
            }
            
            [layout setRowInfo:ssn_layout_table_row(bottomView.ssn_height) atRow:2];
            ssn_layout_add_v2(layout, bottomView, 2, ssn_layout_table_cell_v2(SSNUIContentModeCenter), bottomView);
        }
        
        self.bottomPanel.hidden = YES;
        
    }
    
    return _bottomPanel;
}

- (void)showBottomPanelWithTitle:(NSString *)title detail:(NSString *)detail {
    if (self.bottomPanel.hidden) {
        self.bottomPanel.ssn_bottom = self.view.bounds.size.height - cn_bottom_edge_height;
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


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = cn_localized(@"nearby.header.title");
    self.tabBarItem.image = cn_image(@"icon_nearby_normal");
    self.tabBarItem.selectedImage = cn_image(@"icon_nearby_selected");
    
    _nearbyPersons = [[NSMutableArray alloc] initWithCapacity:1];
    
    
    _mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_mapView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
    annotationView.canShowCallout = NO;
    annotationView.draggable = NO;
    
    return annotationView;
}
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    //展示
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
