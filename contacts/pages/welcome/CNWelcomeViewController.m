//
//  CNWelcomeViewController.m
//  contacts
//
//  Created by lingminjun on 15/5/24.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNWelcomeViewController.h"

#define cn_page_count (3)
#define cn_dot_width  (14)

@interface CNWelcomeViewController ()<SSNPageControlDelegate>

@property (nonatomic,strong) NSString *url;
@property (nonatomic,copy) NSDictionary *query;

@property (nonatomic,strong) SSNPageControl *pageView;
@property (nonatomic,strong) UIPageControl *dotView;

@end

@implementation CNWelcomeViewController

- (SSNPageControl *)pageView {
    if (_pageView) {
        return _pageView;
    }
    
    _pageView = [[SSNPageControl alloc] initWithPageCount:cn_page_count];
    _pageView.frame = self.view.bounds;
    _pageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _pageView.delegate = self;
    
    for (NSInteger index = 0; index < cn_page_count; index++) {
        NSString *imageName = [NSString stringWithFormat:@"welcome%02ld.jpg",(long)(index+1)];
        UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        imgV.frame = _pageView.bounds;
        imgV.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [_pageView addView:imgV atIndex:index];
        
        if (index == cn_page_count - 1) {
            imgV.userInteractionEnabled = YES;
            [imgV addSubview:[self skipButton]];
        }
    }
    
    return _pageView;
}

- (UIPageControl *)dotView {
    return nil;
//    if (_dotView) {
//        return _dotView;
//    }
//    
//    _dotView = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, (cn_page_count - 1)*cn_dot_width, 8)];
//    _dotView.numberOfPages = cn_page_count;
//    [_dotView sizeToFit];
//    _dotView.ssn_bottom = self.view.ssn_height - 20;
//    _dotView.ssn_center_x = self.view.ssn_center_x;
//    _dotView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
//    return _dotView;
}

- (UIButton *)skipButton {
    UIButton *btn = [UIButton ssn_buttonWithSize:CGSizeMake(195, 40) font:[UIFont systemFontOfSize:14] color:[UIColor blackColor] selected:nil disabled:nil backgroud:nil selected:nil disabled:nil];
    UIImage *img = cn_image(@"icon_welcome_enter");
    btn.ssn_normalBackgroundImage = img;
    btn.ssn_center_y = self.view.ssn_height - 70;
    btn.ssn_center_x = ssn_center([UIScreen mainScreen].bounds).x;
    [btn ssn_addTarget:self touchAction:@selector(skipAction:)];
    return btn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:self.pageView];
    [self.view addSubview:self.dotView];
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

#pragma mark PageControlDelegate
- (void)ssn_control:(SSNPageControl *)control didEnterPage:(UIView *)page atIndex:(NSUInteger)index {
    self.dotView.currentPage = index;
}

#pragma mark - SSNPage
- (BOOL)ssn_canRespondURL:(NSURL *)url query:(NSDictionary *)query {
    return YES;
}

- (void)ssn_handleOpenURL:(NSURL *)url query:(NSDictionary *)query {
    self.url = [[query objectForKey:@"url"] ssn_urlDecode];
    self.query = query;
}

@end
