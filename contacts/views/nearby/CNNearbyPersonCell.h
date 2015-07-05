//
//  CNNearbyPersonCell.h
//  contacts
//
//  Created by y_liang on 15/7/5.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNTableViewCell.h"


@class CNNearbyPersonCell;
@protocol CNNearbyPersonCellDelegate <NSObject>

@optional
- (void)callAction:(CNNearbyPersonCell *)cell;
- (void)gpsAction:(CNNearbyPersonCell *)cell;

@end


@interface CNNearbyPersonCell : CNTableViewCell

@property (nonatomic, strong, readonly) UILabel * nameLabel;
@property (nonatomic, strong, readonly) UILabel * addressLabel;
@property (nonatomic, strong, readonly) UILabel * distanceLabel;
@property (nonatomic, strong, readonly) UIButton * callPhoneBtn;
@property (nonatomic, strong, readonly) UIButton * gpsBtn;

@end



@interface CNNearbyPersonCellModel : CNCellModel

@property (nonatomic,strong) CNPerson *person;

@end