//
//  CNFriendsViewController.m
//  contacts
//
//  Created by lingminjun on 15/5/24.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNFriendsViewController.h"
#import "CNPersonCell.h"
#import "CNContactsSection.h"

@interface CNFriendsViewController ()<SSNDBFetchControllerDelegate,UISearchBarDelegate,UISearchDisplayDelegate>

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) SSNDBFetchController *dbFetchController;

@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic,strong) UITableView *searchTable;
@property (nonatomic,strong) SSNDBFetchController *searchFetchController;
@property (nonatomic,strong) SSNTableViewConfigurator *searchConfigurator;
@property (nonatomic) BOOL isSearching;

@property (nonatomic,strong) UIView *noResultPlaceholder;

@property (nonatomic,strong) NSString *titleCount;

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
    fetch.predicate = [NSPredicate predicateWithFormat:@"%K!=%@",@"uid",[CNUserCenter center].currentUID];
    
    return [SSNDBFetchController fetchControllerWithDB:[CNUserCenter center].currentDatabase fetch:fetch];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = cn_localized(@"friends.header.title");
    self.tabBarItem.image = cn_image(@"icon_friends_normal");
    self.tabBarItem.selectedImage = cn_image(@"icon_friends_selected");
    
//    UISearchController 
    self.searchBar = [[UISearchBar alloc] init];
    [self.searchBar sizeToFit];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = cn_localized(@"friends.search.placeholder");
    self.searchBar.backgroundImage = [UIImage ssn_imageWithColor:cn_bar_color];
    self.searchBar.searchBarStyle = UISearchBarStyleProminent;
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cn_screen_width, cn_tool_bar_height)];
    self.headerView.backgroundColor = cn_bar_color;
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.headerView addSubview:self.searchBar];
    
    [self.view addSubview:self.headerView];
    self.tableView.ssn_top = self.headerView.ssn_bottom;
    self.tableView.ssn_height = self.view.bounds.size.height - self.headerView.ssn_height;
    self.tableView.sectionIndexBackgroundColor = [UIColor ssn_colorWithHex:0xcccccc alpha:0.2];
    
    //因为数据库fetch默认不支持分组，所以仅仅作为数据源
    self.dbFetchController = [self loadDBFetchController];
    self.dbFetchController.delegate = self;
    
    //用于界面显示数据
    [self.ssn_tableViewConfigurator configureWithTableView:self.tableView groupingFetchController:YES];//支持分组
    //快速索引
    self.ssn_tableViewConfigurator.showGroupIndexs = YES;
    self.ssn_tableViewConfigurator.listFetchController.isMandatorySorting = YES;
    
    //由数据库fetch发起
    [self.dbFetchController performFetch];
    
    //绑定标题
    [self boundTitleCount];
}

- (void)boundTitleCount {
    
    SSNDBTable *tb = [SSNDBTableManager personTable];
    
    NSString *sql = [NSString stringWithFormat:@"select count(*) AS count from %@ where uid <> '%@'",tb.name,[CNUserCenter center].currentUID];
    
    __weak typeof(self) w_self = self;
    [self ssn_boundTable:tb forSQL:sql tieField:@"titleCount" map:^id(SSNDBTable *table, NSString *sql, NSArray *changed_new_values) {
        __strong typeof(w_self) self = w_self;
        
        NSArray *sums = [changed_new_values valueForKey:@"count"];
        NSNumber *first = [sums firstObject];
        if ([first integerValue] > 0) {
            if (self.navigationItem.rightBarButtonItem == nil) {
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:cn_localized(@"friends.add.friend") style:UIBarButtonItemStylePlain target:self action:@selector(addPerson:)];
                self.parentViewController.navigationItem.rightBarButtonItem = self.navigationItem.rightBarButtonItem;
            }
            [self.noResultPlaceholder removeFromSuperview];
            return [NSString stringWithFormat:cn_localized(@"friends.header.title.format"),first];
        }
        else {
            self.navigationItem.rightBarButtonItem = nil;
            [self.view addSubview:self.noResultPlaceholder];
            return cn_localized(@"friends.header.title");
        }
    }];
}

- (UITableView *)tableView {
    if (_tableView) {
        return _tableView;
    }
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    return _tableView;
}

- (UITableView *)searchTable {
    if (_searchTable) {
        return _searchTable;
    }
    
    CGRect frame = self.view.bounds;
    frame.origin.y = cn_tool_bar_height + cn_status_bar_height;
    frame.size.height = self.view.bounds.size.height - frame.origin.y;
    _searchTable = [[UITableView alloc] initWithFrame:frame];
    _searchTable.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    SSNDBLikeFetch *fetch = [SSNDBLikeFetch fetchWithEntity:[CNPerson class] fromTable:NSStringFromClass([CNPerson class])];
    fetch.searchText = @"";
    fetch.fields = @[@"name",@"pinyin",@"mobile"];
    fetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"pinyin" ascending:YES]];
    fetch.predicate = [NSPredicate predicateWithFormat:@"%K!=%@",@"uid",[CNUserCenter center].currentUID];
    _searchFetchController = [SSNDBFetchController fetchControllerWithDB:[CNUserCenter center].currentDatabase fetch:fetch];
    _searchFetchController.delegate = self;
    
    _searchConfigurator = [[SSNTableViewConfigurator alloc] init];
    _searchConfigurator.delegate = self;
    _searchConfigurator.tableView = _searchTable;
    _searchConfigurator.listFetchController.isMandatorySorting = YES;
    
    return _searchTable;
}

- (UIView *)noResultPlaceholder {
    if (_noResultPlaceholder) {
        return _noResultPlaceholder;
    }
    _noResultPlaceholder = [[UIView alloc] initWithFrame:self.view.bounds];
    _noResultPlaceholder.ssn_top = _headerView.ssn_bottom;
    _noResultPlaceholder.ssn_height = self.view.bounds.size.height - _headerView.ssn_height;
    _noResultPlaceholder.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    {
        UIImageView *icon = [UIImageView ssn_imageViewWithImage:cn_image(@"no_friends_icon")];
        
        UIButton *btn = [UIButton cn_normal_button];
        btn.ssn_normalTitle = cn_localized(@"friends.add.friend.tip");
        [btn ssn_addTarget:self touchAction:@selector(addPerson:)];
        
        SSNUIFlowLayout *layout = [_noResultPlaceholder ssn_flowLayoutWithRowCount:1 spacing:cn_ver_space_height];
        layout.orientation = SSNUILayoutOrientationLandscapeLeft;
        layout.contentInset = UIEdgeInsetsMake(0, 0, cn_tab_bar_height, 0);
        layout.contentMode = SSNUIContentModeCenter;
        ssn_layout_add(layout, icon, 0, icon);
        ssn_layout_add(layout, btn, 1, btn);
    }
    return _noResultPlaceholder;
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
    
    //本地通讯录服务
    if ([CNUserCenter center].isSign && ![SSNABContactsManager manager].isOpenService) {
        [[SSNABContactsManager manager] openService];
    }
    
    if (_isSearching) {
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    }
    else {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
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
    if (controller == _searchFetchController) {
        [self.searchConfigurator.listFetchController loadData];
    }
    else {
        [self.ssn_tableViewConfigurator.listFetchController loadData];//连带界面数据重构
    }
}

#pragma mark - SSNTableViewConfiguratorDelegate
//加载数据源
- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator controller:(id<SSNFetchControllerPrototol>)controller loadDataWithOffset:(NSUInteger)offset limit:(NSUInteger)limit userInfo:(NSDictionary *)userInfo completion:(void (^)(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished))completion {
    
    //已经有新的数据了
    NSArray *objs = nil;
    if (configurator == self.searchConfigurator) {
        objs = self.searchFetchController.objects;
    }
    else {
        objs = self.dbFetchController.objects;
    }
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:1];
    for (CNPerson *person in objs) {
        CNPersonCellModel *cellModel = [[CNPersonCellModel alloc] init];
        cellModel.person = person;
        [items addObject:cellModel];
    }
    completion(items,NO,nil,YES);
}

- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator tableView:(UITableView *)tableView didSelectModel:(CNPersonCellModel *)model atIndexPath:(NSIndexPath *)indexPath {
    if (![model isKindOfClass:[CNPersonCellModel class]]) {
        return ;
    }
    
    NSString *path = [NSString stringWithFormat:@"nav/detail?uid=%@",model.person.uid];
    [self.ssn_router open:cn_combine_path(path)];
}

- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator controller:(id<SSNFetchControllerPrototol>)controller sectionDidLoad:(SSNVMSectionInfo *)section sectionIdntify:(NSString *)identify {
    
    if (configurator == self.searchConfigurator) {
        return ;
    }
    
    //section需要排序
    if ([identify length] > 0) {
        unichar c = [identify characterAtIndex:0];
        if (c >= 'a' && c <='z') {
            section.sortIndex = c - 'a';
        }
        else if (c >= 'A' && c <= 'Z') {
            section.sortIndex = c;
        }
        else {
            section.sortIndex = '|';
        }
    }
    else {
        section.sortIndex = '|';
    }
    
    section.customHeaderView = [CNContactsSection sectionWithTitle:identify];
//    NSLog(@"section 需要排序 %@",identify);
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    SSNDBLikeFetch *fetch = (SSNDBLikeFetch *)self.searchFetchController.fetch;
    fetch.searchText = searchText;
    [self.searchFetchController setFetch:fetch];
    [self.searchFetchController performFetch];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    self.headerView.ssn_height = cn_tool_bar_height + cn_status_bar_height;
    self.tableView.ssn_top = self.headerView.ssn_bottom;
    self.tableView.ssn_height = self.view.ssn_height - self.headerView.ssn_height;
    
    self.searchTable.hidden = NO;
    [self.view addSubview:self.searchTable];
    SSNDBLikeFetch *fetch = (SSNDBLikeFetch *)self.searchFetchController.fetch;
    fetch.searchText = @"";
    [self.searchFetchController setFetch:fetch];
    [self.searchFetchController performFetch];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    _isSearching = YES;
    
    searchBar.showsCancelButton = YES;
//    for (UIView *v in searchBar.subviews) {
//        for (UIView *sbv in v.subviews) {
//            if ([sbv isKindOfClass:[UIButton class]]) {
//                [(UIButton *)sbv setSsn_normalTitleColor:cn_button_title_color];
//            }
//        }
//    }
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _isSearching = NO;
    self.searchTable.hidden = YES;
    [self.searchTable removeFromSuperview];

    searchBar.showsCancelButton = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.headerView.ssn_height = cn_tool_bar_height;
    self.tableView.ssn_top = self.headerView.ssn_bottom;
    self.tableView.ssn_height = self.view.ssn_height - self.headerView.ssn_height;
    
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

#pragma mark - SSNPage
- (BOOL)ssn_canRespondURL:(NSURL *)url query:(NSDictionary *)query {
    return YES;
}

@end
