//
//  WKWebView+Hook.m
//  HttpProxyDemo
//
//  Created by Nemo on 2020/2/22.
//  Copyright © 2020 Nemo. All rights reserved.
//

#import "WKWebView+Hook.h"
#import <objc/runtime.h>

@implementation WKWebView (Hook)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method origin = class_getClassMethod(self, @selector(handlesURLScheme:));
        Method hook = class_getClassMethod(self, @selector(cdz_handlesURLScheme:));
        // 交换方法
        method_exchangeImplementations(origin, hook);
    });
}

+ (BOOL)cdz_handlesURLScheme:(NSString *)urlScheme {
    if ([urlScheme isEqualToString:@"http"] || [urlScheme isEqualToString:@"https"]) {
        return NO;
    }
    return [self cdz_handlesURLScheme:urlScheme];
}

@end
