//
//  YFAspect.h
//  YFDuanzi
//
//  Created by laizw on 2017/9/8.
//  Copyright © 2017年 laizw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>

@interface YFAspect : NSObject

+ (void)hook:(id)target sel:(SEL)sel1 with:(SEL)sel2;
+ (void)hook:(id)target sel:(SEL)sel with:(id)target2 sel2:(SEL)sel2;

@end
