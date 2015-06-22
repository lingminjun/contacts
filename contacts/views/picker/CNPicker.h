//
//  CNPicker.h
//  contacts
//
//  Created by lingminjun on 15/6/22.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CNPicker;
@protocol CNPickerData,CNPickerDelegate;


@interface CNPicker : UIView

@property (nonatomic,strong,readonly) UIPickerView *picker;

@property (nonatomic,copy) NSArray <CNPickerData>*datas;//第一列数据
@property (nonatomic) NSInteger componentCount;

@property (nonatomic,weak) id<CNPickerDelegate> delegate;

- (NSArray <CNPickerData>*)selectedDatas;

- (void)reload;

//必须注意，datas中只需要title匹配即可
- (void)selectDatas:(NSArray <CNPickerData>*)datas animated:(BOOL)animated;

@end


@protocol CNPickerDelegate <NSObject>

@optional
- (void)picker:(CNPicker *)picker didSelectRow:(id<CNPickerData>)data inComponent:(NSInteger)component;

- (void)pickerDoneButtonClick:(CNPicker *)picker;

@end


/**
 *  picker元素定义
 */
@protocol CNPickerData <NSObject,NSCopying>
@property (nonatomic,copy,readonly) NSString *title;
@end

/**
 *  元素具体申明
 */
@interface CNPickerData : NSObject<CNPickerData>

@property (nonatomic,copy) NSString *title;
@property (nonatomic,strong,readonly) NSMutableArray <CNPickerData>*children;
@property (nonatomic,copy) NSDictionary *userInfo;

- (instancetype)initWithTitle:(NSString *)title;
+ (instancetype)dataWithTitle:(NSString *)title;

@end

