//
//  CNWelcomeViewController.m
//  contacts
//
//  Created by lingminjun on 15/5/24.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNWelcomeViewController.h"

@interface CNWelcomeViewController ()

@property (nonatomic,strong) NSString *url;
@property (nonatomic,copy) NSDictionary *query;

@property (nonatomic,strong) UIScrollView *panel;

@end

@implementation CNWelcomeViewController

- (UIScrollView *)panel {
    if (_panel) {
        return _panel;
    }
    
    _panel = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _panel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _panel.scrollEnabled = YES;
    return _panel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor redColor];
    
    UIButton *btn = [UIButton ssn_buttonWithSize:CGSizeMake(60, 40) font:[UIFont systemFontOfSize:14] color:[UIColor blackColor] selected:nil disabled:nil backgroud:nil selected:nil disabled:nil];
    btn.ssn_center_y = 100;
    btn.ssn_center_x = ssn_center([UIScreen mainScreen].bounds).x;
    [btn ssn_addTarget:self touchAction:@selector(skipAction:)];
    btn.ssn_normalTitle = @"跳过";
    [self.view addSubview:btn];
}

- (void)skipAction:(id)sender {
    [self.ssn_router open:self.url query:self.query];
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
- (BOOL)ssn_canRespondURL:(NSURL *)url query:(NSDictionary *)query {
    return YES;
}

- (void)ssn_handleOpenURL:(NSURL *)url query:(NSDictionary *)query {
    self.url = [[query objectForKey:@"url"] ssn_urlDecode];
    self.query = query;
}

@end
