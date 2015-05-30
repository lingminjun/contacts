//
//  CNQuestionViewController.m
//  contacts
//
//  Created by lingminjun on 15/5/31.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNQuestionViewController.h"
#import "CNIconTitleCell.h"

@interface CNQuestionViewController ()

@end

@implementation CNQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = cn_localized(@"setting.question.title");
    
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
    cell.title = cn_localized(@"question.what.pengyou.label");
    [models addObject:cell];
    
    cell = [[CNIconTitleCellModel alloc] init];
    cell.title = cn_localized(@"question.how.safety.label");
    [models addObject:cell];
    
    
    cell = [[CNIconTitleCellModel alloc] init];
    cell.title = cn_localized(@"question.info.disclosure.label");
    [models addObject:cell];
    
    
    completion(models,NO,nil,YES);
}


//当cell选中时
- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator tableView:(UITableView *)tableView didSelectModel:(CNIconTitleCellModel *)model atIndexPath:(NSIndexPath *)indexPath {
    if (![model isKindOfClass:[CNIconTitleCellModel class]]) {
        return ;
    }
    
    //进入地图选择
    NSDictionary *query = nil;
    if ([model.title isEqualToString:cn_localized(@"question.what.pengyou.label")]) {
        query = @{@"answer":cn_localized(@"question.what.pengyou.answer")};
    }
    else if ([model.title isEqualToString:cn_localized(@"question.how.safety.label")]) {
        query = @{@"answer":cn_localized(@"question.how.safety.answer")};
    }
    else if ([model.title isEqualToString:cn_localized(@"question.info.disclosure.label")]) {
        query = @{@"answer":cn_localized(@"question.info.disclosure.answer")};
        
    }
    [self.ssn_router open:cn_combine_path(@"nav/answer") query:query];
}


@end
