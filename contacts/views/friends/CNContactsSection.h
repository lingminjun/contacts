//
//  CNContactsSection.h
//  contacts
//
//  Created by lingminjun on 15/6/13.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import <UIKit/UIKit.h>

#define cn_contacts_section_height (20)

@interface CNContactsSection : UIView

@property (nonatomic,strong,readonly) UILabel *titleLabel;
@property (nonatomic,strong,readonly) UIImageView *distanceIcon;
@property (nonatomic,strong,readonly) UILabel *distanceLabel;

- (instancetype)initWithTitle:(NSString *)title;
+ (instancetype)sectionWithTitle:(NSString *)title;

@end
