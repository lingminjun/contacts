//
//  CNLocalPointCell.h
//  contacts
//
//  Created by lingminjun on 15/6/27.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNTableViewCell.h"
#import "CNLocationPoint.h"

@interface CNLocalPointCell : CNTableViewCell

@property (nonatomic,strong,readonly) UILabel *name;
@property (nonatomic,strong,readonly) UILabel *address;
@property (nonatomic,strong,readonly) UIImageView *icon;

@end


@interface CNLocalPointCellModel : CNCellModel

@property (nonatomic,assign) BOOL needShowIndex;
@property (nonatomic,strong) CNLocationPoint *point;

@end