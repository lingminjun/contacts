//
//  CNIconTitleCell.h
//  contacts
//
//  Created by lingminjun on 15/5/30.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNTableViewCell.h"

@interface CNIconTitleCell : CNTableViewCell

@property (nonatomic,strong,readonly) UIImageView *icon;
@property (nonatomic,strong,readonly) UILabel *title;
@property (nonatomic,strong,readonly) UILabel *value;

@end

@interface CNIconTitleCellModel : CNCellModel

@property (nonatomic,copy) NSString *iconName;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *value;

@end
