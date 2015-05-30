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
    
    if ([CN_DETAIL_SET_USER_OPTION isEqualToString:_option]) {//防止侧滑返回，因为必须设置自己的资料
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(emptyAction:)];
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:cn_localized(@"common.done.button") style:UIBarButtonItemStylePlain target:self action:@selector(doneAction:)];
    
    //配置table
    self.ssn_tableViewConfigurator.tableView = self.tableView;
    
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
        //
    }
    else if ([model.title isEqualToString:cn_localized(@"user.company.address.label")]) {
        //
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
