//
//  CNNearbyPersonCell.m
//  contacts
//
//  Created by y_liang on 15/7/5.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNNearbyPersonCell.h"
#import "CNNearbyPerson.h"

#define NEARBY_CELL_HEIGHT (120.0F)

@implementation CNNearbyPersonCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
            UIImageView *backgroud = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
            backgroud.image = [[UIImage ssn_imageWithColor:cn_backgroud_white_color cornerRadius:2] ssn_centerStretchImage];
            backgroud.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            backgroud.center = ssn_center(self.contentView.bounds);
            ssn_panel_set(self.contentView, backgroud, backgroud);
        
        
        SSNUITableLayout *layout = [self.contentView ssn_tableLayoutWithRowCount:5 columnCount:1];
        layout.contentInset = UIEdgeInsetsMake(cn_top_edge_height, cn_left_edge_width, 0, cn_right_edge_width);
        
        //头部
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cn_screen_width - cn_left_edge_width - cn_right_edge_width, 24)];
        {
            int local_width = 100;
            SSNUITableLayout *ly = [topView ssn_tableLayoutWithRowCount:1 columnCount:2];
            [ly setColumnInfo:ssn_layout_table_column_v2(local_width) atColumn:1];
            
            _nameLabel = [UILabel ssn_labelWithWidth:topView.ssn_width - local_width
                                                font:cn_title_font
                                               color:cn_text_normal_color
                                           backgroud:[UIColor clearColor]
                                           alignment:NSTextAlignmentLeft
                                           multiLine:NO];
            ssn_layout_add_v2(ly, _nameLabel, 0, ssn_layout_table_cell_v2(SSNUIContentModeCenter), _nameLabel);
            
            _distanceLabel = [UILabel ssn_labelWithWidth:local_width
                                                    font:cn_assist_font
                                                   color:cn_text_assist_color
                                               backgroud:[UIColor clearColor]
                                               alignment:NSTextAlignmentRight
                                               multiLine:NO];
            ssn_layout_add_v2(ly, _distanceLabel, 1, ssn_layout_table_cell_v2(SSNUIContentModeCenter), _distanceLabel);
        }
        ssn_layout_add_v2(layout, topView, 0, ssn_layout_table_cell_v2(SSNUIContentModeCenter), topView);
        [layout setRowInfo:ssn_layout_table_row(topView.ssn_height) atRow:0];
        
        //地址名称
        _locationNameLabel = [UILabel ssn_labelWithWidth:cn_screen_width - (cn_left_edge_width + cn_right_edge_width)
                                               font:[UIFont systemFontOfSize:13]
                                              color:[UIColor blackColor]
                                          backgroud:[UIColor clearColor]
                                          alignment:NSTextAlignmentLeft
                                          multiLine:NO];
        [layout setRowInfo:ssn_layout_table_row(20) atRow:1];
        ssn_layout_add_v2(layout, _locationNameLabel, 1, ssn_layout_table_cell_v2(SSNUIContentModeCenter), _locationNameLabel);
        
        //内容
        _addressLabel = [UILabel ssn_labelWithWidth:cn_screen_width - (cn_left_edge_width + cn_right_edge_width)
                                               font:[UIFont systemFontOfSize:12]
                                              color:cn_text_assist_color
                                          backgroud:[UIColor clearColor]
                                          alignment:NSTextAlignmentLeft
                                          multiLine:NO];
        [layout setRowInfo:ssn_layout_table_row(24) atRow:2];
        ssn_layout_add_v2(layout, _addressLabel, 2, ssn_layout_table_cell_v2(SSNUIContentModeCenter), _addressLabel);
        
        //先
        [layout setRowInfo:ssn_layout_table_row(1) atRow:3];
        UIImageView *line = [UIImageView ssn_lineWithWidth:cn_screen_width - (cn_left_edge_width + cn_right_edge_width) color:cn_separator_line_color orientation:UIInterfaceOrientationPortraitUpsideDown];
        ssn_layout_add_v2(layout, line, 3, ssn_layout_table_cell_v2(SSNUIContentModeCenter), line);
        
        //底部
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cn_screen_width - cn_left_edge_width - cn_right_edge_width, 40)];
        {
            SSNUITableLayout *ly = [bottomView ssn_tableLayoutWithRowCount:1 columnCount:3];
            [ly setColumnInfo:ssn_layout_table_column_v2(40) atColumn:1];
            
            UIButton *btn = [UIButton cn_transparent_button];
            btn.ssn_normalTitle = cn_localized(@"location.call.label");
            btn.ssn_normalImage = cn_image(@"icon_call");
            [btn ssn_addTarget:self touchAction:@selector(callAction:)];
            ssn_layout_add_v2(ly, btn, 0, ssn_layout_table_cell_v2(SSNUIContentModeCenter), call);
            _callPhoneBtn = btn;
            
            UIImageView *line = [UIImageView ssn_lineWithWidth:30 color:cn_separator_line_color orientation:UIInterfaceOrientationLandscapeLeft];
            ssn_layout_add_v2(ly, line, 1, ssn_layout_table_cell_v2(SSNUIContentModeCenter), line);
            
            btn = [UIButton cn_transparent_button];
            btn.ssn_normalTitle = cn_localized(@"location.gps.label");
            btn.ssn_normalImage = cn_image(@"icon_gps");
            [btn ssn_addTarget:self touchAction:@selector(gpsAction:)];
            
            ssn_layout_add_v2(ly, btn, 2, ssn_layout_table_cell_v2(SSNUIContentModeCenter), gps);
            _gpsBtn = btn;
        }
        
        [layout setRowInfo:ssn_layout_table_row(bottomView.ssn_height) atRow:4];
        ssn_layout_add_v2(layout, bottomView, 4, ssn_layout_table_cell_v2(SSNUIContentModeCenter), bottomView);
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _nameLabel.text = nil;
    _addressLabel.text = nil;
    _distanceLabel.text = nil;
    _locationNameLabel.text = nil;
}


- (void)callAction:(id)sender {
    id<CNNearbyPersonCellDelegate> delegate = (id<CNNearbyPersonCellDelegate>)[self ssn_presentingViewController];
    if ([delegate respondsToSelector:@selector(callAction:)]) {
        [delegate callAction:self];
    }
}

- (void)gpsAction:(id)sender {
    id<CNNearbyPersonCellDelegate> delegate = (id<CNNearbyPersonCellDelegate>)[self ssn_presentingViewController];
    if ([delegate respondsToSelector:@selector(gpsAction:)]) {
        [delegate gpsAction:self];
    }
}

- (void)ssn_configureCellWithModel:(CNNearbyPersonCellModel *)model atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    [super ssn_configureCellWithModel:model atIndexPath:indexPath inTableView:tableView];
    
    if ([model isKindOfClass:[CNNearbyPersonCellModel class]]) {
        NSString * addressLabel = model.person.addressLabel == CNCompanyAddressLabel ? @"公司" : @"家";
        _locationNameLabel.text = model.person.locationPointName;
        _nameLabel.text = [NSString stringWithFormat:@"%ld.%@-%@",(long)model.person.nearbyIndex,model.person.name, addressLabel];
        _addressLabel.text = model.person.street;
        if (model.person.distance > 0.009f ) {
            _distanceLabel.text = [NSString stringWithFormat:@"%.2fkm",model.person.nearbyDistance];
        }
    }
    
    //根据位置隐藏底线
    self.bottomLine.hidden = (indexPath.row + 1 >= [tableView numberOfRowsInSection:indexPath.section]);
}

@end



@implementation CNNearbyPersonCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellClass = [CNNearbyPersonCell class];
        self.cellHeight = NEARBY_CELL_HEIGHT;
        self.hiddenDisclosureIndicator = YES;
        self.hiddenTopLine = NO;
    }
    return self;
}


@end
