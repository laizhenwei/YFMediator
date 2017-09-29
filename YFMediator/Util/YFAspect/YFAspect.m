//
//  YFAspect.m
//  YFDuanzi
//
//  Created by laizw on 2017/9/8.
//  Copyright © 2017年 laizw. All rights reserved.
//

#import "YFAspect.h"

@implementation YFAspect

+ (void)hook:(id)target sel:(SEL)sel1 with:(SEL)sel2 {
    [self hook:target sel:sel1 with:target sel2:sel2];
}

+ (void)hook:(id)target sel:(SEL)sel with:(id)target2 sel2:(SEL)sel2 {
    Method original = class_getInstanceMethod([target class], sel);
    Method swizlled = class_getInstanceMethod([target2 class], sel2);
    method_exchangeImplementations(original, swizlled);
}

@end
