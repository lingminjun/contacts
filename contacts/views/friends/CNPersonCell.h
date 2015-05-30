//
//  CNPersonCell.h
//  contacts
//
//  Created by lingminjun on 15/5/30.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNTableViewCell.h"

@interface CNPersonCell : CNTableViewCell

@property (nonatomic,strong,readonly) UILabel *name;

@end


@interface CNPersonCellModel : CNCellModel

@property (nonatomic,strong) CNPerson *person;

@end
