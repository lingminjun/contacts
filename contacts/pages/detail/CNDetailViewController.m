//
//  CNDetailViewController.m
//  contacts
//
//  Created by lingminjun on 15/5/24.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNDetailViewController.h"

NSString *const CN_DETAIL_SET_USER_OPTION = @"setuser";
NSString *const CN_DETAIL_ADD_FRIEND_OPTION = @"addfriend";

@interface CNDetailViewController ()

@end

@implementation CNDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([_uid length] == 0) {
        _uid = [CNUserCenter uidGenerator];
    }
 
    if ([CN_DETAIL_SET_USER_OPTION isEqualToString:_option]) {
        self.title = cn_localized(@"user.header.title");
    }
    else {
        self.title = cn_localized(@"detail.header.title");
    }
    
    //配置table
    self.ssn_tableViewConfigurator.tableView = self.tableView;
    
    //开始加载数据
    [self.ssn_tableViewConfigurator.listFetchController loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([CN_DETAIL_SET_USER_OPTION isEqualToString:_option]) {//防止侧滑返回，因为必须设置自己的资料
        self.navigationItem.backBarButtonItem.enabled = NO;
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([CN_DETAIL_SET_USER_OPTION isEqualToString:_option]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
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

#pragma mark - SSNTableViewConfiguratorDelegate
//加载数据源
- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator controller:(id<SSNFetchControllerPrototol>)controller loadDataWithOffset:(NSUInteger)offset limit:(NSUInteger)limit userInfo:(NSDictionary *)userInfo completion:(void (^)(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished))completion {
    
    
    
}


//当cell选中时
- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator tableView:(UITableView *)tableView didSelectModel:(id<SSNCellModel>)model atIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark - SSNPage
- (void)ssn_handleOpenURL:(NSURL *)url query:(NSDictionary *)query {
    self.uid = [query objectForKey:@"uid"];
    self.option = [query objectForKey:@"option"];
}

- (BOOL)ssn_canRespondURL:(NSURL *)url query:(NSDictionary *)query {
    NSString *uid = [query objectForKey:@"uid"];
    return [_uid isEqualToString:uid];
}

@end
