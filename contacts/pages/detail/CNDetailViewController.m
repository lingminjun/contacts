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
#import "CNAddress.h"
//#import "CNLocationInputCell.h"
#import "CNPicker.h"
#import "CNLocationLableCell.h"
#import "CNLocationTaggingCell.h"

NSString *const CN_DETAIL_SET_USER_OPTION = @"setuser";
NSString *const CN_DETAIL_ADD_FRIEND_OPTION = @"addfriend";

@interface CNDetailViewController ()<UITableViewDataSource,UITableViewDelegate,CNPickerDelegate>

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) CNPerson *person;

@property (nonatomic,strong) NSArray *items;

@property (nonatomic,strong) CNUserHeaderCellModel *headerCell;
@property (nonatomic,strong) CNLabelInputCellModel *nameCell;
@property (nonatomic,strong) CNSelectionCellModel *genderCell;
@property (nonatomic,strong) CNLabelInputCellModel *mobileCell;
@property (nonatomic,strong) CNSelectionCellModel *addressTypeCell;
@property (nonatomic,strong) CNLabelCellModel *provinceCell;

@property (nonatomic, strong) CNLocationTaggingCellModel * locationTaggingCellModel;
@property (nonatomic, strong) CNLocationLableCellModel * locationNameCellModel;
@property (nonatomic, strong) CNLocationLableCellModel * detailAddressCellModel;
@property (nonatomic, strong) CNLabelInputCellModel *addressDetailCell;

//本地通讯录选择
@property (nonatomic,strong) UITableView *selectedTable;
@property (nonatomic,strong) NSArray *selectPersons;
//@property (nonatomic,strong) CNLabelInputCellModel *selectItem;

//省市选择
@property (nonatomic) BOOL isShowPicker;
@property (nonatomic,strong) CNPicker *picker;
@property (nonatomic,strong) NSArray *provineces;

@property (nonatomic) CLLocationCoordinate2D coor;

@end

@implementation CNDetailViewController

- (UITableView *)tableView {
    if (_tableView) {
        return _tableView;
    }
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    return _tableView;
}

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

- (CNPicker *)picker {
    if (_picker) {
        return _picker;
    }
    
    _picker = [[CNPicker alloc] init];
    _picker.componentCount = 2;
    _picker.delegate = self;
    return _picker;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.tableView];
    
    //
    [NSNotificationCenter ssn_defaultCenterAddObserver:self
                                              selector:@selector(keyboardWillShow:)
                                                  name:UIKeyboardWillShowNotification
                                                object:nil];
    [NSNotificationCenter ssn_defaultCenterAddObserver:self
                                              selector:@selector(keyboardWillHide:)
                                                  name:UIKeyboardWillHideNotification
                                                object:nil];
    
    if ([_uid length] == 0) {
        _uid = [CNUserCenter uidGenerator];
    }
 
    if ([CN_DETAIL_SET_USER_OPTION isEqualToString:_option]) {
        self.title = cn_localized(@"user.header.title");
    }
    else {
        if ([_uid isEqualToString:[CNUserCenter center].currentUID]) {
            self.title = cn_localized(@"user.header.title");
        }
        else {
            self.title = cn_localized(@"detail.header.title");
        }
    }
    
    if ([CN_DETAIL_SET_USER_OPTION isEqualToString:_option]) {//防止侧滑返回，因为必须设置自己的资料
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(emptyAction:)];
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:cn_localized(@"common.done.button") style:UIBarButtonItemStylePlain target:self action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    //配置table
    self.ssn_tableViewConfigurator.tableView = self.tableView;
    self.ssn_tableViewConfigurator.isWithoutAnimation = YES;
    
    //开始加载数据
    [self.ssn_tableViewConfigurator.listFetchController loadData];
}

- (void)loadAreas {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"areas" ofType:@"plist"];
    _provineces = [NSArray arrayWithContentsOfFile:path];
    NSMutableArray <CNPickerData>*pickdatas = (NSMutableArray <CNPickerData>*)[NSMutableArray array];
    for (NSDictionary *dic1 in _provineces) {
        NSString *title = [dic1 objectForKey:@"provinceName"];
        CNPickerData *data1 = [CNPickerData dataWithTitle:title];
        [pickdatas addObject:data1];
        
        NSArray *cities = [dic1 objectForKey:@"cities"];
        for (NSDictionary *dic2 in cities) {
            NSString *city = [dic2 objectForKey:@"cityName"];
            CNPickerData *data2 = [CNPickerData dataWithTitle:city];
            [data1.children addObject:data2];
            
            NSArray *regions = [dic2 objectForKey:@"regions"];
            for (NSDictionary *dic3 in regions) {
                NSString *region = [dic3 objectForKey:@"regionName"];
                CNPickerData *data3 = [CNPickerData dataWithTitle:region];
                [data2.children addObject:data3];
            }
        }
    }
    [self.picker setDatas:pickdatas];
    
    NSMutableArray <CNPickerData>*sels = (NSMutableArray <CNPickerData>*)[NSMutableArray array];
    if ([_person.province ssn_non_empty]) {
        [sels addObject:[CNPickerData dataWithTitle:_person.province]];
        
        if ([_person.city ssn_non_empty]) {
            [sels addObject:[CNPickerData dataWithTitle:_person.city]];
            
            if ([_person.region ssn_non_empty]) {
                [sels addObject:[CNPickerData dataWithTitle:_person.region]];
            }
        }
    }
    
    if ([sels count]) {
        [self.picker selectDatas:sels animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_provineces == nil) {
        [self loadAreas];
    }
    
}

- (void)emptyAction:(id)sender {
}

#pragma mark picker
#define cn_index_path(row,section) [NSIndexPath indexPathForRow:(row) inSection:(section)]
- (void)pickerDoneButtonClick:(CNPicker *)picker {
    NSArray <CNPickerData>*addr = picker.selectedDatas;
    
    _person.province = [addr[0] title];//前半段
    _person.city = [addr[1] title];//后半段
//    _person.region = [addr[2] title];//后半段
//    _provinceCell.subTitle = [NSString stringWithFormat:@"%@ %@ %@",[addr[0] title],[addr[1] title],[addr[2] title]];
    NSString *str = [NSString stringWithFormat:@"%@ %@",[addr[0] title],[addr[1] title]];
    if (![_provinceCell.subTitle hasPrefix:str]) {
        _provinceCell.subTitle = str;
    }
    
    _locationNameCellModel.subTitle = nil;
    _detailAddressCellModel.subTitle = nil;
    _addressDetailCell.input = nil;
    [self.tableView reloadData];

    
    [self dismissPicker];
}

- (void)showPicker {
    self.picker.ssn_top = self.view.ssn_bottom;
    [self.view addSubview:self.picker];
    
    NSMutableArray <CNPickerData>*sels = (NSMutableArray <CNPickerData>*)[NSMutableArray array];
    if ([_person.province ssn_non_empty]) {
        [sels addObject:[CNPickerData dataWithTitle:_person.province]];
        
        if ([_person.city ssn_non_empty]) {
            [sels addObject:[CNPickerData dataWithTitle:_person.city]];
            
            if ([_person.region ssn_non_empty]) {
                [sels addObject:[CNPickerData dataWithTitle:_person.region]];
            }
        }
    }
    
    if ([sels count]) {
        [self.picker selectDatas:sels animated:NO];
    }
    
//    [self.picker reload];
    
    self.isShowPicker = YES;
    [self.view endEditing:YES];
    
    [UIView animateWithDuration:0.6 animations:^{
        self.picker.ssn_bottom = self.view.ssn_bottom - 64;
    } completion:^(BOOL finished) {
        self.isShowPicker = YES;
        UIEdgeInsets inserts = self.tableView.contentInset;
        inserts.bottom = 256;
        self.tableView.contentInset = inserts;
    }];
}

- (void)dismissPicker {
    [UIView animateWithDuration:0.6 animations:^{
        self.picker.ssn_top = self.view.ssn_bottom;
    } completion:^(BOOL finished) {
        self.isShowPicker = NO;
    }];
}

- (void)keyboardWillShow:(NSNotification *)notify {
    if (self.isShowPicker) {
        [self dismissPicker];
    }
    UIEdgeInsets inserts = self.tableView.contentInset;
    inserts.bottom = 256;
    self.tableView.contentInset = inserts;
}

- (void)keyboardWillHide:(NSNotification *)notify {
    if (!self.isShowPicker) {
        UIEdgeInsets inserts = self.tableView.contentInset;
        inserts.bottom = 0;
        self.tableView.contentInset = inserts;
    }
}

- (void)doneAction:(id)sender {
    
    //check 名字
    if ([[_nameCell.input ssn_trimWhitespace] length] == 0) {
        [self ssn_showToast:cn_localized(@"user.name.input.tip")];
        return ;
    }
    
//    //check mobile
//    if ([[_mobileCell.input ssn_trimAllWhitespace] length] == 0) {
//        [self ssn_showToast:cn_localized(@"user.mobile.input.tip")];
//        return ;
//    }
//    
//    //check addr
//    if ([[_provinceCell.subTitle ssn_trimWhitespace] length] == 0
//        || [[_streetAddrCell.input ssn_trimWhitespace] length] == 0
//        || [[_addressDetailCell.input ssn_trimWhitespace] length] == 0) {
//        [self ssn_showToast:cn_localized(@"user.address.input.tip")];
//        return ;
//    }
    
    //取得界面输入数据
    _person.name = [_nameCell.input ssn_trimWhitespace];
    _person.gender = _genderCell.value == 0 ? CNPersonMaleGender : CNPersonFemaleGender;
    _person.mobile = [[_mobileCell.input ssn_trimAllWhitespace] ssn_trimCountryCodePhoneNumber];
    _person.addressLabel = _addressTypeCell.value == 0 ? CNHomeAddressLabel : CNCompanyAddressLabel;
    _person.locationPointName = [_locationNameCellModel.subTitle ssn_trimWhitespace];
    _person.street = [_detailAddressCellModel.subTitle ssn_trimWhitespace];
    _person.addressDetail = [_addressDetailCell.input ssn_trimWhitespace];
    
    NSString *auid = self.uid;
    if (_coor.longitude == 0.0f) {
        if ([_person.street ssn_non_empty] && [_person.city ssn_non_empty]) {
            [[CNBMKMapDelegate delegate] geoCodeWithAddress:_person.street city:_person.city completion:^(CLLocationCoordinate2D coor, NSError *error) {
                
                if (!error) {
                    //将数据保存到数据库
                    SSNDBTable *tb = [SSNDBTableManager personTable];
                    NSArray *ary = [tb objectsWithClass:[CNPerson class] forConditions:@{@"uid":auid}];
                    CNPerson *pn = [ary firstObject];
                    pn.latitude = coor.latitude;
                    pn.longitude = coor.longitude;
                    
                    if ([CN_DETAIL_SET_USER_OPTION isEqualToString:_option]) {//设置自己的信息，不需要管
                    }
                    else if ([CNUserCenter center].currentUID == _uid) {//修改自己的信息，计算所有数据位置
                        [self updateAllFriendsDistance];
                    }
                    else {
                        CNPerson *me = [CNUserCenter center].currentUser;
                        if (me.longitude != 0.0f) {
                            CLLocationCoordinate2D from = CLLocationCoordinate2DMake(me.latitude, me.longitude);
                            CLLocationCoordinate2D to = CLLocationCoordinate2DMake(_person.latitude, _person.longitude);
                            _person.distance = [[CNBMKMapDelegate delegate] kilometersFromCoordinate:from toCoordinate:to];
                        }
                    }
                    
                    [tb upinsertObject:pn fields:@[@"latitude",@"longitude",@"distance"]];
                }
                
            }];
        }
    }
    else {
        BOOL changed = NO;
        if (_person.latitude != _coor.latitude) {
            _person.latitude = _coor.latitude;
            changed = YES;
        }
        if (_person.longitude != _coor.longitude) {
            _person.longitude = _coor.longitude;
            changed = YES;
        }
        
        if ([CN_DETAIL_SET_USER_OPTION isEqualToString:_option]) {//设置自己的信息，不需要管
        }
        else if ([CNUserCenter center].currentUID == _uid) {//修改自己的信息，计算所有数据位置
            if (changed) {
                [self updateAllFriendsDistance];
            }
        }
        else {
            CNPerson *me = [CNUserCenter center].currentUser;
            if (me.longitude != 0.0f) {
                CLLocationCoordinate2D from = CLLocationCoordinate2DMake(me.latitude, me.longitude);
                CLLocationCoordinate2D to = CLLocationCoordinate2DMake(_person.latitude, _person.longitude);
                _person.distance = [[CNBMKMapDelegate delegate] kilometersFromCoordinate:from toCoordinate:to];
            }
        }
    }
    
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
    
    if ([self.url length] > 0) {
        [self.ssn_router open:self.url];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)updateAllFriendsDistance {
    CNPerson *me = [CNUserCenter center].currentUser;
    if (me.longitude == 0.0f) {
        return ;
    }
    
    SSNDBTable *tb = [SSNDBTableManager personTable];
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where uid <> '%@' and longitude <> 0.0 and latitude <> 0.0",tb.name,[CNUserCenter center].currentUID];
    NSArray *persons = [[CNUserCenter center].currentDatabase objects:[CNPerson class] sql:sql arguments:nil];
    
    CLLocationCoordinate2D from = CLLocationCoordinate2DMake(me.latitude, me.longitude);
    
    for (CNPerson *person in persons) {
        CLLocationCoordinate2D to = CLLocationCoordinate2DMake(person.latitude, person.longitude);
        person.distance = [[CNBMKMapDelegate delegate] kilometersFromCoordinate:from toCoordinate:to];
    }
    
    [tb upinsertObjects:persons fields:@[@"distance"]];
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
    _selectedTable.delegate = nil;
    _tableView.delegate = nil;
    [NSNotificationCenter ssn_defaultCenterRemoveObserver:self];
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
    else if ([model.title isEqualToString:cn_localized(@"user.biotope.label")]) {
        _coor.latitude = 0.0f;
        _coor.longitude = 0.0f;
    }
    else if ([model.title isEqualToString:cn_localized(@"user.building.label")]) {
        _coor.latitude = 0.0f;
        _coor.longitude = 0.0f;
    }
    
    [self checkButtonStatus];
}

- (void)checkButtonStatus {
    if (![CN_DETAIL_SET_USER_OPTION isEqualToString:_option]) {
        if ([_person.name isEqualToString:[_nameCell.input ssn_trimWhitespace]]
            && [_person.mobile isEqualToString:[_mobileCell.input ssn_trimAllWhitespace]]
            && [_person.province isEqualToString:[_provinceCell.subTitle ssn_trimWhitespace]]
            && [_person.addressDetail isEqualToString:[_addressDetailCell.input ssn_trimWhitespace]]
            && _person.gender == (_genderCell.value == 1 ? CNPersonMaleGender : CNPersonFemaleGender)) {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
        else {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }
    else {
        //check 名字
        if ([[_nameCell.input ssn_trimWhitespace] ssn_non_empty]) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
}

- (void)cellLocationButtonAction:(CNLocationTaggingCell *)cell {
    //进入地图选择
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    
    CNAddress *addr = [[CNAddress alloc] init];
    addr.province = _person.province;
    addr.city = _person.city;
    addr.district = _person.region;
    
    [dic setValue:addr forKey:@"addr"];
    NSString *addrdes = [_detailAddressCellModel.subTitle ssn_trimWhitespace];
    if (![addrdes ssn_non_empty] && [_person.city ssn_non_empty]) {
        if ([_person.region ssn_non_empty]) {
            addrdes = [NSString stringWithFormat:@"%@%@",_person.city,_person.region];
        }
        else {
            addrdes = _person.city;
        }
    }
    [dic setValue:addrdes forKey:@"addrdes"];
    
    if ([[_locationNameCellModel.subTitle ssn_trimWhitespace] ssn_non_empty]) {
        [dic setObject:[_locationNameCellModel.subTitle ssn_trimWhitespace] forKey:@"addrtitle"];
    }
    
    
    NSString *url = [[self ssn_currentURLPath] ssn_URLByAppendQuery:@{@"uid":_uid}].absoluteString;
    [dic setValue:url forKey:@"url"];
    
    [self.ssn_router open:cn_combine_path(@"nav/location") query:dic];
}

- (void)cellRadioDidSelect:(CNSelectionCell *)cell {
    CNSelectionCellModel *model = (CNSelectionCellModel *)cell.ssn_cellModel;
    if (![model.title isEqualToString:cn_localized(@"user.address.type.label")]) {
        [self checkButtonStatus];
        return ;
    }
    if (model.value == 0) {
        _person.addressLabel = CNHomeAddressLabel;
    }
    else {
        _person.addressLabel = CNCompanyAddressLabel;
    }
    
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
            _nameCell.input = abperson.name;
            
            //check mobile
            _mobileCell.input = abperson.mobile;
            
            
            //
            NSInteger nameCellRow = [_items indexOfObject:_provinceCell];
            NSIndexPath *nameCellpath = cn_index_path(nameCellRow, 0);
            
            NSInteger mobileCellRow = [_items indexOfObject:_provinceCell];
            NSIndexPath *mobileCellPath = cn_index_path(mobileCellRow, 0);
            
            [self.ssn_tableViewConfigurator.listFetchController updateDatasAtIndexPaths:@[nameCellpath,mobileCellPath] withContext:nil];
            
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
    if (!_items) {
        NSMutableArray *models = [NSMutableArray arrayWithCapacity:1];
        
        if ([CN_DETAIL_SET_USER_OPTION isEqualToString:_option]
            || [_uid isEqualToString:[CNUserCenter center].currentUID]) {
            CNUserHeaderCellModel *cell = [[CNUserHeaderCellModel alloc] init];
            cell.avatarURL = _person.avatarURL;
            [models addObject:cell];
            _headerCell = cell;
        }
        
        {
            CNLabelInputCellModel *inputCell = [[CNLabelInputCellModel alloc] init];
            inputCell.title = cn_localized(@"user.name.label");
            inputCell.input = _person.name;
            inputCell.inputMaxLength = 10;
            inputCell.inputPlaceholder = cn_localized(@"user.name.placeholder");
            inputCell.disabledSelect = YES;
            [models addObject:inputCell];
            _nameCell = inputCell;
        }
        
        {
            CNSelectionCellModel *gender = [[CNSelectionCellModel alloc] init];
            gender.title = cn_localized(@"user.gender.label");
            gender.radio1 = cn_localized(@"common.male.label");
            gender.radio2 = cn_localized(@"common.female.label");
            gender.value = (_person.gender == CNPersonMaleGender?0:1);
            [models addObject:gender];
            _genderCell = gender;
        }
        
        {
            CNLabelInputCellModel *inputCell = [[CNLabelInputCellModel alloc] init];
            inputCell.title = cn_localized(@"user.mobile.label");
            inputCell.input = _person.mobile;
            inputCell.inputMaxLength = 13;
            inputCell.inputCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
            inputCell.inputFormat = ^(NSString *originText){ return [originText ssn_mobile344Format];};
            inputCell.inputPlaceholder = cn_localized(@"user.mobile.placeholder");
            inputCell.disabledSelect = YES;
            inputCell.keyboardType = UIKeyboardTypePhonePad;
            [models addObject:inputCell];
            _mobileCell = inputCell;
        }
        
        CNSectionCellModel *sectionCell = [[CNSectionCellModel alloc] init];
        sectionCell.title = cn_localized(@"user.detail.generally.address");
        [models addObject:sectionCell];
        
        {
            CNSelectionCellModel *addressType = [[CNSelectionCellModel alloc] init];
            addressType.title = cn_localized(@"user.address.type.label");
            addressType.radio1 = cn_localized(@"user.home.address.label");
            addressType.radio2 = cn_localized(@"user.company.address.label");
            addressType.value = (_person.addressLabel == CNHomeAddressLabel?0:1);
            [models addObject:addressType];
            _addressTypeCell = addressType;
        }
        
        {
            CNLabelCellModel *labelCell = [[CNLabelCellModel alloc] init];
            labelCell.title = cn_localized(@"user.address.province.city.label");
            NSMutableString *text = [NSMutableString string];
            if ([_person.province ssn_non_empty]) {
                [text appendFormat:@"%@",_person.province];
                if ([_person.city ssn_non_empty]) {
                    [text appendFormat:@" %@",_person.city];
                    if ([_person.region ssn_non_empty]) {
                        [text appendFormat:@" %@",_person.region];
                    }
                }
            }
            labelCell.subTitle = text;
            labelCell.hiddenDisclosureIndicator = NO;
            [models addObject:labelCell];
            _provinceCell = labelCell;
        }
        
        {
            CNLocationTaggingCellModel * taggingCellModel = [CNLocationTaggingCellModel new];
            taggingCellModel.title = @"位置";
            taggingCellModel.subTitle = cn_localized(@"user.map.label");
            taggingCellModel.disabledSelect = YES;
            [models addObject:taggingCellModel];
            _locationTaggingCellModel = taggingCellModel;
        }
        
        {
            CNLocationLableCellModel * locationNameCellModel = [[CNLocationLableCellModel alloc] init];
            locationNameCellModel.title = @"位置名称";
            locationNameCellModel.disabledSelect = YES;
            locationNameCellModel.subTitle = _person.locationPointName;
            [models addObject:locationNameCellModel];
            _locationNameCellModel = locationNameCellModel;
        }
        
        {
            CNLocationLableCellModel * detailStreedAddrCell = [[CNLocationLableCellModel alloc] init];
            detailStreedAddrCell.title = cn_localized(@"user.detail.addr.label");
            detailStreedAddrCell.disabledSelect = YES;
            detailStreedAddrCell.subTitle = _person.street;
            [models addObject:detailStreedAddrCell];
            _detailAddressCellModel = detailStreedAddrCell;
        }
        
        {
            CNLabelInputCellModel *addressDetailCell = [[CNLabelInputCellModel alloc] init];
            addressDetailCell.title = (_person.addressLabel == CNHomeAddressLabel?cn_localized(@"user.room.label"):cn_localized(@"user.floor.label"));
            addressDetailCell.input = _person.addressDetail;
            addressDetailCell.inputPlaceholder = (_person.addressLabel == CNHomeAddressLabel?cn_localized(@"user.room.placeholder"):cn_localized(@"user.floor.placeholder"));
            [models addObject:addressDetailCell];
            _addressDetailCell = addressDetailCell;
        }
        
        _items = models;
    }
    
    completion(_items,NO,nil,YES);
}


//当cell选中时
- (void)ssn_configurator:(id<SSNTableViewConfigurator>)configurator tableView:(UITableView *)tableView didSelectModel:(CNLabelInputCellModel *)model atIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isShowPicker) {
        [self dismissPicker];
        return ;
    }
    
    if ([model isKindOfClass:[CNLabelCellModel class]]) {
        [self showPicker];
    }
}


#pragma mark - SSNPage
- (void)ssn_handleOpenURL:(NSURL *)url query:(NSDictionary *)query {
    self.uid = [query objectForKey:@"uid"];
    self.option = [query objectForKey:@"option"];
    self.url = [[query objectForKey:@"url"] ssn_urlDecode];
}

- (BOOL)ssn_canRespondURL:(NSURL *)url query:(NSDictionary *)query {
    NSString *uid = [query objectForKey:@"uid"];
    return [_uid isEqualToString:uid];
}

- (void)ssn_handleNoticeURL:(NSURL *)url query:(NSDictionary *)query {
    NSString *addrdes = [query objectForKey:@"addrdes"];
    NSString *addrName = [query objectForKey:@"name"];
    CNAddress *addr = [query objectForKey:@"addr"];
    
    if ([addrName length]) {
        _locationNameCellModel.subTitle = addrName;
    }
    
    if ([addrdes length]) {
        _detailAddressCellModel.subTitle = addrdes;
    }
    
    if (addr) {
        _person.province = addr.province;
        _person.city = addr.city;
        _person.region = addr.district;
        
        _provinceCell.subTitle = [NSString stringWithFormat:@"%@ %@ %@",addr.province,addr.city,addr.district];
    }
    
    CGFloat longitude = [[query objectForKey:@"longitude"] floatValue];
    CGFloat latitude = [[query objectForKey:@"latitude"] floatValue];
    
    _coor.latitude = latitude;
    _coor.longitude = longitude;
    
    NSInteger addrIndex= [_items indexOfObject:_provinceCell];
    NSInteger street = [_items indexOfObject:_detailAddressCellModel];
    NSInteger location = [_items indexOfObject:_locationNameCellModel];
    
    [self.ssn_tableViewConfigurator.listFetchController updateDatasAtIndexPaths:@[cn_index_path(addrIndex,0),cn_index_path(street,0),cn_index_path(location,0)] withContext:nil];
    
    [self checkButtonStatus];
}

@end
