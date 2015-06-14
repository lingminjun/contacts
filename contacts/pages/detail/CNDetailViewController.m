//
//  CNDetailViewController.m
//  contacts
//
//  Created by lingminjun on 15/5/24.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNDetailViewController.h"
#import "CNLabelInputCell.h"
#import "CNSelectionCell.h"
#import "CNSectionCell.h"
#import "CNLabelCell.h"
#import "CNUserHeaderCell.h"

NSString *const CN_DETAIL_SET_USER_OPTION = @"setuser";
NSString *const CN_DETAIL_ADD_FRIEND_OPTION = @"addfriend";

@interface CNDetailViewController ()

@property (nonatomic,strong) CNPerson *person;

@property (nonatomic,strong) NSArray *items;
@property (nonatomic,strong) CNLabelInputCellModel *streetAddrCell;
@property (nonatomic,strong) CNLabelInputCellModel *addressDetailCell;

//本地通讯录选择
@property (nonatomic,strong) UITableView *selectedTable;
@property (nonatomic,strong) NSArray *selectPersons;
@property (nonatomic,strong) CNLabelInputCellModel *selectItem;

@property (nonatomic) CLLocationCoordinate2D homeCoor;
@property (nonatomic) CLLocationCoordinate2D companyCoor;

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
    
    CNSelectionCellModel *gender = [self.ssn_tableViewConfigurator.listFetchController objectAtIndexPath:cn_index_path(1,0)];
    
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
    _person.gender = gender.value == 0 ? CNPersonMaleGender : CNPersonFemaleGender;
    _person.mobile = [mobileCell.input ssn_trimAllWhitespace];
    NSString *homeAddr = [homeAddrCell.input ssn_trimWhitespace];
//    if (!ssn_is_equal_to_string(_person.homeAddress, homeAddr)) {
//        _person.homeLongitude = _homeCoor.longitude;
//        _person.homeLatitude = _homeCoor.latitude;
//        _person.homeAddress = homeAddr;
//        
//        NSString *auid = _uid;
//        if ([homeAddr length] > 0 && _homeCoor.longitude == 0.0f) {
//            [[CNBMKMapDelegate delegate] geoCodeWithAddress:homeAddr city:nil completion:^(CLLocationCoordinate2D coor, NSError *error) {
//                
//                if (!error) {
//                    //将数据保存到数据库
//                    SSNDBTable *tb = [SSNDBTableManager personTable];
//                    NSArray *ary = [tb objectsWithClass:[CNPerson class] forConditions:@{@"uid":auid}];
//                    CNPerson *pn = [ary firstObject];
//                    pn.homeLatitude = coor.latitude;
//                    pn.homeLongitude = coor.longitude;
//                    
//                    [tb upinsertObject:pn fields:@[@"homeLatitude",@"homeLongitude"]];
//                }
//                
//            }];
//        }
//    }
    
    NSString *companyAddr = [companyAddrCell.input ssn_trimWhitespace];
//    if (!ssn_is_equal_to_string(_person.companyAddress, companyAddr)) {
//        _person.companyLongitude = _companyCoor.longitude;
//        _person.companyLatitude = _companyCoor.latitude;
//        _person.companyAddress = companyAddr;
//        
//        NSString *auid = _uid;
//        if ([companyAddr length] > 0 && _companyCoor.longitude == 0.0f) {
//            [[CNBMKMapDelegate delegate] geoCodeWithAddress:homeAddr city:nil completion:^(CLLocationCoordinate2D coor, NSError *error) {
//                
//                if (!error) {
//                    //将数据保存到数据库
//                    SSNDBTable *tb = [SSNDBTableManager personTable];
//                    NSArray *ary = [tb objectsWithClass:[CNPerson class] forConditions:@{@"uid":auid}];
//                    CNPerson *pn = [ary firstObject];
//                    pn.companyLatitude = coor.latitude;
//                    pn.companyLongitude = coor.longitude;
//                    
//                    [tb upinsertObject:pn fields:@[@"companyLatitude",@"companyLongitude"]];
//                }
//                
//            }];
//        }
//    }
    
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

- (void)dealloc {
    [_selectedTable removeFromSuperview];
}

#pragma mark delegate
- (void)cellInputDidChange:(CNLabelInputCell *)cell {
    CNLabelInputCellModel *model = (CNLabelInputCellModel *)cell.ssn_cellModel;
    
    if ([model.title isEqualToString:cn_localized(@"user.name.label")]) {
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
    else if ([model.title isEqualToString:cn_localized(@"user.home.address.label")]) {
        _homeCoor.latitude = 0.0f;
        _homeCoor.longitude = 0.0f;
    }
    else if ([model.title isEqualToString:cn_localized(@"user.company.address.label")]) {
        _companyCoor.latitude = 0.0f;
        _companyCoor.longitude = 0.0f;
    }
    
}

- (void)cellRadioDidSelect:(CNSelectionCell *)cell {
    CNSelectionCellModel *model = (CNSelectionCellModel *)cell.ssn_cellModel;
    if (![model.title isEqualToString:cn_localized(@"user.address.type.label")]) {
        return ;
    }
    if (model.value == 0) {
        _person.addressLabel = CNHomeAddressLabel;
    }
    else {
        _person.addressLabel = CNCompanyAddressLabel;
    }
    
    _streetAddrCell.title = (_person.addressLabel == CNHomeAddressLabel?cn_localized(@"user.biotope.label"):cn_localized(@"user.building.label"));
    _streetAddrCell.input = _person.street;
    _streetAddrCell.inputPlaceholder = (_person.addressLabel == CNHomeAddressLabel?cn_localized(@"user.biotope.placeholder"):cn_localized(@"user.building.placeholder"));
    _streetAddrCell.subTitle = cn_localized(@"user.map.label");
    
    _addressDetailCell.title = (_person.addressLabel == CNHomeAddressLabel?cn_localized(@"user.room.label"):cn_localized(@"user.floor.label"));
    _addressDetailCell.input = _person.addressDetail;
    _addressDetailCell.inputPlaceholder = (_person.addressLabel == CNHomeAddressLabel?cn_localized(@"user.room.placeholder"):cn_localized(@"user.floor.placeholder"));
    _addressDetailCell.subTitle = nil;//cn_localized(@"user.map.label");
    
    [self.ssn_tableViewConfigurator.listFetchController loadData];
}

- (void)cellAvatarDidTouch:(CNUserHeaderCell *)cell {
}



#pragma mark uitabledelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _selectedTable) {
        NSUInteger row_count = [self.selectPersons count];
        if (row_count > 8) {
            tableView.ssn_height = tableView.rowHeight * 8;
        }
        else {
            tableView.ssn_height = tableView.rowHeight * row_count;
        }
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
    
//    _homeCoor.longitude = _person.homeLongitude;
//    _homeCoor.latitude = _person.homeLatitude;
//    
//    _companyCoor.longitude = _person.companyLongitude;
//    _companyCoor.latitude = _person.companyLatitude;
    
    
    //构建cell
    if (!_items) {
        NSMutableArray *models = [NSMutableArray arrayWithCapacity:1];
        
        if ([CN_DETAIL_SET_USER_OPTION isEqualToString:_option]) {
            CNUserHeaderCellModel *headerCell = [[CNUserHeaderCellModel alloc] init];
            headerCell.avatarURL = _person.avatarURL;
            [models addObject:headerCell];
        }
        
        CNLabelInputCellModel *nameCell = [[CNLabelInputCellModel alloc] init];
        nameCell.title = cn_localized(@"user.name.label");
        nameCell.input = _person.name;
        nameCell.inputMaxLength = 10;
        nameCell.inputPlaceholder = cn_localized(@"user.name.placeholder");
        nameCell.disabledSelect = YES;
        [models addObject:nameCell];
        
        CNSelectionCellModel *gender = [[CNSelectionCellModel alloc] init];
        gender.title = cn_localized(@"user.gender.label");
        gender.radio1 = cn_localized(@"common.male.label");
        gender.radio2 = cn_localized(@"common.female.label");
        gender.value = (_person.gender == CNPersonMaleGender?0:1);
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
        
        CNSectionCellModel *sectionCell = [[CNSectionCellModel alloc] init];
        sectionCell.title = cn_localized(@"user.detail.generally.address");
        [models addObject:sectionCell];
        
        CNSelectionCellModel *addressType = [[CNSelectionCellModel alloc] init];
        addressType.title = cn_localized(@"user.address.type.label");
        addressType.radio1 = cn_localized(@"user.home.address.label");
        addressType.radio2 = cn_localized(@"user.company.address.label");
        addressType.value = (_person.addressLabel == CNHomeAddressLabel?0:1);
        [models addObject:addressType];
        
        CNLabelCellModel *labelCell = [[CNLabelCellModel alloc] init];
        labelCell.title = cn_localized(@"user.address.province.city.label");
        labelCell.subTitle = [_person addressCityDisplay];
        labelCell.hiddenDisclosureIndicator = NO;
        [models addObject:labelCell];
        
        CNLabelInputCellModel *streetAddrCell = [[CNLabelInputCellModel alloc] init];
        streetAddrCell.title = (_person.addressLabel == CNHomeAddressLabel?cn_localized(@"user.biotope.label"):cn_localized(@"user.building.label"));
        streetAddrCell.input = _person.street;
        streetAddrCell.inputPlaceholder = (_person.addressLabel == CNHomeAddressLabel?cn_localized(@"user.biotope.placeholder"):cn_localized(@"user.building.placeholder"));
        streetAddrCell.subTitle = cn_localized(@"user.map.label");
        [models addObject:streetAddrCell];
        _streetAddrCell = streetAddrCell;
        
        CNLabelInputCellModel *addressDetailCell = [[CNLabelInputCellModel alloc] init];
        addressDetailCell.title = (_person.addressLabel == CNHomeAddressLabel?cn_localized(@"user.room.label"):cn_localized(@"user.floor.label"));
        addressDetailCell.input = _person.addressDetail;
        addressDetailCell.inputPlaceholder = (_person.addressLabel == CNHomeAddressLabel?cn_localized(@"user.room.placeholder"):cn_localized(@"user.floor.placeholder"));
        addressDetailCell.subTitle = nil;//cn_localized(@"user.map.label");
        [models addObject:addressDetailCell];
        _addressDetailCell = addressDetailCell;
        
        _items = models;
    }
    
    completion(_items,NO,nil,YES);
}


//当cell选中时
- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator tableView:(UITableView *)tableView didSelectModel:(CNLabelInputCellModel *)model atIndexPath:(NSIndexPath *)indexPath {
    if (![model isKindOfClass:[CNLabelInputCellModel class]]) {
        return ;
    }
    
    //进入地图选择
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    _selectItem = model;
    [dic setValue:[model.input ssn_trimWhitespace] forKey:@"address"];
    NSString *url = [[self ssn_currentURLPath] ssn_URLByAppendQuery:@{@"uid":_uid}].absoluteString;
    [dic setValue:url forKey:@"url"];
    
    [self.ssn_router open:cn_combine_path(@"nav/location") query:dic];
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

- (void)ssn_handleNoticeURL:(NSURL *)url query:(NSDictionary *)query {
    if (!_selectItem) {
        return ;
    }
    
    NSString *address = [query objectForKey:@"address"];
    NSString *city = [query objectForKey:@"city"];
    
    if ([address hasPrefix:city]) {
        _selectItem.input = address;
    }
    else {
        _selectItem.input = [NSString stringWithFormat:@"%@ %@",city,address];
    }
    
    CGFloat longitude = [[query objectForKey:@"longitude"] floatValue];
    CGFloat latitude = [[query objectForKey:@"latitude"] floatValue];
    
    if ([_selectItem.title isEqualToString:cn_localized(@"user.home.address.label")]) {
        _homeCoor.longitude = longitude;
        _homeCoor.latitude = latitude;
    }
    else if ([_selectItem.title isEqualToString:cn_localized(@"user.company.address.label")]) {
        [self.ssn_router open:cn_combine_path(@"nav/location")];
        _companyCoor.longitude = longitude;
        _companyCoor.latitude = latitude;
    }
    
    NSInteger index = [_items indexOfObject:_selectItem];
    
    [self.ssn_tableViewConfigurator.listFetchController updateDatasAtIndexPaths:@[cn_index_path(index,0)] withContext:nil];
}

@end
