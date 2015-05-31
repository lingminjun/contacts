//
//  CNStatementCell.h
//  contacts
//
//  Created by lingminjun on 15/5/31.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNTableViewCell.h"

@interface CNStatementCell : CNTableViewCell

@property (nonatomic,strong,readonly) UILabel *statement;

@end

@interface CNStatementCellModel : CNCellModel

@property (nonatomic,copy) NSString *statement;
@property (nonatomic) NSUInteger leftEdgeWidth;

@end