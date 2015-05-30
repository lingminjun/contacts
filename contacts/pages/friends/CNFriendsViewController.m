//
//  CNFriendsViewController.m
//  contacts
//
//  Created by lingminjun on 15/5/24.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNFriendsViewController.h"
#import "CNPersonCell.h"

@interface CNFriendsViewController ()<SSNDBFetchControllerDelegate>

@property (nonatomic,strong) SSNDBFetchController *dbFetchController;

@end

@implementation CNFriendsViewController

- (SSNDBFetchController *)loadDBFetchController {
    
    SSNDBTable *tb = [SSNDBTableManager personTable];
    if (!tb) {
        return nil;
    }
    
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"pinyin" ascending:YES];
    
    //非级联测试
    SSNDBFetch *fetch = [SSNDBFetch fetchWithEntity:[CNPerson class] sortDescriptors:@[ sort1 ] predicate:nil offset:0 limit:0 fromTable:NSStringFromClass([CNPerson class])];
    
    return [SSNDBFetchController fetchControllerWithDB:[CNUserCenter center].currentDatabase fetch:fetch];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = cn_localized(@"friends.header.title");
    self.tabBarItem.image = cn_image(@"icon_friends_normal");
    self.tabBarItem.selectedImage = cn_image(@"icon_friends_selected");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addPerson:)];
    
    //因为数据库fetch默认不支持分组，所以仅仅作为数据源
    self.dbFetchController = [self loadDBFetchController];
    self.dbFetchController.delegate = self;
    
    //用于界面显示数据
    [self.ssn_tableViewConfigurator configureWithTableView:self.tableView groupingFetchController:YES];//支持分组
    
    //由数据库fetch发起
    [self.dbFetchController performFetch];
}

- (void)addPerson:(id)sender {
    [self.ssn_router open:cn_combine_path(@"nav/detail?option=addfriend")];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (nil == _dbFetchController) {//第一次可能还没有创建用户
        self.dbFetchController = [self loadDBFetchController];
        self.dbFetchController.delegate = self;
        [self.dbFetchController performFetch];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark SSNDBFetchControllerDelegate
- (void)ssndb_controller:(SSNDBFetchController *)controller didChangeObject:(id)object atIndex:(NSUInteger)index forChangeType:(SSNDBFetchedChangeType)type newIndex:(NSUInteger)newIndex {
    
}


- (void)ssndb_controllerWillChange:(SSNDBFetchController *)controller {
    
}


- (void)ssndb_controllerDidChange:(SSNDBFetchController *)controller {
    [self.ssn_tableViewConfigurator.listFetchController loadData];//连带界面数据重构
}

#pragma mark - SSNTableViewConfiguratorDelegate
//加载数据源
- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator controller:(id<SSNFetchControllerPrototol>)controller loadDataWithOffset:(NSUInteger)offset limit:(NSUInteger)limit userInfo:(NSDictionary *)userInfo completion:(void (^)(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished))completion {
    
    //已经有新的数据了
    NSArray *objs = self.dbFetchController.objects;
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:1];
    for (CNPerson *person in objs) {
        CNPersonCellModel *cellModel = [[CNPersonCellModel alloc] init];
        cellModel.person = person;
        [items addObject:cellModel];
    }
    
    completion(items,NO,nil,YES);
}

#pragma mark - SSNPage
- (BOOL)ssn_canRespondURL:(NSURL *)url query:(NSDictionary *)query {
    return YES;
}

@end
