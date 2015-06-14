//
//  CNSectionCell.h
//  contacts
//
//  Created by lingminjun on 15/6/14.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNTableViewCell.h"

@interface CNSectionCell : CNTableViewCell

@property (nonatomic,strong,readonly) UILabel *title;

@end


@interface CNSectionCellModel : CNCellModel

@property (nonatomic,copy) NSString *title;

@end

