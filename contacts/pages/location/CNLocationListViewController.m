//
//  CNLocationListViewController.m
//  contacts
//
//  Created by lingminjun on 15/6/22.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNLocationListViewController.h"
#import "CNBMKMapDelegate.h"
#import "CNLocalPointCell.h"

@interface CNLocationListViewController ()

@property (nonatomic,strong) NSMutableArray *datas;
@property (nonatomic) NSInteger pageIndex;

@end

@implementation CNLocationListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _results = [NSMutableArray array];
        _datas = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [self.searchText length] > 0 ? self.searchText : cn_localized(@"location.list.header.title");
    
    //    self.tableView.ssn_loadMoreEnabled = YES;//上提更多
    
    self.ssn_tableViewConfigurator.tableView = self.tableView;
    self.ssn_tableViewConfigurator.isAutoEnabledLoadMore = YES;//自动控制是否还有更多
    
    //开始加载数据
    [self.ssn_tableViewConfigurator.listFetchController loadData];
    
}

#pragma mark - SSNTableViewConfiguratorDelegate
//加载数据源
- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator controller:(id<SSNFetchControllerPrototol>)controller loadDataWithOffset:(NSUInteger)offset limit:(NSUInteger)limit userInfo:(NSDictionary *)userInfo completion:(void (^)(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished))completion {
    
    
    if (offset == 0) {
        self.pageIndex = 0;
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:1];
        [self.datas setArray:self.results];
        for (CNLocationPoint *point in self.results) {
            CNLocalPointCellModel *cellModel = [[CNLocalPointCellModel alloc] init];
            cellModel.point = point;
            [items addObject:cellModel];
        }
        completion(items,[self.results count] > 10,nil,YES);
    }
    else {
        self.pageIndex = self.pageIndex + 1;
        [[CNBMKMapDelegate delegate] pointsSearchWithCity:self.city
                                                pointType:CNLocationNormalPoint
                                               searchText:self.searchText
                                                pageIndex:self.pageIndex
                                                 pageSize:10
                                               completion:^(NSArray *list, NSError *error) {
                                                   
                                                   NSMutableArray *items = [NSMutableArray arrayWithCapacity:1];
                                                   for (CNLocationPoint *point in self.results) {
                                                       CNLocalPointCellModel *cellModel = [[CNLocalPointCellModel alloc] init];
                                                       cellModel.point = point;
                                                       [items addObject:cellModel];
                                                   }
                                                   
                                                   if (limit) {
                                                       [self.datas addObjectsFromArray:list];
                                                   }
                                                   
                                                   completion(items,[list count] > 0,nil,NO);
                                               }];
    }
    
    
}

- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator tableView:(UITableView *)tableView didSelectModel:(CNLocalPointCellModel *)model atIndexPath:(NSIndexPath *)indexPath {
    if (![model isKindOfClass:[CNLocalPointCellModel class]]) {
        return ;
    }
    
    //进入地图选择
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    
    [dic setValue:self.datas forKey:@"results"];
    [dic setValue:model.point forKey:@"selectedPoint"];
    [dic setValue:@(YES) forKey:@"listCallback"];
    
    [self.ssn_router noticeURL:[NSURL URLWithString:cn_combine_path(@"nav/location")] query:dic];
    
    [self.ssn_router open:cn_combine_path(@"nav/location") query:dic];
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
    self.city = [query objectForKey:@"city"];
    self.searchText = [query objectForKey:@"searchText"];
}


@end
