//
//  CNLocationTaggingCell.h
//  contacts
//
//  Created by y_liang on 15/7/18.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNTableViewCell.h"





@class CNLocationTaggingCell;
@protocol CNLocationTaggingCellDelegate <NSObject>

@optional
- (void)cellLocationButtonAction:(CNLocationTaggingCell *)cell;//

@end


@interface CNLocationTaggingCell : CNTableViewCell

@property (nonatomic,strong,readonly) UILabel *title;
@property (nonatomic,strong,readonly) UIButton *locationButton;

@end


@interface CNLocationTaggingCellModel : CNCellModel

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subTitle;

@end