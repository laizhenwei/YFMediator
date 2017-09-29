//
//  YFProxy.h
//  AFNetworking
//
//  Created by laizw on 2017/9/18.
//

/**
 Message Forward
 middleman -> receiver
 */

#import <Foundation/Foundation.h>

@interface YFProxy : NSObject

@property (nonatomic, weak) id middleman;
@property (nonatomic, weak) id receiver;

+ (instancetype)proxyWithReceiver:(id)receiver;
- (instancetype)initWithReceiver:(id)receiver;

+ (instancetype)proxyWithMiddleman:(id)middleman;
- (instancetype)initWithMiddleman:(id)middleman;

@end
