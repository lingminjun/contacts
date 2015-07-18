//
//  UIButton+UIDic.m
//  contacts
//
//  Created by lingminjun on 15/6/9.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "UIButton+UIDic.h"

@implementation UIButton (UIDic)

/**
 *  普通button，size:300x40
 *
 *  @return size:300x40
 */
+ (instancetype)cn_normal_button {
    CGSize size = CGSizeMake(cn_screen_width - cn_left_edge_width - cn_right_edge_width, 40);
    
    UIImage *img1 = [[UIImage ssn_imageWithColor:cn_button_normal_color border:0 color:nil cornerRadius:4] ssn_centerStretchImage];
    UIImage *img2 = [[UIImage ssn_imageWithColor:cn_button_disable_color border:0 color:nil cornerRadius:4] ssn_centerStretchImage];
    UIButton *btn = [UIButton ssn_buttonWithSize:size
                                            font:cn_title_font
                                           color:cn_button_title_color
                                        selected:nil
                                        disabled:nil
                                       backgroud:img1
                                        selected:nil
                                        disabled:img2];
    return btn;
}

/**
 *  done button，size:50x30
 *
 *  @return size:50x30
 */
+ (instancetype)cn_done_button {
    CGSize size = CGSizeMake(50, 30);
    
    UIImage *img1 = [[UIImage ssn_imageWithColor:cn_button_normal_color border:0 color:nil cornerRadius:2] ssn_centerStretchImage];
    UIImage *img2 = [[UIImage ssn_imageWithColor:cn_button_disable_color border:0 color:nil cornerRadius:2] ssn_centerStretchImage];
    UIButton *btn = [UIButton ssn_buttonWithSize:size
                                            font:cn_normal_font
                                           color:cn_button_title_color
                                        selected:nil
                                        disabled:nil
                                       backgroud:img1
                                        selected:nil
                                        disabled:img2];
    return btn;
}

/**
 *  done button，size:90x30
 *
 *  @return size:90x30
 */
+ (instancetype)cn_location_button {
    CGSize size = CGSizeMake(90, 30);
    
    UIImage *img1 = [[UIImage ssn_imageWithColor:cn_hex_color(0xf95651) border:0 color:nil cornerRadius:2] ssn_centerStretchImage];
    UIImage *img2 = [[UIImage ssn_imageWithColor:cn_button_disable_color border:0 color:nil cornerRadius:2] ssn_centerStretchImage];
    UIButton *btn = [UIButton ssn_buttonWithSize:size
                                            font:cn_normal_font
                                           color:cn_button_title_color
                                        selected:nil
                                        disabled:nil
                                       backgroud:img1
                                        selected:nil
                                        disabled:img2];
    return btn;
}

/**
 *  done button，size:100x30
 *
 *  @return size:100x30
 */
+ (instancetype)cn_transparent_button {
    CGSize size = CGSizeMake(100, 30);
    
    UIButton *btn = [UIButton ssn_buttonWithSize:size
                                            font:cn_normal_font
                                           color:cn_text_normal_color
                                        selected:nil
                                        disabled:nil
                                       backgroud:nil
                                        selected:nil
                                        disabled:nil];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, cn_hor_space_width, 0, 0);
    return btn;
}

@end
