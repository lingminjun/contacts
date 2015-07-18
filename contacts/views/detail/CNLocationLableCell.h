//
//  CNLocationLableCell.h
//  contacts
//
//  Created by y_liang on 15/7/18.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNTableViewCell.h"

@interface CNLocationLableCell : CNTableViewCell

@property (nonatomic,strong,readonly) UILabel *title;
@property (nonatomic,strong,readonly) UILabel *subTitle;

@property (nonatomic,strong) SSNUITableLayout *layout;

@end


@interface CNLocationLableCellModel : CNCellModel

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subTitle;

@end