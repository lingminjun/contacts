//
//  CNSeparatorCell.m
//  contacts
//
//  Created by lingminjun on 15/7/5.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNSeparatorCell.h"

@implementation CNSeparatorCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundView.backgroundColor = cn_table_group_section_color;
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

- (void)ssn_configureCellWithModel:(CNSeparatorCelllModel *)model atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    [super ssn_configureCellWithModel:model atIndexPath:indexPath inTableView:tableView];
}

@end

@implementation CNSeparatorCelllModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellClass = [CNSeparatorCell class];
        self.cellHeight = cn_ver_section_space_height;
        self.disabledSelect = YES;
        self.hiddenDisclosureIndicator = YES;
    }
    return self;
}


@end
