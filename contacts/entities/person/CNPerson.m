//
//  CNPerson.m
//  contacts
//
//  Created by lingminjun on 15/5/24.
//  Copyright (c) 2015年 shield. All rights reserved.
//

#import "CNPerson.h"

@implementation CNPerson

- (void)setName:(NSString *)name {
    if (ssn_is_equal_to_string(_name, name)) {
        return ;
    }
    
    if ([name length] > 0) {
        _pinyin = [name ssn_searchPinyinString];
        if ([_pinyin length] > 0) {
            unichar c = [_pinyin characterAtIndex:0];
            if (c >= 'a' && c <= 'z') {
                _firstSpell = c - ('a' - 'A');
            }
            else if (c >= 'A' && c <= 'Z') {
                _firstSpell = c;
            }
            else {
                _firstSpell = '#';
            }
        }
        else {
            _firstSpell = '#';
        }
    }
   
    _name = [name copy];
}

@end
