//
//  CNGenderSelectionCell.h
//  contacts
//
//  Created by lingminjun on 15/5/29.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNTableViewCell.h"

@class CNGenderSelectionCell;
@protocol CNGenderSelectionCellDelegate <NSObject>

@optional
- (void)cellGenderDidSelect:(CNGenderSelectionCell *)cell;//

@end

@interface CNGenderSelectionCell : CNTableViewCell

@property (nonatomic,strong,readonly) UILabel *title;
@property (nonatomic,strong,readonly) UIButton *male;
@property (nonatomic,strong,readonly) UIButton *female;

@end


@interface CNGenderSelectionCellModel : CNCellModel

@property (nonatomic,copy) NSString *title;
@property (nonatomic) CNPersonGender gender;

@end

