//
//  CNStatementCell.m
//  contacts
//
//  Created by lingminjun on 15/5/31.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNStatementCell.h"

@interface CNStatementCell()

@property (nonatomic,strong) SSNUITableLayout *layout;

@end

@implementation CNStatementCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _statement = [UILabel ssn_labelWithWidth:60 font:cn_normal_font color:cn_text_normal_color backgroud:cn_clear_color alignment:NSTextAlignmentLeft multiLine:YES];
        _statement.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        //开始布局
        _layout = [self.contentView ssn_tableLayoutWithRowCount:1 columnCount:1];
        _layout.contentInset = UIEdgeInsetsMake(cn_top_edge_height, cn_left_edge_width, cn_bottom_edge_height, cn_right_edge_width);
        
        //添加元素到cell中
        ssn_layout_add_v2(_layout, _statement, 0, ssn_layout_table_cell_v2(SSNUIContentModeScaleToFill), statement);
        
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _statement.text = nil;
    _layout.contentInset = UIEdgeInsetsMake(cn_top_edge_height, cn_left_edge_width, cn_bottom_edge_height, cn_right_edge_width);
}

- (void)ssn_configureCellWithModel:(CNStatementCellModel *)model atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    [super ssn_configureCellWithModel:model atIndexPath:indexPath inTableView:tableView];
    
    if ([model isKindOfClass:[CNStatementCellModel class]]) {
        _statement.text = model.statement;
        _statement.ssn_max_width = self.ssn_width - model.leftEdgeWidth - cn_right_edge_width;
        [_statement ssn_sizeToFit];
        
        _layout.contentInset = UIEdgeInsetsMake(cn_top_edge_height, model.leftEdgeWidth, cn_bottom_edge_height, cn_right_edge_width);
        [_layout layoutSubviews];
        
        //计算cell高度
        model.cellHeight = _statement.ssn_height + cn_top_edge_height + cn_bottom_edge_height;
    }
}

@end

@implementation CNStatementCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellClass = [CNStatementCell class];
        self.leftEdgeWidth = cn_left_edge_width;
        self.disabledSelect = YES;
        self.hiddenDisclosureIndicator = YES;
    }
    return self;
}


@end

