//
//  CNLabelCell.h
//  contacts
//
//  Created by lingminjun on 15/6/14.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNTableViewCell.h"


@interface CNLabelCell : CNTableViewCell

@property (nonatomic,strong,readonly) UILabel *title;
@property (nonatomic,strong,readonly) UILabel *subTitle;

@end

@interface CNLabelCellModel : CNCellModel

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subTitle;

@end
