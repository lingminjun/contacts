//
//  CNSelectionCell.h
//  contacts
//
//  Created by lingminjun on 15/5/29.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNTableViewCell.h"

@class CNSelectionCell;
@protocol CNSelectionCellDelegate <NSObject>

@optional
- (void)cellRadioDidSelect:(CNSelectionCell *)cell;//

@end

@interface CNSelectionCell : CNTableViewCell

@property (nonatomic,strong,readonly) UILabel *title;
@property (nonatomic,strong,readonly) UIButton *radio1;
@property (nonatomic,strong,readonly) UIButton *radio2;

@end


@interface CNSelectionCellModel : CNCellModel

@property (nonatomic,copy) NSString *title;

@property (nonatomic,copy) NSString *radio1;
@property (nonatomic,copy) NSString *radio2;

@property (nonatomic) NSInteger value;//0或1

@end

