//
//  CNLocationLableCell.m
//  contacts
//
//  Created by y_liang on 15/7/18.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNLocationLableCell.h"

@implementation CNLocationLableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        NSUInteger title_width = 60;
        
        _title = [UILabel ssn_labelWithWidth:title_width font:cn_normal_font color:cn_text_normal_color backgroud:cn_clear_color alignment:NSTextAlignmentLeft multiLine:NO]; _title.backgroundColor = [UIColor redColor];
        
        _subTitle = [UILabel ssn_labelWithWidth:self.ssn_width - title_width font:cn_normal_font color:cn_text_normal_color backgroud:cn_clear_color alignment:NSTextAlignmentLeft multiLine:NO]; _subTitle.backgroundColor = [UIColor greenColor];
        
        
        //开始布局
        SSNUITableLayout *layout = [self.contentView ssn_tableLayoutWithRowCount:1 columnCount:2];
        layout.contentInset = UIEdgeInsetsMake(0, cn_left_edge_width, 0, 0);
        _layout = layout;
        
        //固定左右列宽度
        [layout setColumnInfo:ssn_layout_table_column_v2(title_width) atColumn:0];
        
        //添加元素到cell中
        ssn_layout_add_v2(layout, _title, 0, ssn_layout_table_cell_v2(SSNUIContentModeRight), title);
        ssn_layout_add_v2(layout, _subTitle, 1, ssn_layout_table_cell(0, cn_ver_space_height, 0, cn_right_edge_width, SSNUIContentModeScaleToFill), subTitle);
        
    }
    return self;
}

- (void)ssn_configureCellWithModel:(CNLocationLableCellModel *)model atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    [super ssn_configureCellWithModel:model atIndexPath:indexPath inTableView:tableView];
    
    if ([model isKindOfClass:[CNLocationLableCellModel class]]) {
        _title.text = model.title;
        _subTitle.text = model.subTitle;
    }
}


@end


@implementation CNLocationLableCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellClass = [CNLocationLableCell class];
        self.hiddenDisclosureIndicator = YES;
    }
    return self;
}

@end
