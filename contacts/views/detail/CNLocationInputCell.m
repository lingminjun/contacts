//
//  CNLocationInputCell.m
//  contacts
//
//  Created by lingminjun on 15/6/22.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNLocationInputCell.h"

@implementation CNLocationInputCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _locationButton = [UIButton cn_location_button];
        _locationButton.ssn_normalImage = cn_image(@"location_label_icon");
        [_locationButton ssn_addTarget:self touchAction:@selector(locationAction:)];
        
        [self.layout setColumnCount:3];
        [self.layout setColumnInfo:ssn_layout_table_column_v2(80) atColumn:2];
        
        //开始布局
        SSNUITableLayout *layout = [self.contentView ssn_tableLayoutWithRowCount:1 columnCount:3];
        layout.contentInset = UIEdgeInsetsMake(0, cn_left_edge_width, 0, cn_right_edge_width);
        
        //固定左右列宽度
        [layout setColumnInfo:ssn_layout_table_column_v2(self.title.ssn_width) atColumn:0];
        [layout setColumnInfo:ssn_layout_table_column_v2(self.locationButton.ssn_width) atColumn:2];
        
        ssn_layout_add_v2(layout, _locationButton, 2, ssn_layout_table_cell_v2(SSNUIContentModeRight), locationButton);
        
    }
    return self;
}

- (void)ssn_configureCellWithModel:(CNLocationInputCellModel *)model atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    [super ssn_configureCellWithModel:model atIndexPath:indexPath inTableView:tableView];
    
    if ([model isKindOfClass:[CNLocationInputCellModel class]]) {
        _locationButton.ssn_normalTitle = model.subTitle;
    }
}


- (void)locationAction:(id)sender {
    id<CNLocationInputCellDelegate> delegate = (id<CNLocationInputCellDelegate>)[self ssn_presentingViewController];
    if ([delegate respondsToSelector:@selector(cellLocationButtonAction:)]) {
        [delegate cellLocationButtonAction:self];
    }
}

@end



@implementation CNLocationInputCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellClass = [CNLocationInputCell class];
        self.hiddenDisclosureIndicator = YES;
    }
    return self;
}

@end