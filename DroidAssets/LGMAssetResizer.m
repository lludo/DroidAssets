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

+ (NSImage *)imageWithDensity:(NSString *)destinationDensity
                  fromDensity:(NSString *)sourceDensity
                   sourcePath:(NSString *)imagePath
                  isNinePatch:(BOOL)isNinePatch {
    
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
    
    NSImage *outputImage;
    if (isNinePatch) {
        // For images with 9-patch
        NSSize outputSize = NSMakeSize(floorf(((inputImagePixelSize.width - 2) * scale + 2)) / pixelPerPoint,
                                       floorf(((inputImagePixelSize.height - 2) * scale + 2)) / pixelPerPoint);
        
        outputImage = [[NSImage alloc] initWithSize:outputSize];
        [outputImage lockFocus];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        
        // Fill the background with black
        [[NSColor whiteColor] setFill];
        [NSBezierPath fillRect:NSMakeRect(0, 0, outputSize.width, outputSize.width)];
        
        // Draw the 9-patch arround the image
        //TODO: xxx
        
        // Draw the image in the center
        [inputImage drawInRect:NSMakeRect(1 / pixelPerPoint, 1 / pixelPerPoint,
                                          outputSize.width - 2 / pixelPerPoint,
                                          outputSize.height - 2 / pixelPerPoint)
                      fromRect:NSMakeRect(1, 1,
                                          outputSize.width  * pixelPerPoint - 3,
                                          outputSize.height * pixelPerPoint - 3)
                     operation:NSCompositeSourceOver
                      fraction:1.0];
        [outputImage unlockFocus];
        outputImage.size = outputSize;
    } else {
        // For simple PNG images
        NSSize outputSize = NSMakeSize(floorf(inputImagePixelSize.width * scale) / pixelPerPoint,
                                       floorf(inputImagePixelSize.height * scale) / pixelPerPoint);
        
        outputImage = [[NSImage alloc] initWithSize:outputSize];
        [outputImage lockFocus];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [inputImage drawInRect:NSMakeRect(0, 0, outputSize.width, outputSize.height)
                      fromRect:NSZeroRect
                     operation:NSCompositeSourceOver
                      fraction:1.0];
        [outputImage unlockFocus];
        outputImage.size = outputSize;
    }
    
    return outputImage;
}

@end
