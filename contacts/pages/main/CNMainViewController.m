//
//  HTMainViewController.m
//  hitaoq
//
//  Created by lingminjun on 15/5/13.
//  Copyright (c) 2015年 SSN. All rights reserved.
//

#import "CNMainViewController.h"

@interface CNMainViewController ()/*<UITabBarControllerDelegate>*/

@end

@implementation CNMainViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.tabBar.translucent = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.delegate = self;
    // Do any additional setup after loading the view.
    
    if (![CNUserCenter center].isSign) {//是否设置过个人资料
        [UIAlertView ssn_showConfirmationDialogWithTitle:@""
                                                 message:cn_localized(@"user.set.user.info.tip")
                                                  cancel:nil
                                                 confirm:cn_localized(@"common.submit.button")
                                                 handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                     NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
                                                     if ([cn_localized(@"common.submit.button") isEqualToString:btnTitle]) {
                                                         [alertView.ssn_router open:cn_combine_path(@"nav/detail?option=setuser")];
                                                     }
                                                 }];
    }
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

#pragma mark override
- (void)setSelectedViewController:(UIViewController *)selectedViewController {
    self.title = selectedViewController.title;
    self.navigationItem.leftBarButtonItem = selectedViewController.navigationItem.leftBarButtonItem;
    self.navigationItem.rightBarButtonItem = selectedViewController.navigationItem.rightBarButtonItem;
    
    [super setSelectedViewController:selectedViewController];
}

#pragma mark - UITabBarControllerDelegate


#pragma mark - SSNPage
- (BOOL)ssn_canRespondURL:(NSURL *)url query:(NSDictionary *)query {
    return YES;
}

@end
