//
//  CNTableViewCell.h
//  contacts
//
//  Created by lingminjun on 15/5/28.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNTableViewCell : UITableViewCell<SSNVMCellProtocol>

@property (nonatomic,strong,readonly) UIImageView *topLine;
@property (nonatomic,strong,readonly) UIImageView *bottomLine;
@property (nonatomic,strong,readonly) UIImageView *disclosureIndicator;

@end


@interface CNCellModel : SSNVMCellItem

@property (nonatomic) BOOL hiddenTopLine;//默认隐藏
@property (nonatomic) BOOL hiddenBottomLine;//默认不隐藏

@property (nonatomic) NSUInteger topLineHeaderSpace;//topLine左边距
@property (nonatomic) NSUInteger bottomLineHeaderSpace;//bottomLine左边距

@property (nonatomic) BOOL hiddenDisclosureIndicator;//隐藏左边指示器，默认显示

@end