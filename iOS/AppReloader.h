//
//  AppReloader.h
//  RNPlayNative
//
//  Created by Dave Sibiski on 6/2/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

extern float const kFlipTransitionDuration;
extern int const kFlipTransitionType;

@interface AppReloader : NSObject

+ (void)reloadAppWithVersion:(NSString *)version
                  bundlePath:(NSString *)bundlePath
                 moduleNamed:(NSString *)moduleName;

@end