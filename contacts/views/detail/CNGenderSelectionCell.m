//
//  CNGenderSelectionCell.m
//  contacts
//
//  Created by lingminjun on 15/5/29.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNGenderSelectionCell.h"

@implementation CNGenderSelectionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        NSUInteger title_width = 60;
        NSUInteger button_width = 60;
        NSUInteger button_height = 30;
        
        _title = [UILabel ssn_labelWithWidth:title_width font:cn_normal_font color:cn_text_normal_color backgroud:cn_clear_color alignment:NSTextAlignmentRight multiLine:NO];
        
        _male = [UIButton ssn_buttonWithSize:CGSizeMake(button_width, button_height) font:cn_normal_font color:cn_text_normal_color selected:cn_text_normal_color disabled:nil backgroud:nil selected:nil disabled:nil];
        _male.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _male.ssn_normalImage = cn_image(@"icon_radio_normal");
        _male.ssn_selectedImage = cn_image(@"icon_radio_selected");
        _male.ssn_selectedTitle = cn_localized(@"common.male.label");
        _male.titleEdgeInsets = UIEdgeInsetsMake(0, cn_hor_inner_space_width, 0, 0);
        [_male ssn_addTarget:self touchAction:@selector(maleAction:)];
        
        _female = [UIButton ssn_buttonWithSize:CGSizeMake(button_width, button_height) font:cn_normal_font color:cn_text_normal_color selected:cn_text_normal_color disabled:nil backgroud:nil selected:nil disabled:nil];
        _female.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _female.ssn_normalImage = cn_image(@"icon_radio_normal");
        _female.ssn_selectedImage = cn_image(@"icon_radio_selected");
        _female.ssn_normalTitle = cn_localized(@"common.female.label");
        _female.titleEdgeInsets = UIEdgeInsetsMake(0, cn_hor_inner_space_width, 0, 0);
        [_female ssn_addTarget:self touchAction:@selector(femaleAction:)];
        
        //开始布局
        SSNUITableLayout *layout = [self.contentView ssn_tableLayoutWithRowCount:1 columnCount:3];
        layout.contentInset = UIEdgeInsetsMake(0, cn_left_edge_width, 0, cn_right_edge_width + cn_hor_space_width + self.disclosureIndicator.ssn_width);
        
        //固定左右列宽度
        [layout setColumnInfo:ssn_layout_table_column_v2(title_width) atColumn:0];
        [layout setColumnInfo:ssn_layout_table_column_v2(button_width+cn_hor_space_width) atColumn:1];
        [layout setColumnInfo:ssn_layout_table_column_v2(button_width) atColumn:2];
        
        //添加元素到cell中
        ssn_layout_add_v2(layout, _title, 0, ssn_layout_table_cell_v2(SSNUIContentModeRight), title);
        ssn_layout_add_v2(layout, _male, 1, ssn_layout_table_cell(0, cn_hor_space_width, 0, 0, SSNUIContentModeLeft), male);
        ssn_layout_add_v2(layout, _female, 2, ssn_layout_table_cell_v2(SSNUIContentModeLeft), female);
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _title.text = nil;
    _male.selected = YES;
    _female.selected = NO;
}

- (void)maleAction:(id)sender {
    _male.selected = YES;
    _female.selected = NO;
    
    id<CNGenderSelectionCellDelegate> delegate = (id<CNGenderSelectionCellDelegate>)(self.ssn_presentingViewController);
    if ([delegate respondsToSelector:@selector(cellGenderDidSelect:)]) {
        
        if ([self.ssn_cellModel isKindOfClass:[CNGenderSelectionCellModel class]]) {
            [(CNGenderSelectionCellModel *)self.ssn_cellModel setGender:CNPersonMaleGender];
        }
        
        [delegate cellGenderDidSelect:self];
    }
    
    if ([self.ssn_cellModel isKindOfClass:[CNGenderSelectionCellModel class]]) {
        [(CNGenderSelectionCellModel *)self.ssn_cellModel setGender:CNPersonMaleGender];
    }
}

- (void)femaleAction:(id)sender {
    _male.selected = NO;
    _female.selected = YES;
    
    id<CNGenderSelectionCellDelegate> delegate = (id<CNGenderSelectionCellDelegate>)(self.ssn_presentingViewController);
    if ([delegate respondsToSelector:@selector(cellGenderDidSelect:)]) {
        
        if ([self.ssn_cellModel isKindOfClass:[CNGenderSelectionCellModel class]]) {
            [(CNGenderSelectionCellModel *)self.ssn_cellModel setGender:CNPersonFemaleGender];
        }
        
        [delegate cellGenderDidSelect:self];
    }
    
    if ([self.ssn_cellModel isKindOfClass:[CNGenderSelectionCellModel class]]) {
        [(CNGenderSelectionCellModel *)self.ssn_cellModel setGender:CNPersonFemaleGender];
    }
}

- (void)ssn_configureCellWithModel:(CNGenderSelectionCellModel *)model atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    [super ssn_configureCellWithModel:model atIndexPath:indexPath inTableView:tableView];
    
    if ([model isKindOfClass:[CNGenderSelectionCellModel class]]) {
        _title.text = model.title;
        _male.selected = model.gender == CNPersonMaleGender;
        _female.selected = model.gender == CNPersonFemaleGender;
    }
}


@end

@implementation CNGenderSelectionCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellClass = [CNGenderSelectionCell class];
        self.hiddenDisclosureIndicator = YES;
        self.disabledSelect = YES;
    }
    return self;
}

@end

