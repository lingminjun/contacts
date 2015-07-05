//
//  CNNearbyListViewController.m
//  contacts
//
//  Created by y_liang on 15/7/5.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNNearbyListViewController.h"
#import "CNNearbyPersonCell.h"
#import <BaiduMapAPI/BMapKit.h>

@interface CNNearbyListViewController ()<CNNearbyPersonCellDelegate>

@property (nonatomic) CLLocationCoordinate2D here;//当前位置

@property (nonatomic,strong) CNPerson *selectdPerson;

@end

@implementation CNNearbyListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _results = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = cn_localized(@"nearby.header.title");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:cn_image(@"icon_me_location") style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    
    self.ssn_tableViewConfigurator.tableView = self.tableView;
    self.ssn_tableViewConfigurator.isAutoEnabledLoadMore = YES;//自动控制是否还有更多
    
    //开始加载数据
    [self.ssn_tableViewConfigurator.listFetchController loadData];
}

- (void)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SSNTableViewConfiguratorDelegate
//加载数据源
- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator controller:(id<SSNFetchControllerPrototol>)controller loadDataWithOffset:(NSUInteger)offset limit:(NSUInteger)limit userInfo:(NSDictionary *)userInfo completion:(void (^)(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished))completion {
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:1];
    for (CNPerson *person in self.results) {
        CNNearbyPersonCellModel *cellModel = [[CNNearbyPersonCellModel alloc] init];
        cellModel.person = person;
        [items addObject:cellModel];
    }
    completion(items,NO,nil,YES);
    
}




#pragma mark - page url
//是否可以响应，默认返回NO，已存在界面如果可以响应，将重新被打开
- (BOOL)ssn_canRespondURL:(NSURL *)url query:(NSDictionary *)query {
    return YES;
}

- (void)ssn_handleOpenURL:(NSURL *)url query:(NSDictionary *)query {
    NSArray *array = [query objectForKey:@"results"];
    if ([array count]) {
        [_results setArray:array];
    }
    
    double latitude = [[query objectForKey:@"latitude"] doubleValue];
    double longitude = [[query objectForKey:@"longitude"] doubleValue];
    
    self.here = CLLocationCoordinate2DMake(latitude, longitude);
}


#pragma mark - cell btn delegate

- (void)callAction:(CNNearbyPersonCell *)cell {
    
    self.selectdPerson = [(CNNearbyPersonCellModel *)cell.ssn_cellModel person];
    
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

- (void)gpsAction:(CNNearbyPersonCell *)cell {
    
    self.selectdPerson = [(CNNearbyPersonCellModel *)cell.ssn_cellModel person];
    
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

@end
