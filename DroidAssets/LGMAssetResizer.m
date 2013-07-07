//
//  LGMAssetResizer.m
//  DroidAssets
//
//  Created by Ludovic Landry on 7/4/13.
//  Copyright (c) 2013 Little Green Mens. All rights reserved.
//

#import "LGMAssetResizer.h"
#import "NSImage+PixelSize.h"
#include <QuartzCore/CoreImage.h>

@implementation LGMAssetResizer

+ (NSImage *)imageWithDensity:(NSString *)destinationDensity fromDensity:(NSString *)sourceDensity sourcePath:(NSString *)imagePath {
    
    NSDictionary *densitiesScale = @{
        @"ldpi": @(0.75),
        @"mdpi": @(1),
        @"tvdpi": @(1.33),
        @"hdpi": @(1.5),
        @"xhdpi": @(2),
        @"xxhdpi": @(3)
    };
    
    NSNumber *sourceScale = [densitiesScale valueForKey:sourceDensity];
    NSNumber *destinationScale = [densitiesScale valueForKey:destinationDensity];
    float scale = [destinationScale floatValue] / [sourceScale floatValue];
    
    NSImage *inputImage = [[NSImage alloc] initWithContentsOfFile:imagePath];
    NSSize inputImagePixelSize = inputImage.pixelSize;
    float pixelPerPoint = inputImagePixelSize.width / inputImage.size.width;
    
    NSSize outputSize = NSMakeSize(floorf(inputImagePixelSize.width * scale / pixelPerPoint),
                                   floorf(inputImagePixelSize.height * scale / pixelPerPoint));
    
    NSImage *outputImage = [[NSImage alloc] initWithSize:outputSize];
    [outputImage lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [inputImage drawInRect:NSMakeRect(0, 0, outputSize.width, outputSize.height)
                  fromRect:NSZeroRect
                 operation:NSCompositeSourceOver
                  fraction:1.0];
    [outputImage unlockFocus];
    outputImage.size = outputSize;
    
    return outputImage;
}

@end
