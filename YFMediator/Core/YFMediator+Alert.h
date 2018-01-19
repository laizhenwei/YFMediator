//
//  YFMediator+Alert.h
//  fuyi
//
//  Created by laizw on 2017/11/22.
//  Copyright © 2017年 losehero. All rights reserved.
//

#import "YFMediator.h"

typedef void(^YFAlertActionHanlder)(UIAlertAction *action);

@interface YFMediator (Alert)

// Alert
- (UIAlertController *)alertWithTitle:(NSString *)title
                             selected:(YFAlertActionHanlder)handler;

- (UIAlertController *)alertWithTitle:(NSString *)title
                                items:(NSArray<NSString *> *)items
                               cancel:(NSString *)cancel
                             selected:(YFAlertActionHanlder)handler;

- (UIAlertController *)alertWithMessage:(NSString *)message
                               selected:(YFAlertActionHanlder)handler;

- (UIAlertController *)alertWithMessage:(NSString *)message
                                  items:(NSArray<NSString *> *)items
                                 cancel:(NSString *)cancel
                               selected:(YFAlertActionHanlder)handler;

- (UIAlertController *)alertWithTitle:(NSString *)title
                              message:(NSString *)message
                             selected:(YFAlertActionHanlder)handler;

- (UIAlertController *)alertWithTitle:(NSString *)title
                              message:(NSString *)message
                                items:(NSArray<NSString *> *)items
                               cancel:(NSString *)cancel
                             selected:(YFAlertActionHanlder)handler;

// Action Sheet
- (UIAlertController *)actionSheetWithItems:(NSArray<NSString *> *)items
                                     cancel:(NSString *)cancel
                                    selected:(YFAlertActionHanlder)handler;

@end
