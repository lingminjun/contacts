//
//  CNLabelInputCell.h
//  contacts
//
//  Created by lingminjun on 15/5/28.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNTableViewCell.h"

@class CNLabelInputCell;
@protocol CNLabelInputCellDelegate <NSObject>

@optional
- (void)cellInputDidChange:(CNLabelInputCell *)cell;//当有输入时回调

@end

/**
 *  标签输入cell
 */
@interface CNLabelInputCell : CNTableViewCell

@property (nonatomic,strong,readonly) UILabel *title;
@property (nonatomic,strong,readonly) UITextField *input;
@property (nonatomic,strong,readonly) UILabel *subTitle;

@end

@interface CNLabelInputCellModel : CNCellModel

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *input;
@property (nonatomic,copy) NSString *inputPlaceholder;
@property (nonatomic,copy) NSString *subTitle;

@property (nonatomic) UIKeyboardType keyboardType; 
@property (nonatomic) NSUInteger inputMaxLength;//最大输入限制，传入0表示不限制
@property (nonatomic,copy) NSCharacterSet *inputCharacterSet;//输入字符限制
@property (nonatomic,copy) NSString *(^inputFormat)(NSString *originText);//输入字符限制

@end
