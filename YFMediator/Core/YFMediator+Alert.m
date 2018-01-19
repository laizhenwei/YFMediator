//
//  YFMediator+Alert.m
//  fuyi
//
//  Created by laizw on 2017/11/22.
//  Copyright © 2017年 losehero. All rights reserved.
//

#import "YFMediator+Alert.h"

@implementation YFMediator (Alert)

#pragma mark - Alert
- (UIAlertController *)alertWithTitle:(NSString *)title
                             selected:(YFAlertActionHanlder)handler {
    return [self alertWithTitle:title message:nil selected:handler];
}

- (UIAlertController *)alertWithTitle:(NSString *)title
                                items:(NSArray<NSString *> *)items
                               cancel:(NSString *)cancel
                             selected:(YFAlertActionHanlder)handler {
    return [self alertWithTitle:title message:nil items:items cancel:cancel selected:handler];
}

- (UIAlertController *)alertWithMessage:(NSString *)message
                               selected:(YFAlertActionHanlder)handler {
    return [self alertWithTitle:nil message:message selected:handler];
}

- (UIAlertController *)alertWithMessage:(NSString *)message
                                  items:(NSArray<NSString *> *)items
                                 cancel:(NSString *)cancel
                               selected:(YFAlertActionHanlder)handler {
    return [self alertWithTitle:nil message:message items:items cancel:cancel selected:handler];
}

- (UIAlertController *)alertWithTitle:(NSString *)title
                              message:(NSString *)message
                             selected:(YFAlertActionHanlder)handler {
    return [self alertWithTitle:title message:message items:@[@"cancel"] cancel:nil selected:handler];
}

- (UIAlertController *)alertWithTitle:(NSString *)title
                              message:(NSString *)message
                                items:(NSArray<NSString *> *)items
                               cancel:(NSString *)cancel
                             selected:(YFAlertActionHanlder)handler {
    
    UIAlertController *alert = [self alert:UIAlertControllerStyleAlert withTitle:title message:message items:items cancel:cancel selected:handler];
    [[kYFMediator currentViewController] presentViewController:alert animated:YES completion:nil];
    return alert;
}

#pragma mark - Action Sheet
- (UIAlertController *)actionSheetWithItems:(NSArray<NSString *> *)items cancel:(NSString *)cancel selected:(YFAlertActionHanlder)handler {
    UIAlertController *alert = [self alert:UIAlertControllerStyleActionSheet withTitle:nil message:nil items:items cancel:cancel selected:handler];
    [[kYFMediator currentViewController] presentViewController:alert animated:YES completion:nil];
    return alert;
}

#pragma mark - Helper
- (UIAlertController *)alert:(UIAlertControllerStyle)style
                   withTitle:(NSString *)title
                     message:(NSString *)message
                       items:(NSArray<NSString *> *)items
                      cancel:(NSString *)cancel
                    selected:(YFAlertActionHanlder)handler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];
    for (NSString *item in items) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:item style:UIAlertActionStyleDefault handler:handler];
        [alert addAction:action];
    }
    if (cancel) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:handler];
        [alert addAction:action];
    }
    return alert;
}

@end
