//
//  CNTableViewCell.m
//  contacts
//
//  Created by lingminjun on 15/5/28.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNTableViewCell.h"

@implementation CNTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.backgroundView.backgroundColor = cn_table_cell_normal_color;
        
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.selectedBackgroundView.backgroundColor = cn_table_cell_selected_color;
        
        //
        _topLine = [UIImageView ssn_lineWithWidth:self.contentView.ssn_width color:cn_separator_line_color orientation:UIInterfaceOrientationPortrait];
        _topLine.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        _topLine.ssn_left = 0;
        _topLine.ssn_top = 0;
        _topLine.hidden = YES;
        [self.contentView addSubview:_topLine];
        
        //
        _bottomLine = [UIImageView ssn_lineWithWidth:self.contentView.ssn_width color:cn_separator_line_color orientation:UIInterfaceOrientationPortraitUpsideDown];
        _bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        _bottomLine.ssn_left = 0;
        _bottomLine.ssn_bottom = self.contentView.ssn_bottom;
        [self.contentView addSubview:_bottomLine];
        
        //
        _disclosureIndicator = [UIImageView ssn_imageViewWithImage:cn_image(@"icon_disclosure_indicator")];
        _disclosureIndicator.ssn_right = self.contentView.ssn_width - cn_right_edge_width;
        _disclosureIndicator.ssn_center_y = self.contentView.ssn_center_y;
        _disclosureIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:_disclosureIndicator];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _topLine.hidden = YES;
    _topLine.ssn_left = 0;
    _topLine.ssn_width = self.contentView.ssn_width;
    
    
    _bottomLine.hidden = NO;
    _bottomLine.ssn_left = 0;
    _bottomLine.ssn_width = self.contentView.ssn_width;
    
    _disclosureIndicator.hidden = NO;
}

- (void)ssn_configureCellWithModel:(CNCellModel *)model atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    [super ssn_configureCellWithModel:model atIndexPath:indexPath inTableView:tableView];
    
    if ([model isKindOfClass:[CNCellModel class]]) {
        self.topLine.hidden = model.hiddenTopLine;
        self.topLine.ssn_left = model.topLineHeaderSpace;
        self.topLine.ssn_width = self.contentView.ssn_width - model.topLineHeaderSpace;
        
        self.bottomLine.hidden = model.hiddenBottomLine;
        self.bottomLine.ssn_left = model.bottomLineHeaderSpace;
        self.bottomLine.ssn_width = self.contentView.ssn_width - model.bottomLineHeaderSpace;
        
        self.disclosureIndicator.hidden = model.hiddenDisclosureIndicator;
    }
}

@end

@implementation CNCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellClass = [CNTableViewCell class];
        _hiddenTopLine = YES;
    }
    return self;
}

@end

