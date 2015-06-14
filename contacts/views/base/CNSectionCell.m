//
//  CNSectionCell.m
//  contacts
//
//  Created by lingminjun on 15/6/14.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNSectionCell.h"

@interface CNSectionCell()

@property (nonatomic,strong) SSNUITableLayout *layout;

@end

@implementation CNSectionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundView.backgroundColor = cn_table_group_section_color;
        
        int width = cn_screen_width - cn_left_edge_width - cn_right_edge_width;
        _title = [UILabel ssn_labelWithWidth:width font:cn_normal_font color:cn_text_assist_color backgroud:cn_clear_color alignment:NSTextAlignmentLeft multiLine:YES];
        
        //开始布局
        _layout = [self.contentView ssn_tableLayoutWithRowCount:1 columnCount:1];
        _layout.contentInset = UIEdgeInsetsMake(cn_ver_section_space_height, cn_left_edge_width, cn_ver_inner_space_height, cn_right_edge_width);
        
        //添加元素到cell中
        ssn_layout_add_v2(_layout, _title, 0, ssn_layout_table_cell_v2(SSNUIContentModeBottom), title);
        
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _title.text = nil;
    [_title ssn_sizeToFit];
}

- (void)ssn_configureCellWithModel:(CNSectionCellModel *)model atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    [super ssn_configureCellWithModel:model atIndexPath:indexPath inTableView:tableView];
    
    if ([model isKindOfClass:[CNSectionCellModel class]]) {
        _title.text = model.title;
        [_title ssn_sizeToFit];
        
        [_layout layoutSubviews];
        
        //计算cell高度
        model.cellHeight = _title.ssn_height + cn_ver_section_space_height + cn_ver_inner_space_height;
    }
}

@end

@implementation CNSectionCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellClass = [CNSectionCell class];
        self.cellHeight = cn_ver_section_space_height;
        self.disabledSelect = YES;
        self.hiddenDisclosureIndicator = YES;
    }
    return self;
}


@end