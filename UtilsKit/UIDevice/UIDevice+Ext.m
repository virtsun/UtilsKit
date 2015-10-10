//
// Created by sunlantao on 15/6/25.
// Copyright (c) 2015 sunlantao. All rights reserved.
//

#import "UIDevice+Ext.h"


@implementation UIDevice(DeviceExt)


+ (BOOL)isLandscape{
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
}

@end