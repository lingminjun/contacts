//
//  CNUserHeaderCell.h
//  contacts
//
//  Created by lingminjun on 15/6/14.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNTableViewCell.h"

@class CNUserHeaderCell;
@protocol CNUserHeaderCellDelegate <NSObject>

@optional
- (void)cellAvatarDidTouch:(CNUserHeaderCell *)cell;//

@end

@interface CNUserHeaderCell : CNTableViewCell

@property (nonatomic,strong,readonly) UILabel *title;
@property (nonatomic,strong,readonly) UIImageView *avatar;

@end

@interface CNUserHeaderCellModel : CNCellModel

@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *avatarURL;

@end