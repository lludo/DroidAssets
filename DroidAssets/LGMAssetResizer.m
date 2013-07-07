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
    CGImageRef imageRef = [inputImage CGImageForProposedRect:NULL context:nil hints:nil];
    NSSize inputImagePixelSize = inputImage.pixelSize;
    
    NSBitmapImageRep *outputImageRep;
    if (isNinePatch) {
        // For images with 9-patch
        NSSize outputSize = NSMakeSize(floorf(((inputImagePixelSize.width - 2) * scale + 2)),
                                       floorf(((inputImagePixelSize.height - 2) * scale + 2)));
        
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
        NSDictionary *patchDescription = [self getPatchDescriptionForImage:inputImage];
        NSArray *top = [patchDescription objectForKey:@"top"];
        for (NSInteger ndx = 0; ndx < [top count]; ndx = ndx+2) {
            float start = [[top objectAtIndex:ndx] floatValue];
            float stop = [[top objectAtIndex:ndx + 1] floatValue];
            
            float x = floorf(start * scale);
            float width = floorf((stop - start) * scale);
            [NSBezierPath fillRect:NSMakeRect((x) ? x : 1, outputSize.height - 1, (width) ? width : 1, 1)];
        }
        NSArray *left = [patchDescription objectForKey:@"left"];
        for (NSInteger ndx = 0; ndx < [left count]; ndx = ndx+2) {
            float start = [[left objectAtIndex:ndx] floatValue];
            float stop = [[left objectAtIndex:ndx + 1] floatValue];
            
            float y = floorf(start * scale);
            float height = floorf((stop - start) * scale);
            [NSBezierPath fillRect:NSMakeRect(0, (y) ? y : 1, 1, (height) ? height : 1)];
        }
        NSArray *bottom = [patchDescription objectForKey:@"bottom"];
        for (NSInteger ndx = 0; ndx < [bottom count]; ndx = ndx+2) {
            float start = [[bottom objectAtIndex:ndx] floatValue];
            float stop = [[bottom objectAtIndex:ndx + 1] floatValue];
            
            float x = floorf(start * scale);
            float width = floorf((stop - start) * scale);
            [NSBezierPath fillRect:NSMakeRect((x) ? x : 1, 0, (width) ? width : 1, 1)];
        }
        NSArray *right = [patchDescription objectForKey:@"right"];
        for (NSInteger ndx = 0; ndx < [right count]; ndx = ndx+2) {
            float start = [[right objectAtIndex:ndx] floatValue];
            float stop = [[right objectAtIndex:ndx + 1] floatValue];
            
            float y = floorf(start * scale);
            float height = floorf((stop - start) * scale);
            [NSBezierPath fillRect:NSMakeRect(outputSize.width - 1, (y) ? y : 1, 1, (height) ? height : 1)];
        }
        
        // Draw the image in the center
        [inputImage drawInRect:NSMakeRect(1, 1, outputSize.width - 2, outputSize.height - 2)
                      fromRect:NSMakeRect(1, 1, inputImage.size.width - 2, inputImage.size.height - 2)
                     operation:NSCompositeSourceOver
                      fraction:1.0];
        [NSGraphicsContext restoreGraphicsState];
    } else {
        // For simple PNG images
        NSSize outputSize = NSMakeSize(floorf(inputImagePixelSize.width * scale),
                                       floorf(inputImagePixelSize.height * scale));
        
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

+ (NSDictionary *)getPatchDescriptionForImage:(NSImage *)image {
    NSDictionary *patchDescription = @{
        @"top": [NSMutableArray array],
        @"left": [NSMutableArray array],
        @"bottom": [NSMutableArray array],
        @"right": [NSMutableArray array]
    };
    
    CGImageRef imageRef = [image CGImageForProposedRect:NULL context:nil hints:nil];
    NSBitmapImageRep *imageRepresentation = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
    [imageRepresentation setSize:[image size]];
    
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
