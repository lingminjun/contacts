//
//  UIViewController+SSNTableViewEasyConfigure.m
//  ssn
//
//  Created by lingminjun on 15/2/26.
//  Copyright (c) 2015年 lingminjun. All rights reserved.
//

#import "UIViewController+SSNTableViewEasyConfigure.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif


@interface SSNTableViewConfigurator ()
@end


@implementation SSNTableViewConfigurator

@synthesize listFetchController = _listFetchController;
- (SSNListFetchController *)listFetchController {
    if (_listFetchController) {
        return _listFetchController;
    }
    
    _listFetchController = [SSNListFetchController fetchControllerWithDelegate:self dataSource:self isGrouping:NO];
    return _listFetchController;
}

- (void)setTableView:(UITableView *)tableView {
    
    BOOL changed = NO;
    if (tableView.delegate != self) {//不相等时再赋值，setDelegate会触发内部检查一些委托方法是否实现问题
        tableView.delegate = self;
        changed = YES;
    }
    
    if (tableView.dataSource != self) {//不相等时再赋值，setDataSource会触发内部检查一些委托方法是否实现问题
        tableView.dataSource = self;
        changed = YES;
    }
    
    tableView.ssn_headerPullRefreshView.delegate = self;
    tableView.ssn_footerLoadMoreView.delegate = self;
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tableView = tableView;
    
    if (changed) {
        [tableView reloadData];//此时是必要的一次reload，因为tableView显示的cell是上一个委托的值
    }
}

- (void)configureWithTableView:(UITableView *)tableView groupingFetchController:(BOOL)grouping {
    if (tableView) {
        self.tableView = tableView;
    }
    
    if (_listFetchController.isGrouping != grouping) {
        _listFetchController = [SSNListFetchController fetchControllerWithDelegate:self dataSource:self isGrouping:grouping];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView != self.tableView) {
        return 0;
    }
    
    return [self.listFetchController sectionCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView != self.tableView) {
        return 0;
    }
    
    SSNVMSectionInfo *sec = [self.listFetchController sectionAtIndex:section];
    return [sec count];
}

- (UITableViewCell *)loadCellWithTableView:(UITableView *)tableView cellModel:(id<SSNCellModel>)cellModel {
    NSString *cellId = [cellModel cellIdentify];
    if (!cellId) {
        cellId = @"cell";
    }
    
    //先取复用队列
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell) {
        return cell;
    }
    
    //优先从nib加载
    if ([cellModel.cellNibName length] > 0) {
        NSArray *views =  [[NSBundle mainBundle] loadNibNamed:cellModel.cellNibName owner:nil options:nil];
        cell = (UITableViewCell *)[views objectAtIndex:0];
    }
    if (cell) {
        return cell;
    }
    
    //自己创建
    Class clazz = nil;
    if ([cellModel respondsToSelector:@selector(cellClass)]) {
        clazz = cellModel.cellClass;
    }
    
    if (clazz) {
        cell = [[clazz alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    if (cell) {
        return cell;
    }
    
    //默认返回
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.tableView) {
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    id<SSNCellModel> model = [self.listFetchController objectAtIndexPath:indexPath];
    
    //加载cell
    UITableViewCell *cell = [self loadCellWithTableView:tableView cellModel:model];
    
    cell.ssn_cellModel = model;
    
    if (model.isDisabledSelect) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    [cell ssn_configureCellWithModel:model atIndexPath:indexPath inTableView:tableView];
    
    cell.ssn_cellModel = model;
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView != self.tableView) {
        return SSN_VM_CELL_ITEM_DEFAULT_HEIGHT;
    }
    
    id<SSNCellModel> model = [self.listFetchController objectAtIndexPath:indexPath];
    return [model cellHeight];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.tableView) {
        return UITableViewCellEditingStyleNone;
    }
    
    //仅仅支持删除
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.tableView) {
        return ;
    }
    
    if ([self.delegate respondsToSelector:@selector(ssn_configurator:tableView:commitEditingStyle:forRowAtIndexPath:)]) {
        [self.delegate ssn_configurator:self tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.tableView) {
        return nil;
    }
    
    id<SSNCellModel> model = [self.listFetchController objectAtIndexPath:indexPath];
    return [model cellDeleteConfirmationButtonTitle];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView != self.tableView) {
        return NO;
    }
    
    id<SSNCellModel> model = [self.listFetchController objectAtIndexPath:indexPath];
    return [model cellDeleteConfirmationButtonTitle] > 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView != self.tableView) {
        return ;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id<SSNCellModel> model = [self.listFetchController objectAtIndexPath:indexPath];
    if (model.isDisabledSelect) {
        return ;
    }
    
    if ([self.delegate respondsToSelector:@selector(ssn_configurator:tableView:didSelectModel:atIndexPath:)]) {
        [self.delegate ssn_configurator:self tableView:tableView didSelectModel:model atIndexPath:indexPath];
    }
}

//header
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView != self.tableView) {
        return nil;
    }
    
    SSNVMSectionInfo *sec = [self.listFetchController sectionAtIndex:section];
    if (sec.hiddenHeader) {
        return nil;
    }
    return sec.headerTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView != self.tableView) {
        return 0.0f;
    }
    
    SSNVMSectionInfo *sec = [self.listFetchController sectionAtIndex:section];
    if (sec.hiddenHeader) {
        return 0.0f;
    }
    return sec.headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView != self.tableView) {
        return nil;
    }
    
    SSNVMSectionInfo *sec = [self.listFetchController sectionAtIndex:section];
    if (sec.hiddenHeader) {
        return nil;
    }
    return sec.customHeaderView;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (tableView != self.tableView) {
        return nil;
    }
    
    SSNVMSectionInfo *sec = [self.listFetchController sectionAtIndex:section];
    if (sec.hiddenFooter) {
        return nil;
    }
    return sec.footerTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (tableView != self.tableView) {
        return 0.0f;
    }
    
    SSNVMSectionInfo *sec = [self.listFetchController sectionAtIndex:section];
    if (sec.hiddenFooter) {
        return 0.0f;
    }
    return sec.footerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (tableView != self.tableView) {
        return nil;
    }
    
    SSNVMSectionInfo *sec = [self.listFetchController sectionAtIndex:section];
    if (sec.hiddenFooter) {
        return nil;
    }
    return sec.customFooterView;
}

// return list of section titles to display in section index view (e.g. "ABCD...Z#")
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView != self.tableView) {
        return nil;
    }
    
    if (_showGroupIndexs) {
        return [self.listFetchController sectionIdentifiers];
    }
    
    return nil;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (tableView != self.tableView) {
        return 0;
    }
    
    return index;
}

#pragma mark - pull refresh delegate
/**
 *  将要触发动作
 *
 *  @param view
 */
- (void)ssn_scrollEdgeViewDidTrigger:(SSNScrollEdgeView *)scrollEdgeView {
    if (scrollEdgeView == self.tableView.ssn_headerPullRefreshView) {
        [self.listFetchController loadData];
    }
    else if (scrollEdgeView == self.tableView.ssn_footerLoadMoreView) {
        [self.listFetchController loadMoreData];
    }
}

#pragma mark - list fetch controller delegate
- (void)ssnlist_controller:(SSNListFetchController *)controller didChangeSection:(SSNVMSectionInfo *)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(SSNListFetchedChangeType)type {
    if (controller != self.listFetchController) {
        return ;
    }

    if (_isWithoutAnimation) {
        return ;
    }
    
    switch(type) {
        case SSNListFetchedChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:_rowAnimation];
            break;
            
        case SSNListFetchedChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:_rowAnimation];
            break;
        default:break;
    }
}

- (void)ssnlist_controller:(SSNListFetchController *)controller didChangeObject:(id<SSNCellModel>)object atIndexPath:(NSIndexPath *)indexPath forChangeType:(SSNListFetchedChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (controller != self.listFetchController) {
        return ;
    }
    
    if (_isWithoutAnimation) {
        return ;
    }
    
    switch (type) {
        case SSNListFetchedChangeInsert:
        {
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:_rowAnimation];
        }
            break;
        case SSNListFetchedChangeDelete:
        {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:_rowAnimation];
        }
            break;
        case SSNListFetchedChangeMove:
        {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:_rowAnimation];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:_rowAnimation];
        }
            break;
        case SSNListFetchedChangeUpdate:
        {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell ssn_configureCellWithModel:object atIndexPath:indexPath inTableView:self.tableView];
        }
            break;
        default:
            break;
    }
    
}

- (void)ssnlist_controllerWillChange:(SSNListFetchController *)controller {
    if (controller != self.listFetchController) {
        return ;
    }
    
    if (_isWithoutAnimation) {
        return ;
    }
    
    [self.tableView beginUpdates];
}

- (void)ssnlist_controllerDidChange:(SSNListFetchController *)controller {
    if (controller != self.listFetchController) {
        return ;
    }
    
    if (_isWithoutAnimation) {
        [self.tableView reloadData];
    }
    else {
        [self.tableView endUpdates];
    }
}

#pragma mark - list fetch controller datasource

- (void)ssnlist_controller:(SSNListFetchController *)controller loadDataWithOffset:(NSUInteger)offset limit:(NSUInteger)limit userInfo:(NSDictionary *)userInfo completion:(void (^)(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished))completion
{
    if (controller != self.listFetchController) {
        return ;
    }
    
    if ([self.delegate respondsToSelector:@selector(ssn_configurator:controller:loadDataWithOffset:limit:userInfo:completion:)]) {
        
        void (^block)(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished) = ^(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished) {
            
            if (offset == 0) {
                [self.tableView.ssn_headerPullRefreshView finishedLoading];
            }
            else {
                [self.tableView.ssn_footerLoadMoreView finishedLoading];
            }
            
            if (self.isAutoEnabledLoadMore) {
                self.tableView.ssn_loadMoreEnabled = hasMore;
                _tableView.ssn_footerLoadMoreView.delegate = self;
            }
            
            if (completion) {
                completion(results,hasMore,userInfo,finished);
            }
        };
        
        [self.delegate ssn_configurator:self controller:controller loadDataWithOffset:offset limit:limit userInfo:userInfo completion:block];
    }
}

- (void)ssnlist_controller:(SSNListFetchController *)controller sectionDidLoad:(SSNVMSectionInfo *)section sectionIdntify:(NSString *)identify {
    if (controller != self.listFetchController) {
        return ;
    }
    
    if ([self.delegate respondsToSelector:@selector(ssn_configurator:controller:sectionDidLoad:sectionIdntify:)]) {
        [self.delegate ssn_configurator:self controller:controller sectionDidLoad:section sectionIdntify:identify];
    }
}

- (id<SSNCellModel>)ssnlist_controller:(SSNListFetchController *)controller insertDataWithIndexPath:(NSIndexPath *)indexPath context:(void *)context {
    if (controller != self.listFetchController) {
        return nil;
    }
    
    if ([self.delegate respondsToSelector:@selector(ssn_configurator:controller:insertDataWithIndexPath:context:)]) {
        return [self.delegate ssn_configurator:self controller:controller insertDataWithIndexPath:indexPath context:context];
    }

    return nil;
}

- (id<SSNCellModel>)ssnlist_controller:(SSNListFetchController *)controller updateDataWithOriginalData:(id<SSNCellModel>)model indexPath:(NSIndexPath *)indexPath context:(void *)context {
    if (controller != self.listFetchController) {
        return model;
    }
    
    if ([self.delegate respondsToSelector:@selector(ssn_configurator:controller:updateDataWithOriginalData:indexPath:context:)]) {
        return [self.delegate ssn_configurator:self controller:controller updateDataWithOriginalData:model indexPath:indexPath context:context];
    }
    else {
        return model;
    }
}

@end


@implementation UIViewController (SSNTableViewEasyConfigure)
#pragma mark list fetch controller
static char * ssn_table_configurator_key = NULL;
- (SSNTableViewConfigurator *)ssn_tableViewConfigurator {
    SSNTableViewConfigurator *configurator = objc_getAssociatedObject(self, &(ssn_table_configurator_key));
    if (configurator) {
        return configurator;
    }
    
    configurator = [[SSNTableViewConfigurator alloc] init];
    configurator.delegate = self;
    
    objc_setAssociatedObject(self, &(ssn_table_configurator_key),configurator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return configurator;
}

#pragma mark - 委托默认实现
- (void)ssn_configurator:(SSNTableViewConfigurator *)configurator tableView:(UITableView *)tableView didSelectModel:(id<SSNCellModel>)model atIndexPath:(NSIndexPath *)indexPath {
}

- (void)ssn_configurator:(SSNTableViewConfigurator *)configurator controller:(SSNListFetchController *)controller loadDataWithOffset:(NSUInteger)offset limit:(NSUInteger)limit userInfo:(NSDictionary *)userInfo completion:(void (^)(NSArray *results, BOOL hasMore, NSDictionary *userInfo, BOOL finished))completion {
    
    if (completion) {
        completion(nil,NO,userInfo,YES);
    }
    
}

@end
