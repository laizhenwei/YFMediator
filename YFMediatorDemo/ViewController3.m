//
//  ViewController3.m
//  YFMediatorDemo
//
//  Created by laizw on 2016/12/14.
//  Copyright © 2016年 laizw. All rights reserved.
//

#import "ViewController3.h"
#import "YFMediator.h"

@interface ViewController3 () <YFMediatorProtocol>

@end

@implementation ViewController3

- (instancetype)initWithParams:(NSDictionary *)params {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:NSStringFromClass(self.class)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}
@end
