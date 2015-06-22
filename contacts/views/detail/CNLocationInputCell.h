//
//  CNLocationInputCell.h
//  contacts
//
//  Created by lingminjun on 15/6/22.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNLabelInputCell.h"

@class CNLocationInputCell;
@protocol CNLocationInputCellDelegate <NSObject>

@optional
- (void)cellLocationButtonAction:(CNLocationInputCell *)cell;//

@end

@interface CNLocationInputCell : CNLabelInputCell

@property (nonatomic,strong,readonly) UIButton *locationButton;

@end


@interface CNLocationInputCellModel : CNLabelInputCellModel

@end