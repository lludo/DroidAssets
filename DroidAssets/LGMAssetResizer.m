//
//  LGMAssetResizer.m
//  DroidAssets
//
//  Created by Ludovic Landry on 7/4/13.
//  Copyright (c) 2013 Little Green Mens. All rights reserved.
//

#import "LGMAssetResizer.h"
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
    float ratio = [destinationScale floatValue] / [sourceScale floatValue];
    
    NSURL *imageUrl = [NSURL fileURLWithPath:imagePath];
    CIImage *ciImage = [CIImage imageWithContentsOfURL:imageUrl];
    
    // Resize the image
    CIFilter *scaleFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
    [scaleFilter setValue:ciImage forKey:@"inputImage"];
    [scaleFilter setValue:[NSNumber numberWithFloat:ratio] forKey:@"inputScale"];
    [scaleFilter setValue:[NSNumber numberWithFloat:1.0] forKey:@"inputAspectRatio"];
    CIImage *finalCiImage = [scaleFilter valueForKey:@"outputImage"];
    
    NSSize size = finalCiImage.extent.size;
    NSImage *resized = [[NSImage alloc] initWithSize:size];
    [resized lockFocus];
    [finalCiImage drawAtPoint:NSZeroPoint
                     fromRect:NSMakeRect(0, 0, size.width, size.height)
                    operation:NSCompositeCopy fraction:1.0];
    [resized unlockFocus];
    
    return resized;
}

@end
