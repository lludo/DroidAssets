//
//  LGMAssetResizer.h
//  DroidAssets
//
//  Created by Ludovic Landry on 7/4/13.
//  Copyright (c) 2013 Little Green Mens. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LGMAssetResizer : NSObject

+ (NSImage *)imageWithDensity:(NSString *)destinationDensity
                  fromDensity:(NSString *)sourceDensity
                   sourcePath:(NSString *)imagePath
                  isNinePatch:(BOOL)isNinePatch;

@end
