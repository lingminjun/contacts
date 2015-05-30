//
//  CNIconTitleCell.m
//  contacts
//
//  Created by lingminjun on 15/5/30.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNIconTitleCell.h"

@implementation CNIconTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        NSUInteger icon_width = 26;
        NSUInteger value_width = 60;
        
        _icon = [UIImageView ssn_imageViewWithSize:CGSizeMake(icon_width, icon_width)];
        
        _title = [UILabel ssn_labelWithWidth:100 font:cn_normal_font color:cn_text_normal_color backgroud:cn_clear_color alignment:NSTextAlignmentLeft multiLine:NO];
        _title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _value = [UILabel ssn_labelWithWidth:value_width font:cn_normal_font color:cn_text_assist_color backgroud:cn_clear_color alignment:NSTextAlignmentRight multiLine:NO];
        
        //开始布局
        SSNUITableLayout *layout = [self.contentView ssn_tableLayoutWithRowCount:1 columnCount:3];
        layout.contentInset = UIEdgeInsetsMake(0, cn_left_edge_width, 0, cn_right_edge_width + cn_hor_space_width + self.disclosureIndicator.ssn_width);
        
        //固定左右列宽度
        [layout setColumnInfo:ssn_layout_table_column_v2(icon_width + 2*cn_hor_space_width) atColumn:0];
        [layout setColumnInfo:ssn_layout_table_column_v2(value_width) atColumn:2];
        
        //添加元素到cell中
        ssn_layout_add_v2(layout, _icon, 0, ssn_layout_table_cell_v2(SSNUIContentModeCenter), icon);
        ssn_layout_add_v2(layout, _title, 1, ssn_layout_table_cell(0, 0, 0, cn_hor_space_width, SSNUIContentModeScaleToFill), title);
        ssn_layout_add_v2(layout, _value, 2, ssn_layout_table_cell_v2(SSNUIContentModeRight), value);
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _icon.image = nil;
    _title.text = nil;
    _value.text = nil;
}

- (void)ssn_configureCellWithModel:(CNIconTitleCellModel *)model atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    [super ssn_configureCellWithModel:model atIndexPath:indexPath inTableView:tableView];
    
    if ([model isKindOfClass:[CNIconTitleCellModel class]]) {
        if ([model.iconName length]) {
            _icon.image = cn_image(model.iconName);
        }
        else {
            _icon.image = 0;
        }
        
        _title.text = model.title;
        _value.text = model.value;
    }
}

@end


@implementation CNIconTitleCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellClass = [CNIconTitleCell class];
    }
    return self;
}

@end