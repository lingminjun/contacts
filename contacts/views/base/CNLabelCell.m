//
//  CNLabelCell.m
//  contacts
//
//  Created by lingminjun on 15/6/14.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNLabelCell.h"

@interface CNLabelCell()

@end

@implementation CNLabelCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        NSUInteger title_width = 60;
        NSUInteger sub_title_width = cn_screen_width - title_width - cn_right_edge_width - cn_hor_inner_space_width - self.disclosureIndicator.ssn_width;
        
        _title = [UILabel ssn_labelWithWidth:title_width font:cn_normal_font color:cn_text_normal_color backgroud:cn_clear_color alignment:NSTextAlignmentRight multiLine:NO];
        
        _subTitle = [UILabel ssn_labelWithWidth:sub_title_width font:cn_normal_font color:cn_text_assist_color backgroud:cn_clear_color alignment:NSTextAlignmentLeft multiLine:NO];
        
        //开始布局
        SSNUITableLayout *layout = [self.contentView ssn_tableLayoutWithRowCount:1 columnCount:2];
        layout.contentInset = UIEdgeInsetsMake(0, cn_left_edge_width, 0, cn_right_edge_width + cn_hor_space_width + self.disclosureIndicator.ssn_width);
        
        //固定左右列宽度
        [layout setColumnInfo:ssn_layout_table_column_v2(title_width) atColumn:0];
        [layout setColumnInfo:ssn_layout_table_column_v2(sub_title_width) atColumn:2];
        
        //添加元素到cell中
        ssn_layout_add_v2(layout, _title, 0, ssn_layout_table_cell_v2(SSNUIContentModeRight), title);
        ssn_layout_add_v2(layout, _subTitle, 1, ssn_layout_table_cell_v2(SSNUIContentModeLeft), subTitle);
        
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _title.text = nil;
    _subTitle.text = nil;
}

- (void)ssn_configureCellWithModel:(CNLabelCellModel *)model atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    [super ssn_configureCellWithModel:model atIndexPath:indexPath inTableView:tableView];
    
    if ([model isKindOfClass:[CNLabelCellModel class]]) {
        _title.text = model.title;
        _subTitle.text = model.subTitle;
    }
}


@end


@implementation CNLabelCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellClass = [CNLabelCell class];
    }
    return self;
}

@end
