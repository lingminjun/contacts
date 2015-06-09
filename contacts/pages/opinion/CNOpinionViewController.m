//
//  CNOpinionViewController.m
//  contacts
//
//  Created by lingminjun on 15/5/31.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNOpinionViewController.h"

@interface CNOpinionViewController ()

@end

@implementation CNOpinionViewController

- (void)loadView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view = scrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = cn_localized(@"opinion.header.title");
    
//    self.view.backgroundColor = cn_backgroud_white_color;
    
    NSInteger input_height = 200;
    if (cn_screen_height == 480) {
        input_height = 100;
    }
    
    UITextView *input = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.ssn_width - cn_left_edge_width - cn_right_edge_width , input_height)];
    input.layer.cornerRadius = 4;
    
    SSNUIFlowLayout *layout = [self.view ssn_flowLayoutWithRowCount:1 spacing:cn_ver_space_height];
    layout.orientation = SSNUILayoutOrientationLandscapeLeft;
    layout.contentInset = UIEdgeInsetsMake(cn_top_edge_height, 0, cn_bottom_edge_height, 0);
    layout.contentMode = SSNUIContentModeTop;
    ssn_layout_add(layout, input, 0, input);
    
    UIButton *btn = [UIButton cn_normal_button];
    btn.ssn_normalTitle = cn_localized(@"setting.commit.button");
    [btn ssn_addTarget:self touchAction:@selector(submitAction:)];
    
    SSNUIFlowLayout *layout2 = [self.view ssn_flowLayoutWithRowCount:1 spacing:cn_ver_space_height];
    layout2.orientation = SSNUILayoutOrientationLandscapeRight;
    layout2.contentInset = UIEdgeInsetsMake(0, 0, cn_keyboard_v2_height, 0);
    layout2.contentMode = SSNUIContentModeBottom;
    ssn_layout_add(layout2, btn, 0, button);
    
    [input becomeFirstResponder];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)submitAction:(id)sender {
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
