//
//  CNPicker.m
//  contacts
//
//  Created by lingminjun on 15/6/22.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNPicker.h"

@interface CNPicker()<UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic,strong) UIPickerView *picker;
@property (nonatomic,strong) NSMutableArray <CNPickerData>*firsts;
@property (nonatomic,strong) NSMutableArray <CNPickerData>*selects;

@end

@implementation CNPicker

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = cn_backgroud_white_color;
        
        UIImageView *line = [UIImageView ssn_lineWithWidth:cn_screen_width color:cn_separator_line_color orientation:UIInterfaceOrientationPortraitUpsideDown];
        [self addSubview:line];
        
        UIButton *btn = [UIButton cn_done_button];
        btn.ssn_normalTitle = cn_localized(@"common.done.button");
        [btn ssn_addTarget:self touchAction:@selector(doneAction:)];
        
        _picker = [[UIPickerView alloc] init];
        [_picker sizeToFit];
        _picker.ssn_width = cn_screen_width;
        _picker.delegate = self;
        
        self.ssn_height = _picker.ssn_height + cn_tool_bar_height;
        self.ssn_width = cn_screen_width;
        
        SSNUITableLayout *layout = [self ssn_tableLayoutWithRowCount:2 columnCount:1];
        [layout setRowInfo:ssn_layout_table_row(cn_tool_bar_height) atRow:0];
        
        ssn_layout_add_v2(layout, btn, 0, ssn_layout_table_cell(0, 0, 0, cn_right_edge_width, SSNUIContentModeRight), button);
        ssn_layout_add_v2(layout, _picker, 1, ssn_layout_table_cell_v2(SSNUIContentModeCenter), picker);
        
        
        _firsts = (NSMutableArray <CNPickerData>*)[[NSMutableArray alloc] init];
        _selects = (NSMutableArray <CNPickerData>*)[[NSMutableArray alloc] init];
    }
    return self;
}

- (void)doneAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(pickerDoneButtonClick:)]) {
        [_delegate pickerDoneButtonClick:self];
    }
}

- (NSArray <CNPickerData>*)datas {
    return (NSArray <CNPickerData>*)[NSArray arrayWithArray:_firsts];
}
- (void)setDatas:(NSArray<CNPickerData> *)datas {
    if (datas) {
        [_firsts setArray:datas];
    }
    else {
        [_firsts removeAllObjects];
    }
    [_selects removeAllObjects];
    CNPickerData *data = [_firsts firstObject];
    NSInteger idx = 0;
    while (data && idx < _componentCount) {
        [_selects addObject:data];
        data = [data.children firstObject];
        [_picker selectRow:0 inComponent:idx animated:NO];
        idx++;
    }
    [_picker reloadAllComponents];
}

- (NSArray <CNPickerData>*)selectedDatas {
    return (NSArray <CNPickerData>*)[NSArray arrayWithArray:_selects];
}

- (void)reload {
    [_picker reloadAllComponents];
}

- (void)selectDatas:(NSArray <CNPickerData>*)datas animated:(BOOL)animated {
    
    NSMutableArray *selecteds = [NSMutableArray array];
    [datas enumerateObjectsUsingBlock:^(CNPickerData *data, NSUInteger comIdx, BOOL *stop) {
        
        if (comIdx >= _componentCount) {
            *stop = YES;
            return ;
        }
        
        NSArray *targets = nil;
        if (comIdx == 0) {
            targets = _firsts;
        }
        else {
            targets = [(CNPickerData *)selecteds[comIdx - 1] children];
        }
        
        //遍历数据源
        __block CNPickerData *sel = nil;
        [targets enumerateObjectsUsingBlock:^(CNPickerData *obj, NSUInteger idx, BOOL *stop) {
            if ([obj.title isEqualToString:data.title]) {
                sel = obj;
                *stop = YES;
            }
        }];
        
        if (sel) {//找到继续
            [selecteds insertObject:sel atIndex:comIdx];
        }
        else {
            *stop = YES;
        }
    }];
    
    [_selects setArray:selecteds];
    [_picker reloadAllComponents];
    
    for (NSInteger idx = 0; idx < _componentCount; idx++) {
        NSArray *targets = nil;
        if (idx == 0) {
            targets = _firsts;
        }
        else {
            targets = [(CNPickerData *)_selects[idx - 1] children];
        }
        NSInteger row = [targets indexOfObject:_selects[idx]];
        [_picker selectRow:(NSInteger)row inComponent:idx animated:animated];
    }
}

#pragma mark - picker delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return _componentCount;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return [_firsts count];
    }
    else if (component < [_selects count]) {
        CNPickerData *data = [_selects objectAtIndex:(component - 1)];
        return [data.children count];
    }
    else {
        return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    CNPickerData *data = nil;
    if (component == 0) {
        data = [_firsts objectAtIndex:row];
    }
    else if (component < [_selects count]) {
        CNPickerData *sel = (CNPickerData *)[_selects objectAtIndex:component - 1];
        data = [[sel children] objectAtIndex:row];
    }
    return data.title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    CNPickerData *data = nil;
    if (component == 0) {
        data = [_firsts objectAtIndex:row];
    }
    else if (component < [_selects count]) {
        CNPickerData *sel = (CNPickerData *)[_selects objectAtIndex:component - 1];
        data = [[sel children] objectAtIndex:row];
    }
    else {
    }

    if (data) {
        CNPickerData *oldData = [_selects objectAtIndex:component];
        if (oldData != data) {
            CNPickerData *pdata = data;
            NSInteger idx = component;
            while (pdata && idx < _componentCount) {
                [_selects replaceObjectAtIndex:idx withObject:pdata];
                if (pdata && pdata != data) {
                    [_picker selectRow:0 inComponent:idx animated:NO];
                }
                pdata = [[pdata children] firstObject];
                idx++;
            }
            
            [_picker reloadAllComponents];
        }
        
        
        if ([_delegate respondsToSelector:@selector(picker:didSelectRow:inComponent:)]) {
            [_delegate picker:self didSelectRow:data inComponent:component];
        }
    }
}


@end


/**
 *  元素具体申明
 */
@implementation CNPickerData

//@property (nonatomic,copy) NSString *title;
//@property (nonatomic,copy) NSArray <CNPickerData>*children;
//@property (nonatomic,copy) NSDictionary *userInfo;

- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    if (self) {
        _title = [title copy];
        _children = (NSMutableArray <CNPickerData>*)[NSMutableArray array];
    }
    return self;
}
+ (instancetype)dataWithTitle:(NSString *)title {
    return [[CNPickerData alloc] initWithTitle:title];
}

- (id)copyWithZone:(NSZone *)zone {
    CNPickerData *cp = [[self class] dataWithTitle:self.title];
    cp.userInfo = self.userInfo;
    [cp.children setArray:self.children];
    return cp;
}

@end

