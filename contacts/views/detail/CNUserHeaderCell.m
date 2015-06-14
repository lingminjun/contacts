//
//  CNUserHeaderCell.m
//  contacts
//
//  Created by lingminjun on 15/6/14.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNUserHeaderCell.h"
#import "SSNDataStore+Factory.h"

@interface CNUserHeaderCell()

@end

@implementation CNUserHeaderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        NSUInteger avatar_edge = 2;
        NSUInteger avatar_width = 60 - avatar_edge;
        
        UIImageView *bg = [[UIImageView alloc] initWithImage:cn_image(@"user_header_bg")];
        self.backgroundView = bg;
        
//        _title = [UILabel]
        _avatar = [UIImageView ssn_imageViewWithWidth:avatar_width];
        _avatar.userInteractionEnabled = YES;
        
        UIButton *btn = [[UIButton alloc] initWithFrame:_avatar.bounds];
        [btn ssn_addTarget:self touchAction:@selector(avatarButtonAction:)];
        [_avatar addSubview:btn];
        
        //开始布局
        SSNUITableLayout *layout = [self.contentView ssn_tableLayoutWithRowCount:1 columnCount:1];
        layout.contentInset = UIEdgeInsetsMake(0, 15 + avatar_edge/2, 0, 0);
        
        //添加元素到cell中
        ssn_layout_add_v2(layout, _avatar, 0, ssn_layout_table_cell_v2(SSNUIContentModeTop), _avatar);
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _title.text = nil;
    _avatar.image = nil;
}

- (void)ssn_configureCellWithModel:(CNUserHeaderCellModel *)model atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    [super ssn_configureCellWithModel:model atIndexPath:indexPath inTableView:tableView];
    
    if ([model isKindOfClass:[CNUserHeaderCellModel class]]) {
        _title.text = model.title;
        NSData *data = [[[CNUserCenter center] currentStore] accessDataForKey:CN_USER_AVATAR_KEY];
        if (data) {
            _avatar.image = [UIImage imageWithData:data];
        }
        else {
            _avatar.image = nil;
        }
        
        CGSize size = [(UIImageView *)self.backgroundView image].size;
        model.cellHeight = ssn_ceil(size.height * cn_screen_width / size.width);
    }
}

- (void)avatarButtonAction:(id)sender {
    id<CNUserHeaderCellDelegate> delegate = (id<CNUserHeaderCellDelegate>)(self.ssn_presentingViewController);
    if ([delegate respondsToSelector:@selector(cellAvatarDidTouch:)]) {
        [delegate cellAvatarDidTouch:self];
    }
}


@end


@implementation CNUserHeaderCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellHeight = 113;
        self.cellClass = [CNUserHeaderCell class];
        self.hiddenDisclosureIndicator = YES;
        self.hiddenBottomLine = YES;
    }
    return self;
}

@end