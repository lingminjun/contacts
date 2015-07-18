//
//  CNLocationTaggingCell.m
//  contacts
//
//  Created by y_liang on 15/7/18.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNLocationTaggingCell.h"

@implementation CNLocationTaggingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _locationButton = [UIButton cn_location_button];
        _locationButton.ssn_normalImage = cn_image(@"location_label_icon");
        [_locationButton ssn_addTarget:self touchAction:@selector(locationAction:)];
        
        NSUInteger title_width = 60;
        
        _title = [UILabel ssn_labelWithWidth:title_width font:cn_normal_font color:cn_text_normal_color backgroud:cn_clear_color alignment:NSTextAlignmentRight multiLine:NO];
        
        
        //开始布局
        SSNUITableLayout *layout = [self.contentView ssn_tableLayoutWithRowCount:1 columnCount:2];
        layout.contentInset = UIEdgeInsetsMake(0, cn_left_edge_width, 0, cn_right_edge_width);
        
        //固定左右列宽度
        [layout setColumnInfo:ssn_layout_table_column_v2(title_width) atColumn:0];
        //[layout setColumnInfo:ssn_layout_table_column_v2(80) atColumn:1];
        
        //添加元素到cell中
        ssn_layout_add_v2(layout, _title, 0, ssn_layout_table_cell_v2(SSNUIContentModeRight), title);
        ssn_layout_add_v2(layout, _locationButton, 1, ssn_layout_table_cell(0, cn_ver_space_height, 0, cn_right_edge_width, SSNUIContentModeLeft), locationButton);
        
    }
    return self;
}

- (void)ssn_configureCellWithModel:(CNLocationTaggingCellModel *)model atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    [super ssn_configureCellWithModel:model atIndexPath:indexPath inTableView:tableView];
    
    if ([model isKindOfClass:[CNLocationTaggingCellModel class]]) {
        _title.text = model.title;
        _locationButton.ssn_normalTitle = model.subTitle;
    }
}


- (void)locationAction:(id)sender {
    id<CNLocationTaggingCellDelegate> delegate = (id<CNLocationTaggingCellDelegate>)[self ssn_presentingViewController];
    if ([delegate respondsToSelector:@selector(cellLocationButtonAction:)]) {
        [delegate cellLocationButtonAction:self];
    }
}

@end


@implementation CNLocationTaggingCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellClass = [CNLocationTaggingCell class];
        self.hiddenDisclosureIndicator = YES;
    }
    return self;
}

@end


