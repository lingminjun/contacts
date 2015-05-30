//
//  CNPersonCell.m
//  contacts
//
//  Created by lingminjun on 15/5/30.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNPersonCell.h"

@implementation CNPersonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        NSUInteger name_width = 100;
        
        _name = [UILabel ssn_labelWithWidth:name_width font:cn_normal_font color:cn_text_normal_color backgroud:cn_clear_color alignment:NSTextAlignmentLeft multiLine:NO];
        
        
        //开始布局
        SSNUITableLayout *layout = [self.contentView ssn_tableLayoutWithRowCount:1 columnCount:1];
        layout.contentInset = UIEdgeInsetsMake(0, cn_left_edge_width, 0, cn_right_edge_width + cn_hor_space_width + self.disclosureIndicator.ssn_width);
        
        //添加元素到cell中
        ssn_layout_add_v2(layout, _name, 0, ssn_layout_table_cell_v2(SSNUIContentModeLeft), name);
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _name.text = nil;
}


- (void)ssn_configureCellWithModel:(CNPersonCellModel *)model atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    [super ssn_configureCellWithModel:model atIndexPath:indexPath inTableView:tableView];
    
    if ([model isKindOfClass:[CNPersonCellModel class]]) {
        _name.text = model.person.name;
    }
}



@end


@implementation CNPersonCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellClass = [CNPersonCell class];
    }
    return self;
}

- (NSString *)cellSectionIdentify {
    return [NSString stringWithFormat:@"%c",self.person.firstSpell];
}

- (NSComparisonResult)ssn_compare:(CNPersonCellModel *)model {
    return [self.person.pinyin compare:model.person.pinyin];
}

- (BOOL)isEqual:(CNPersonCellModel *)object {
    return [self.person isEqual:object.person];
}

- (NSUInteger)hash {
    return [self.person hash];
}

@end