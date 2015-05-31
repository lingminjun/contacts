//
//  HTSettingViewController.m
//  hitaoq
//
//  Created by lingminjun on 15/5/13.
//  Copyright (c) 2015年 SSN. All rights reserved.
//

#import "CNSettingViewController.h"
#import "CNIconTitleCell.h"
#import "CNStatementCell.h"

@interface CNSettingViewController ()

@end

@implementation CNSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = cn_localized(@"setting.header.title");
    self.tabBarItem.image = cn_image(@"icon_setting_normal");
    self.tabBarItem.selectedImage = cn_image(@"icon_setting_selected");
    
    //配置table
    self.ssn_tableViewConfigurator.tableView = self.tableView;
    self.ssn_tableViewConfigurator.isWithoutAnimation = YES;
    [self.ssn_tableViewConfigurator.listFetchController loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SSNTableViewConfiguratorDelegate
//加载数据源
- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator controller:(id<SSNFetchControllerPrototol>)controller loadDataWithOffset:(NSUInteger)offset limit:(NSUInteger)limit userInfo:(NSDictionary *)userInfo completion:(void (^)(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished))completion {
    

    //构建cell
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:1];
    
    CNIconTitleCellModel *cell = nil;
    
    cell = [[CNIconTitleCellModel alloc] init];
    cell.iconName = @"icon_info";
    cell.title = cn_localized(@"setting.my.info.label");
    [models addObject:cell];
    
    cell = [[CNIconTitleCellModel alloc] init];
    cell.iconName = @"icon_question";
    cell.title = cn_localized(@"setting.question.label");
    [models addObject:cell];
    
    
    cell = [[CNIconTitleCellModel alloc] init];
    cell.iconName = @"icon_opinion";
    cell.title = cn_localized(@"setting.opinion.label");
    [models addObject:cell];
    
    cell = [[CNIconTitleCellModel alloc] init];
    cell.iconName = @"icon_info";
    cell.title = cn_localized(@"setting.about.label");
    cell.disabledSelect = YES;
    cell.hiddenDisclosureIndicator = YES;
    [models addObject:cell];
    
    
    CNStatementCellModel *state = [[CNStatementCellModel alloc] init];
    state.statement = cn_localized(@"setting.about.content");
    state.leftEdgeWidth = cn_left_edge_width + 26 + 2*cn_hor_space_width;
    [models addObject:state];
    
    completion(models,NO,nil,YES);
}


//当cell选中时
- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator tableView:(UITableView *)tableView didSelectModel:(CNIconTitleCellModel *)model atIndexPath:(NSIndexPath *)indexPath {
    if (![model isKindOfClass:[CNIconTitleCellModel class]]) {
        return ;
    }
    
    if ([model.title isEqualToString:cn_localized(@"setting.my.info.label")]) {
        [self.ssn_router open:cn_combine_path(@"nav/detail") query:@{@"uid":[CNUserCenter center].currentUID}];
    }
    else if ([model.title isEqualToString:cn_localized(@"setting.question.label")]) {
        [self.ssn_router open:cn_combine_path(@"nav/question")];
    }
    else if ([model.title isEqualToString:cn_localized(@"setting.opinion.label")]) {
        [self.ssn_router open:cn_combine_path(@"nav/opinion")];
    }
}


#pragma mark - SSNPage
- (BOOL)ssn_canRespondURL:(NSURL *)url query:(NSDictionary *)query {
    return YES;
}

@end
