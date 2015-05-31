//
//  CNDetailViewController.m
//  contacts
//
//  Created by lingminjun on 15/5/24.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNDetailViewController.h"
#import "CNLabelInputCell.h"
#import "CNGenderSelectionCell.h"

NSString *const CN_DETAIL_SET_USER_OPTION = @"setuser";
NSString *const CN_DETAIL_ADD_FRIEND_OPTION = @"addfriend";

@interface CNDetailViewController ()

@property (nonatomic,strong) CNPerson *person;

//本地通讯录选择
@property (nonatomic,strong) UITableView *selectedTable;
@property (nonatomic,strong) NSArray *selectPersons;

@end

@implementation CNDetailViewController

- (UITableView *)selectedTable {
    if (_selectedTable) {
        return _selectedTable;
    }
    
    _selectedTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.ssn_width - cn_left_edge_width - cn_right_edge_width, 0)];
    _selectedTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _selectedTable.backgroundColor = cn_text_assist_color;
    _selectedTable.delegate = self;
    _selectedTable.dataSource = self;
    _selectedTable.rowHeight = 40;
    
    return _selectedTable;
}

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
    
    if ([CN_DETAIL_SET_USER_OPTION isEqualToString:_option]) {//防止侧滑返回，因为必须设置自己的资料
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(emptyAction:)];
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:cn_localized(@"common.done.button") style:UIBarButtonItemStylePlain target:self action:@selector(doneAction:)];
    
    //配置table
    self.ssn_tableViewConfigurator.tableView = self.tableView;
    self.ssn_tableViewConfigurator.isWithoutAnimation = YES;
    
    //开始加载数据
    [self.ssn_tableViewConfigurator.listFetchController loadData];
}

- (void)emptyAction:(id)sender {
}

#define cn_index_path(row,section) [NSIndexPath indexPathForRow:(row) inSection:(section)]
- (void)doneAction:(id)sender {
    
    //check 名字
    CNLabelInputCellModel *nameCell = [self.ssn_tableViewConfigurator.listFetchController objectAtIndexPath:cn_index_path(0,0)];
    if ([[nameCell.input ssn_trimWhitespace] length] == 0) {
        [self ssn_showToast:cn_localized(@"user.name.input.tip")];
        return ;
    }
    
    CNGenderSelectionCellModel *gender = [self.ssn_tableViewConfigurator.listFetchController objectAtIndexPath:cn_index_path(1,0)];
    
    //check mobile
    CNLabelInputCellModel *mobileCell = [self.ssn_tableViewConfigurator.listFetchController objectAtIndexPath:cn_index_path(2,0)];
    if ([[mobileCell.input ssn_trimAllWhitespace] length] == 0) {
        [self ssn_showToast:cn_localized(@"user.mobile.input.tip")];
        return ;
    }
    
    //check home addr
    CNLabelInputCellModel *homeAddrCell = [self.ssn_tableViewConfigurator.listFetchController objectAtIndexPath:cn_index_path(3,0)];
    if ([[homeAddrCell.input ssn_trimWhitespace] length] == 0) {
        [self ssn_showToast:cn_localized(@"user.home.address.input.tip")];
        return ;
    }
    
    CNLabelInputCellModel *companyAddrCell = [self.ssn_tableViewConfigurator.listFetchController objectAtIndexPath:cn_index_path(4,0)];
    
    //取得界面输入数据
    _person.name = [nameCell.input ssn_trimWhitespace];
    _person.gender = gender.gender;
    _person.mobile = [mobileCell.input ssn_trimAllWhitespace];
    _person.homeAddress = [homeAddrCell.input ssn_trimWhitespace];
    _person.companyAddress = [companyAddrCell.input ssn_trimWhitespace];
    
    if (![CNUserCenter center].isSign) {
        if ([CN_DETAIL_SET_USER_OPTION isEqualToString:_option]) {
            [[CNUserCenter center] signWithUID:_uid];
        }
    }
    
    //将数据保存到数据库
    SSNDBTable *tb = [SSNDBTableManager personTable];
    [tb upinsertObject:_person];
    
    //返回到上一个界面
    [self ssn_showToast:cn_localized(@"common.save.success")];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([CN_DETAIL_SET_USER_OPTION isEqualToString:_option]) {//防止侧滑返回，因为必须设置自己的资料
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

#pragma mark delegate
- (void)cellInputDidChange:(CNLabelInputCell *)cell {
    CNLabelInputCellModel *model = (CNLabelInputCellModel *)cell.ssn_cellModel;
    
    if (![model.title isEqualToString:cn_localized(@"user.name.label")]) {
        return ;
    }
    
//    if ([CN_DETAIL_SET_USER_OPTION isEqualToString:_option]) {
//        return ;
//    }
    
    //此时需呀开启搜索本地通讯录
    if (![SSNABContactsManager manager].isOpenService) {
        [[SSNABContactsManager manager] openService];
    }
    
    CGPoint point = cell.input.ssn_bottom_left_corner;
    point = [cell.input convertPoint:point toView:self.view.window];
    self.selectedTable.ssn_top = point.y;
    self.selectedTable.ssn_center_x = self.view.ssn_center_x;
    [self.view.window addSubview:self.selectedTable];
    [self ssn_mainThreadAfter:0.1 block:^{
        NSString *text = model.input;
        if ([text length] == 0) {
            self.selectedTable.hidden = YES;
            self.selectPersons = nil;
            [self.selectedTable reloadData];
        }
        else {
            self.selectedTable.hidden = NO;
            [[SSNABContactsManager manager] searchPersonsWithSearchText:text results:^(NSArray *results) {
                [self ssn_mainThreadAsyncBlock:^{
                    self.selectPersons = results;
                    [self.selectedTable reloadData];
                }];
            }];
        }
    }];
}

- (void)dealloc {
    [_selectedTable removeFromSuperview];
}

#pragma mark uitabledelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _selectedTable) {
        NSUInteger row_count = [self.selectPersons count];
        tableView.ssn_height = tableView.rowHeight * row_count;
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _selectedTable) {
        NSUInteger row_count = [self.selectPersons count];
//        tableView.ssn_height = tableView.rowHeight * row_count;
        return row_count;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    if (tableView == _selectedTable) {
        if (indexPath.row < [self.selectPersons count]) {
            SSNABPerson *abperson = [self.selectPersons objectAtIndex:indexPath.row];
            cell.textLabel.text = abperson.name;
            cell.textLabel.textColor = cn_table_cell_normal_color;
            cell.textLabel.font = cn_normal_font;
            
            cell.detailTextLabel.text = [abperson.mobile ssn_mobile344Format];
            cell.detailTextLabel.textColor = cn_table_cell_normal_color;
            cell.detailTextLabel.font = cn_normal_font;
            
            cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
            cell.backgroundView.backgroundColor = cn_text_assist_color;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == _selectedTable) {
        if (indexPath.row < [self.selectPersons count]) {
            SSNABPerson *abperson = [self.selectPersons objectAtIndex:indexPath.row];
            
            //check 名字
            CNLabelInputCellModel *nameCell = [self.ssn_tableViewConfigurator.listFetchController objectAtIndexPath:cn_index_path(0,0)];
            nameCell.input = abperson.name;
            
            //check mobile
            CNLabelInputCellModel *mobileCell = [self.ssn_tableViewConfigurator.listFetchController objectAtIndexPath:cn_index_path(2,0)];
            mobileCell.input = abperson.mobile;
            
            [self.ssn_tableViewConfigurator.listFetchController updateDatasAtIndexPaths:@[cn_index_path(0,0),cn_index_path(2,0)] withContext:nil];
            
            self.selectPersons = nil;
            self.selectedTable.hidden = YES;
            [self.selectedTable reloadData];
            
        }
    }
}


#pragma mark - SSNTableViewConfiguratorDelegate
//加载数据源
- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator controller:(id<SSNFetchControllerPrototol>)controller loadDataWithOffset:(NSUInteger)offset limit:(NSUInteger)limit userInfo:(NSDictionary *)userInfo completion:(void (^)(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished))completion {
    
    if (!_person) {
        SSNDBTable *tb = [SSNDBTableManager personTable];
        NSArray *ary = [tb objectsWithClass:[CNPerson class] forConditions:@{@"uid":_uid}];
        _person = [ary firstObject];
        
        //数据库还没有数据，提前产生副本
        if (!_person) {
            _person = [[CNPerson alloc] init];
            _person.uid = _uid;
        }
    }
    
    //构建cell
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:1];
    
    CNLabelInputCellModel *nameCell = [[CNLabelInputCellModel alloc] init];
    nameCell.title = cn_localized(@"user.name.label");
    nameCell.input = _person.name;
    nameCell.inputMaxLength = 10;
    nameCell.inputPlaceholder = cn_localized(@"user.name.placeholder");
    nameCell.disabledSelect = YES;
    [models addObject:nameCell];
    
    CNGenderSelectionCellModel *gender = [[CNGenderSelectionCellModel alloc] init];
    gender.title = cn_localized(@"user.gender.label");
    gender.gender = _person.gender;
    [models addObject:gender];
    
    CNLabelInputCellModel *mobileCell = [[CNLabelInputCellModel alloc] init];
    mobileCell.title = cn_localized(@"user.mobile.label");
    mobileCell.input = _person.mobile;
    mobileCell.inputMaxLength = 13;
    mobileCell.inputCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    mobileCell.inputFormat = ^(NSString *originText){ return [originText ssn_mobile344Format];};
    mobileCell.inputPlaceholder = cn_localized(@"user.mobile.placeholder");
    mobileCell.disabledSelect = YES;
    mobileCell.keyboardType = UIKeyboardTypePhonePad;
    [models addObject:mobileCell];
    
    CNLabelInputCellModel *homeAddrCell = [[CNLabelInputCellModel alloc] init];
    homeAddrCell.title = cn_localized(@"user.home.address.label");
    homeAddrCell.input = _person.homeAddress;
    homeAddrCell.inputPlaceholder = cn_localized(@"user.home.address.placeholder");
    homeAddrCell.subTitle = cn_localized(@"user.map.label");
    [models addObject:homeAddrCell];
    
    CNLabelInputCellModel *companyAddrCell = [[CNLabelInputCellModel alloc] init];
    companyAddrCell.title = cn_localized(@"user.company.address.label");
    companyAddrCell.input = _person.companyAddress;
    companyAddrCell.inputPlaceholder = cn_localized(@"user.company.address.placeholder");
    companyAddrCell.subTitle = cn_localized(@"user.map.label");
    [models addObject:companyAddrCell];
    
    completion(models,NO,nil,YES);
}


//当cell选中时
- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator tableView:(UITableView *)tableView didSelectModel:(CNLabelInputCellModel *)model atIndexPath:(NSIndexPath *)indexPath {
    if (![model isKindOfClass:[CNLabelInputCellModel class]]) {
        return ;
    }
    
    //进入地图选择
    if ([model.title isEqualToString:cn_localized(@"user.home.address.label")]) {
        [self.ssn_router open:cn_combine_path(@"nav/location")];
    }
    else if ([model.title isEqualToString:cn_localized(@"user.company.address.label")]) {
        [self.ssn_router open:cn_combine_path(@"nav/location")];
    }
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
