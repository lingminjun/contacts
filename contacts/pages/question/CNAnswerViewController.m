//
//  CNAnswerViewController.m
//  contacts
//
//  Created by lingminjun on 15/5/31.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNAnswerViewController.h"

@interface CNAnswerViewController ()

@end

@implementation CNAnswerViewController

- (void)loadView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view = scrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = cn_localized(@"answer.header.title");
    self.view.backgroundColor = cn_table_cell_normal_color;
    
    UILabel *answer = [UILabel ssn_labelWithWidth:(self.view.ssn_width - cn_left_edge_width - cn_right_edge_width) font:cn_normal_font color:cn_text_normal_color backgroud:cn_table_cell_normal_color alignment:NSTextAlignmentLeft multiLine:YES];
    answer.text = self.answer;
    [answer ssn_sizeToFit];
    
    SSNUIFlowLayout *layout = [self.view ssn_flowLayoutWithRowCount:1 spacing:cn_ver_space_height];
    layout.orientation = SSNUILayoutOrientationLandscapeLeft;
    layout.contentInset = UIEdgeInsetsMake(cn_top_edge_height, 0, cn_bottom_edge_height, 0);
    layout.contentMode = SSNUIContentModeTop;
    ssn_layout_add(layout, answer, 0, answer);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - SSNPage
- (void)ssn_handleOpenURL:(NSURL *)url query:(NSDictionary *)query {
    self.answer = [query objectForKey:@"answer"];
}

@end
