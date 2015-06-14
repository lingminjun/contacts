//
//  CNSelectionCell.m
//  contacts
//
//  Created by lingminjun on 15/5/29.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNSelectionCell.h"

@implementation CNSelectionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        NSUInteger title_width = 60;
        NSUInteger button_width = 60;
        NSUInteger button_height = 30;
        
        _title = [UILabel ssn_labelWithWidth:title_width font:cn_normal_font color:cn_text_normal_color backgroud:cn_clear_color alignment:NSTextAlignmentRight multiLine:NO];
        
        _radio1 = [UIButton ssn_buttonWithSize:CGSizeMake(button_width, button_height) font:cn_normal_font color:cn_text_normal_color selected:cn_text_normal_color disabled:nil backgroud:nil selected:nil disabled:nil];
        _radio1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _radio1.ssn_normalImage = cn_image(@"icon_radio_normal");
        _radio1.ssn_selectedImage = cn_image(@"icon_radio_selected");
        _radio1.titleEdgeInsets = UIEdgeInsetsMake(0, cn_hor_inner_space_width, 0, 0);
        [_radio1 ssn_addTarget:self touchAction:@selector(radio1Action:)];
        
        _radio2 = [UIButton ssn_buttonWithSize:CGSizeMake(button_width, button_height) font:cn_normal_font color:cn_text_normal_color selected:cn_text_normal_color disabled:nil backgroud:nil selected:nil disabled:nil];
        _radio2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _radio2.ssn_normalImage = cn_image(@"icon_radio_normal");
        _radio2.ssn_selectedImage = cn_image(@"icon_radio_selected");
        _radio2.titleEdgeInsets = UIEdgeInsetsMake(0, cn_hor_inner_space_width, 0, 0);
        [_radio2 ssn_addTarget:self touchAction:@selector(radio2Action:)];
        
        //开始布局
        SSNUITableLayout *layout = [self.contentView ssn_tableLayoutWithRowCount:1 columnCount:3];
        layout.contentInset = UIEdgeInsetsMake(0, cn_left_edge_width, 0, cn_right_edge_width + cn_hor_space_width + self.disclosureIndicator.ssn_width);
        
        //固定左右列宽度
        [layout setColumnInfo:ssn_layout_table_column_v2(title_width) atColumn:0];
        [layout setColumnInfo:ssn_layout_table_column_v2(button_width+cn_hor_space_width) atColumn:1];
        [layout setColumnInfo:ssn_layout_table_column_v2(button_width) atColumn:2];
        
        //添加元素到cell中
        ssn_layout_add_v2(layout, _title, 0, ssn_layout_table_cell_v2(SSNUIContentModeRight), title);
        ssn_layout_add_v2(layout, _radio1, 1, ssn_layout_table_cell(0, cn_hor_space_width, 0, 0, SSNUIContentModeLeft), radio1);
        ssn_layout_add_v2(layout, _radio2, 2, ssn_layout_table_cell_v2(SSNUIContentModeLeft), radio2);
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _title.text = nil;
    _radio1.ssn_normalTitle = nil;
    _radio2.ssn_normalTitle = nil;
    
    _radio1.selected = YES;
    _radio2.selected = NO;
}

- (void)radio1Action:(id)sender {
    _radio1.selected = YES;
    _radio2.selected = NO;
    
    id<CNSelectionCellDelegate> delegate = (id<CNSelectionCellDelegate>)(self.ssn_presentingViewController);
    if ([delegate respondsToSelector:@selector(cellRadioDidSelect:)]) {
        
        if ([self.ssn_cellModel isKindOfClass:[CNSelectionCellModel class]]) {
            [(CNSelectionCellModel *)self.ssn_cellModel setValue:0];
        }
        
        [delegate cellRadioDidSelect:self];
    }
    
    if ([self.ssn_cellModel isKindOfClass:[CNSelectionCellModel class]]) {
        [(CNSelectionCellModel *)self.ssn_cellModel setValue:0];
    }
}

- (void)radio2Action:(id)sender {
    _radio1.selected = NO;
    _radio2.selected = YES;
    
    id<CNSelectionCellDelegate> delegate = (id<CNSelectionCellDelegate>)(self.ssn_presentingViewController);
    if ([delegate respondsToSelector:@selector(cellRadioDidSelect:)]) {
        
        if ([self.ssn_cellModel isKindOfClass:[CNSelectionCellModel class]]) {
            [(CNSelectionCellModel *)self.ssn_cellModel setValue:1];
        }
        
        [delegate cellRadioDidSelect:self];
    }
    
    if ([self.ssn_cellModel isKindOfClass:[CNSelectionCellModel class]]) {
        [(CNSelectionCellModel *)self.ssn_cellModel setValue:1];
    }
}

- (void)ssn_configureCellWithModel:(CNSelectionCellModel *)model atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    [super ssn_configureCellWithModel:model atIndexPath:indexPath inTableView:tableView];
    
    if ([model isKindOfClass:[CNSelectionCellModel class]]) {
        _title.text = model.title;
        _radio1.ssn_normalTitle = model.radio1;
        _radio2.ssn_normalTitle = model.radio2;
        
        _radio1.selected = model.value == 0;
        _radio2.selected = model.value == 1;
    }
}


@end

@implementation CNSelectionCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellClass = [CNSelectionCell class];
        self.hiddenDisclosureIndicator = YES;
        self.disabledSelect = YES;
    }
    return self;
}

@end

