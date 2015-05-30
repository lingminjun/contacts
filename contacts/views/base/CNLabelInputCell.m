//
//  CNLabelInputCell.m
//  contacts
//
//  Created by lingminjun on 15/5/28.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNLabelInputCell.h"

@interface CNLabelInputCell()

@end

@implementation CNLabelInputCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        NSUInteger title_width = 60;
        NSUInteger sub_title_width = 60;
        
        _title = [UILabel ssn_labelWithWidth:title_width font:cn_normal_font color:cn_text_normal_color backgroud:cn_clear_color alignment:NSTextAlignmentRight multiLine:NO];
        
        _input = [UITextField ssn_inputWithSize:CGSizeMake(100, ssn_ceil(cn_normal_font.lineHeight + 2*cn_ver_space_height)) font:cn_normal_font color:cn_text_normal_color adjustFont:NO minFont:12];
        _input.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_input addTarget:self action:@selector(inputEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        
        _subTitle = [UILabel ssn_labelWithWidth:sub_title_width font:cn_normal_font color:cn_text_assist_color backgroud:cn_clear_color alignment:NSTextAlignmentRight multiLine:NO];
        
        //开始布局
        SSNUITableLayout *layout = [self.contentView ssn_tableLayoutWithRowCount:1 columnCount:3];
        layout.contentInset = UIEdgeInsetsMake(0, cn_left_edge_width, 0, cn_right_edge_width + cn_hor_space_width + self.disclosureIndicator.ssn_width);
        
        //固定左右列宽度
        [layout setColumnInfo:ssn_layout_table_column_v2(title_width) atColumn:0];
        [layout setColumnInfo:ssn_layout_table_column_v2(sub_title_width) atColumn:2];
        
        //添加元素到cell中
        ssn_layout_add_v2(layout, _title, 0, ssn_layout_table_cell_v2(SSNUIContentModeRight), title);
        ssn_layout_add_v2(layout, _input, 1, ssn_layout_table_cell(0, cn_ver_space_height, 0, cn_ver_space_height, SSNUIContentModeScaleToFill), input);
        ssn_layout_add_v2(layout, _subTitle, 2, ssn_layout_table_cell_v2(SSNUIContentModeRight), subTitle);
        
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _title.text = nil;
    _input.ssn_maxLength = 0;
    _input.ssn_characterLimit = nil;
    _input.ssn_format = nil;
    _input.placeholder = nil;
    _input.text = nil;
    _input.keyboardType = UIKeyboardTypeDefault;
    _subTitle.text = nil;
}

- (void)ssn_configureCellWithModel:(CNLabelInputCellModel *)model atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    [super ssn_configureCellWithModel:model atIndexPath:indexPath inTableView:tableView];
    
    if ([model isKindOfClass:[CNLabelInputCellModel class]]) {
        _title.text = model.title;
        _input.ssn_maxLength = model.inputMaxLength;
        _input.ssn_characterLimit = model.inputCharacterSet;
        _input.ssn_format = model.inputFormat;
        _input.placeholder = model.inputPlaceholder;
        if (model.inputFormat) {
            _input.text = model.inputFormat(model.input);
        }
        else {
            _input.text = model.input;
        }
        _input.keyboardType = model.keyboardType;
        _subTitle.text = model.subTitle;
    }
}

- (void)inputEditingChanged:(id)sender {
    id<CNLabelInputCellDelegate> delegate = (id<CNLabelInputCellDelegate>)(self.ssn_presentingViewController);
    if ([delegate respondsToSelector:@selector(cellInputDidChange:)]) {
        
        if ([self.ssn_cellModel isKindOfClass:[CNLabelInputCellModel class]]) {
            [(CNLabelInputCellModel *)self.ssn_cellModel setInput:_input.text];
        }
        
        [delegate cellInputDidChange:self];
    }
    
    if ([self.ssn_cellModel isKindOfClass:[CNLabelInputCellModel class]]) {
        [(CNLabelInputCellModel *)self.ssn_cellModel setInput:_input.text];
    }
}


@end


@implementation CNLabelInputCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellClass = [CNLabelInputCell class];
    }
    return self;
}

@end