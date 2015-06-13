//
//  CNContactsSection.m
//  contacts
//
//  Created by lingminjun on 15/6/13.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNContactsSection.h"

@implementation CNContactsSection

- (instancetype)initWithTitle:(NSString *)title {
    self = [super initWithFrame:CGRectMake(0, 0, cn_screen_width, cn_contacts_section_height)];
    if (self) {
        
        self.backgroundColor = cn_table_section_color;
        
        SSNUITableLayout *layout = [self ssn_tableLayoutWithRowCount:1 columnCount:3];
        layout.contentInset = UIEdgeInsetsMake(0, cn_left_edge_width, 0, cn_right_edge_width);
        [layout setColumnInfo:ssn_layout_table_column(cn_contacts_section_height, SSNUIContentModeCenter) atColumn:1];
        
        //
        int width = (cn_screen_width/2 - cn_left_edge_width - cn_hor_space_width);
        int index = 0;
        
        _titleLabel = [UILabel ssn_labelWithWidth:width font:cn_title_font color:cn_text_normal_color backgroud:[UIColor clearColor] alignment:NSTextAlignmentLeft multiLine:NO];
        ssn_layout_add_v2(layout, _titleLabel, index++, ssn_layout_table_cell_v2(SSNUIContentModeLeft), titleLabel);
        
        _distanceIcon = [UIImageView ssn_imageViewWithImage:cn_image(@"location_icon")];
        ssn_layout_add_v2(layout, _distanceIcon, index++, ssn_layout_table_cell_v2(SSNUIContentModeCenter), distanceIcon);
        
        _distanceLabel = [UILabel ssn_labelWithWidth:width font:cn_normal_font color:cn_text_assist_color backgroud:[UIColor clearColor] alignment:NSTextAlignmentLeft multiLine:NO];
        ssn_layout_add_v2(layout, _distanceLabel, index++, ssn_layout_table_cell_v2(SSNUIContentModeLeft), distanceLabel);
        
        _titleLabel.text = title;
        _distanceLabel.text = cn_localized(@"friends.distance.label");
    }
    return self;
}

+ (instancetype)sectionWithTitle:(NSString *)title {
    return [[[self class] alloc] initWithTitle:title];
}

@end
