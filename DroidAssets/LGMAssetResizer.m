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
+ (NSDictionary *)getPatchDescriptionForImage:(CGImageRef)imageRef;
@end

@implementation LGMAssetResizer

+ (NSBitmapImageRep *)imageWithDensity:(NSString *)destinationDensity
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
    
    CGImageRef inputImageRef = [inputImage CGImageForProposedRect:NULL context:nil hints:nil];
    NSBitmapImageRep *outputImageRep;
    
    if (isNinePatch) {
        // For images with 9-patch
        NSSize contentOriginalSize = NSMakeSize(roundf(inputImagePixelSize.width - 2),
                                                roundf(inputImagePixelSize.height - 2));
        
        float width = MAX(1, roundf(contentOriginalSize.width * scale));
        float height = MAX(1, roundf(contentOriginalSize.height * scale));
        
        NSSize outputSize = NSMakeSize(width + 2, height + 2);
        
        NSBitmapImageRep *contentImageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil
                                                                                    pixelsWide:contentOriginalSize.width
                                                                                    pixelsHigh:contentOriginalSize.height
                                                                                 bitsPerSample:8
                                                                               samplesPerPixel:4
                                                                                      hasAlpha:YES
                                                                                      isPlanar:NO
                                                                                colorSpaceName:NSCalibratedRGBColorSpace
                                                                                  bitmapFormat:0
                                                                                   bytesPerRow:(4 * contentOriginalSize.width)
                                                                                  bitsPerPixel:32];
        
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:contentImageRep]];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        
        [inputImage drawInRect:NSMakeRect(0, 0, contentOriginalSize.width, contentOriginalSize.height)
                      fromRect:NSMakeRect(1, 1, inputImage.size.width - 2, inputImage.size.height - 2)
                     operation:NSCompositeSourceOver
                      fraction:1.0];
        
        [NSGraphicsContext restoreGraphicsState];
        
        outputImageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil
                                                                 pixelsWide:outputSize.width
                                                                 pixelsHigh:outputSize.height
                                                              bitsPerSample:8
                                                            samplesPerPixel:4
                                                                   hasAlpha:YES
                                                                   isPlanar:NO
                                                             colorSpaceName:NSCalibratedRGBColorSpace
                                                               bitmapFormat:0
                                                                bytesPerRow:(4 * outputSize.width)
                                                               bitsPerPixel:32];
        
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:outputImageRep]];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        
        // Draw the 9-patch arround the image
        [[NSColor blackColor] setFill];
        NSDictionary *patchDescription = [self getPatchDescriptionForImage:inputImageRef];
        NSArray *top = [patchDescription objectForKey:@"top"];
        for (NSInteger ndx = 0; ndx < [top count]; ndx = ndx+2) {
            float start = [[top objectAtIndex:ndx] floatValue];
            float stop = [[top objectAtIndex:ndx + 1] floatValue];
            
            float x = MAX(1, floorf(start * scale));
            float width = MAX(1, ceilf((stop - start) * scale));
            
            // Ajust the values to be visible after reduction and to not go over the patch area on the corners
            if (x + width >= outputSize.width) {
                width = MAX(0, outputSize.width - x - 1);
            }
            
            [NSBezierPath fillRect:NSMakeRect(x, outputSize.height - 1, width, 1)];
        }
        NSArray *left = [patchDescription objectForKey:@"left"];
        for (NSInteger ndx = 0; ndx < [left count]; ndx = ndx+2) {
            float start = [[left objectAtIndex:ndx] floatValue];
            float stop = [[left objectAtIndex:ndx + 1] floatValue];
            
            float y = MAX(1, floorf(start * scale));
            float height = MAX(1, ceilf((stop - start) * scale));
            
            // Ajust the values to be visible after reduction and to not go over the patch area on the corners
            if (y + height >= outputSize.height) {
                height = MAX(0, outputSize.height - y - 1);
            }
            
            [NSBezierPath fillRect:NSMakeRect(0, outputSize.height - height - y, 1, height)];
        }
        NSArray *bottom = [patchDescription objectForKey:@"bottom"];
        for (NSInteger ndx = 0; ndx < [bottom count]; ndx = ndx+2) {
            float start = [[bottom objectAtIndex:ndx] floatValue];
            float stop = [[bottom objectAtIndex:ndx + 1] floatValue];
            
            float x = MAX(1, floorf(start * scale));
            float width = MAX(1, ceilf((stop - start) * scale));
            
            // Ajust the values to be visible after reduction and to not go over the patch area on the corners
            if (x + width >= outputSize.width) {
                width = MAX(0, outputSize.width - x - 1);
            }
            
            [NSBezierPath fillRect:NSMakeRect(x, 0, width, 1)];
        }
        NSArray *right = [patchDescription objectForKey:@"right"];
        for (NSInteger ndx = 0; ndx < [right count]; ndx = ndx+2) {
            float start = [[right objectAtIndex:ndx] floatValue];
            float stop = [[right objectAtIndex:ndx + 1] floatValue];
            
            float y = MAX(1, floorf(start * scale));
            float height = MAX(1, ceilf((stop - start) * scale));
            
            // Ajust the values to be visible after reduction and to not go over the patch area on the corners
            if (y + height >= outputSize.height) {
                height = MAX(0, outputSize.height - y - 1);
            }
            
            [NSBezierPath fillRect:NSMakeRect(outputSize.width - 1, outputSize.height - height - y, 1, height)];
        }
        
        // Draw the image in the center
        [contentImageRep drawInRect:NSMakeRect(1, 1, outputSize.width - 2, outputSize.height - 2)
                           fromRect:NSZeroRect
                          operation:NSCompositeSourceOver
                           fraction:1.0
                     respectFlipped:YES
                              hints:nil];
        
        [NSGraphicsContext restoreGraphicsState];
        
    } else {
        // For simple PNG images
        float width = MAX(1, roundf(inputImagePixelSize.width * scale));
        float height = MAX(1, roundf(inputImagePixelSize.height * scale));
        
        NSSize outputSize = NSMakeSize(width, height);
        
        outputImageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil
                                                                 pixelsWide:outputSize.width
                                                                 pixelsHigh:outputSize.height
                                                              bitsPerSample:8
                                                            samplesPerPixel:4
                                                                   hasAlpha:YES
                                                                   isPlanar:NO
                                                             colorSpaceName:NSCalibratedRGBColorSpace
                                                               bitmapFormat:0
                                                                bytesPerRow:(4 * outputSize.width)
                                                               bitsPerPixel:32];
        
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:outputImageRep]];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [inputImage drawInRect:NSMakeRect(0, 0, outputSize.width, outputSize.height)
                      fromRect:NSZeroRect
                     operation:NSCompositeSourceOver
                      fraction:1.0];
        [NSGraphicsContext restoreGraphicsState];
    }
    
    return outputImageRep;
}

+ (NSDictionary *)getPatchDescriptionForImage:(CGImageRef)imageRef {
    NSDictionary *patchDescription = @{
        @"top": [NSMutableArray array],
        @"left": [NSMutableArray array],
        @"bottom": [NSMutableArray array],
        @"right": [NSMutableArray array]
    };
    
    NSBitmapImageRep *imageRepresentation = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
    
    BOOL isParsingBlackLine;
    
    // Top line
    isParsingBlackLine = NO;
    for (NSInteger x = 0; x < imageRepresentation.pixelsWide; x++) {
        NSColor *color = [imageRepresentation colorAtX:x y:0];
        if (color.alphaComponent > 0.1f) {
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
        NSColor *color = [imageRepresentation colorAtX:x y:imageRepresentation.pixelsHigh - 1];
        if (color.alphaComponent > 0.1f) {
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
        NSColor *color = [imageRepresentation colorAtX:0 y:y];
        if (color.alphaComponent > 0.1f) {
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
        NSColor *color = [imageRepresentation colorAtX:imageRepresentation.pixelsWide - 1 y:y];
        if (color.alphaComponent > 0.1f) {
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
