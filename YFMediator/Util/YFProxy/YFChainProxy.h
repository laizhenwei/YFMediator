//
//  YFChainProxy.h
//  AFNetworking
//
//  Created by laizw on 2017/9/18.
//

/**
 Message Forward
 msg -> middleman -> receiver
 */

#import <Foundation/Foundation.h>

@interface YFChainProxy : NSObject

@property (nonatomic, weak) id middleman;
@property (nonatomic, weak) id receiver;

+ (instancetype)proxyWithReceiver:(id)receiver;
- (instancetype)initWithReceiver:(id)receiver;

+ (instancetype)proxyWithMiddleman:(id)middleman;
- (instancetype)initWithMiddleman:(id)middleman;

@end
