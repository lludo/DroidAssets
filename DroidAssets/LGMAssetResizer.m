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

@interface LGMAssetResizer ()
+ (NSDictionary *)getPatchDescriptionForImage:(NSImage *)image;
@end

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
        
        // Fill the background with white
        [[NSColor whiteColor] setFill];
        [NSBezierPath fillRect:NSMakeRect(0, 0, outputSize.width, outputSize.height)];
        
        // Draw the 9-patch arround the image
        [[NSColor blackColor] setFill];
        NSDictionary *patchDescription = [self getPatchDescriptionForImage:inputImage];
        NSLog(@">> %@", patchDescription);
        NSArray *top = [patchDescription objectForKey:@"top"];
        for (NSInteger ndx = 0; ndx < [top count]; ndx = ndx+2) {
            float start = [[top objectAtIndex:ndx] floatValue];
            float stop = [[top objectAtIndex:ndx + 1] floatValue];
            [NSBezierPath fillRect:NSMakeRect(floor(start * scale) / pixelPerPoint,
                                              outputSize.height - 1 / pixelPerPoint,
                                              floor((stop - start) * scale) / pixelPerPoint,
                                              1 / pixelPerPoint)];
        }
        NSArray *left = [patchDescription objectForKey:@"left"];
        for (NSInteger ndx = 0; ndx < [left count]; ndx = ndx+2) {
            float start = [[left objectAtIndex:ndx] floatValue];
            float stop = [[left objectAtIndex:ndx + 1] floatValue];
            [NSBezierPath fillRect:NSMakeRect(0,
                                              floor(start * scale) / pixelPerPoint,
                                              1 / pixelPerPoint,
                                              floor((stop - start) * scale) / pixelPerPoint)];
        }
        NSArray *bottom = [patchDescription objectForKey:@"bottom"];
        for (NSInteger ndx = 0; ndx < [bottom count]; ndx = ndx+2) {
            float start = [[bottom objectAtIndex:ndx] floatValue];
            float stop = [[bottom objectAtIndex:ndx + 1] floatValue];
            [NSBezierPath fillRect:NSMakeRect(floor(start * scale) / pixelPerPoint,
                                              0,
                                              floor((stop - start) * scale) / pixelPerPoint,
                                              1 / pixelPerPoint)];
        }
        NSArray *right = [patchDescription objectForKey:@"right"];
        for (NSInteger ndx = 0; ndx < [right count]; ndx = ndx+2) {
            float start = [[right objectAtIndex:ndx] floatValue];
            float stop = [[right objectAtIndex:ndx + 1] floatValue];
            [NSBezierPath fillRect:NSMakeRect(outputSize.width - 1 / pixelPerPoint,
                                              floor(start * scale) / pixelPerPoint,
                                              1 / pixelPerPoint,
                                              floor((stop - start) * scale) / pixelPerPoint)];
        }
        
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

+ (NSDictionary *)getPatchDescriptionForImage:(NSImage *)image {
    NSDictionary *patchDescription = @{
        @"top": [NSMutableArray array],
        @"left": [NSMutableArray array],
        @"bottom": [NSMutableArray array],
        @"right": [NSMutableArray array]
    };
    
    [image lockFocus] ;
    NSBitmapImageRep *imageRepresentation = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0.0, 0.0, image.pixelsWide, image.pixelsHigh)];
    [image unlockFocus] ;
    
    BOOL isParsingBlackLine;
    NSColorSpace *grayColorSpace = [NSColorSpace deviceGrayColorSpace];
    
    // Top line
    isParsingBlackLine = NO;
    for (NSInteger x = 0; x < imageRepresentation.pixelsWide; x++) {
        NSColor *color = [[imageRepresentation colorAtX:x y:0] colorUsingColorSpace:grayColorSpace];
        if (color.whiteComponent < 0.1f) {
            if (!isParsingBlackLine) {
                NSMutableArray *topArray = [patchDescription objectForKey:@"top"];
                [topArray addObject:@(x)];
                isParsingBlackLine = YES;
            }
        } else {
            if (isParsingBlackLine) {
                NSMutableArray *topArray = [patchDescription objectForKey:@"top"];
                [topArray addObject:@(x)];
                isParsingBlackLine = NO;
            }
        }
    }
    
    // Bottom line
    isParsingBlackLine = NO;
    for (NSInteger x = 0; x < imageRepresentation.pixelsWide; x++) {
        NSColor *color = [[imageRepresentation colorAtX:x y:imageRepresentation.pixelsHigh - 1] colorUsingColorSpace:grayColorSpace];
        if (color.whiteComponent < 0.1f) {
            if (!isParsingBlackLine) {
                NSMutableArray *bottomArray = [patchDescription objectForKey:@"bottom"];
                [bottomArray addObject:@(x)];
                isParsingBlackLine = YES;
            }
        } else {
            if (isParsingBlackLine) {
                NSMutableArray *bottomArray = [patchDescription objectForKey:@"bottom"];
                [bottomArray addObject:@(x)];
                isParsingBlackLine = NO;
            }
        }
    }
    
    // Left column
    isParsingBlackLine = NO;
    for (NSInteger y = 0; y < imageRepresentation.pixelsHigh; y++) {
        NSColor *color = [[imageRepresentation colorAtX:0 y:y] colorUsingColorSpace:grayColorSpace];
        if (color.whiteComponent < 0.1f) {
            if (!isParsingBlackLine) {
                NSMutableArray *leftArray = [patchDescription objectForKey:@"left"];
                [leftArray addObject:@(y)];
                isParsingBlackLine = YES;
            }
        } else {
            if (isParsingBlackLine) {
                NSMutableArray *leftArray = [patchDescription objectForKey:@"left"];
                [leftArray addObject:@(y)];
                isParsingBlackLine = NO;
            }
        }
    }
    
    // Right column
    isParsingBlackLine = NO;
    for (NSInteger y = 0; y < imageRepresentation.pixelsHigh; y++) {
        NSColor *color = [[imageRepresentation colorAtX:imageRepresentation.pixelsWide - 1 y:y] colorUsingColorSpace:grayColorSpace];
        if (color.whiteComponent < 0.1f) {
            if (!isParsingBlackLine) {
                NSMutableArray *rightArray = [patchDescription objectForKey:@"right"];
                [rightArray addObject:@(y)];
                isParsingBlackLine = YES;
            }
        } else {
            if (isParsingBlackLine) {
                NSMutableArray *rightArray = [patchDescription objectForKey:@"right"];
                [rightArray addObject:@(y)];
                isParsingBlackLine = NO;
            }
        }
    }
    
    return patchDescription;
}

@end
