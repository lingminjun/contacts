//
//  CNLocalPointCell.m
//  contacts
//
//  Created by lingminjun on 15/6/27.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNLocalPointCell.h"


@implementation CNLocalPointCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
         _icon = [UIImageView ssn_imageViewWithImage:cn_image(@"icon_location")];
        
        NSUInteger name_width = cn_screen_width - cn_left_edge_width - cn_right_edge_width - cn_hor_space_width - _icon.ssn_width;
        
        _address = [UILabel ssn_labelWithWidth:name_width font:cn_normal_font color:cn_text_normal_color backgroud:cn_clear_color alignment:NSTextAlignmentLeft multiLine:NO];
        
        
        //开始布局
        SSNUITableLayout *layout = [self.contentView ssn_tableLayoutWithRowCount:1 columnCount:2];
        layout.contentInset = UIEdgeInsetsMake(0, cn_left_edge_width, 0, cn_right_edge_width);
        
        [layout setColumnInfo:ssn_layout_table_column_v2(_icon.ssn_width + cn_hor_space_width) atColumn:1];
        
        //添加元素到cell中
        ssn_layout_add_v2(layout, _address, 0, ssn_layout_table_cell_v2(SSNUIContentModeLeft), address);
        ssn_layout_add_v2(layout, _icon, 1, ssn_layout_table_cell_v2(SSNUIContentModeRight), icon);
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _address.text = nil;
}


- (void)ssn_configureCellWithModel:(CNLocalPointCellModel *)model atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    [super ssn_configureCellWithModel:model atIndexPath:indexPath inTableView:tableView];
    
    if ([model isKindOfClass:[CNLocalPointCellModel class]]) {
        _address.text = [NSString stringWithFormat:@"%@%@",model.point.address,model.point.name];
    }
    
    //根据位置隐藏底线
    self.bottomLine.hidden = (indexPath.row + 1 >= [tableView numberOfRowsInSection:indexPath.section]);
}



@end


@implementation CNLocalPointCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellClass = [CNLocalPointCell class];
        self.bottomLineHeaderSpace = cn_left_edge_width;
        self.hiddenDisclosureIndicator = YES;
    }
    return self;
}

@end
