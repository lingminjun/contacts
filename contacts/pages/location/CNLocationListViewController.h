//
//  CNLocationListViewController.h
//  contacts
//
//  Created by lingminjun on 15/6/22.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNTableViewController.h"
#import "CNAddress.h"

@interface CNLocationListViewController : CNTableViewController

@property (nonatomic,strong) NSString *searchText;
@property (nonatomic,strong) NSString *city;
@property (nonatomic,strong,readonly) NSMutableArray *results;

@end
