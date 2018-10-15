//
//  NSURLRequest+ProxyCanonicalRequest.h
//  FrameworkCommon
//
//  Created by Nemo on 2018/10/15.
//  Copyright © 2018 Nemo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLRequest (ProxyCanonicalRequest)

- (NSURLRequest *)cdz_canonicalRequest;

@end

NS_ASSUME_NONNULL_END
