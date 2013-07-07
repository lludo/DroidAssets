//
//  LGMFileManager.m
//  DroidAssets
//
//  Created by Ludovic Landry on 7/4/13.
//  Copyright (c) 2013 Little Green Mens. All rights reserved.
//

#import "LGMFileManager.h"
#import "NSImage+PixelSize.h"

@implementation LGMFileManager

+ (NSString *)resFolderForImageAtPath:(NSString *)imagePath {
    NSString *densityDirectory = [imagePath stringByDeletingLastPathComponent];
    return [densityDirectory stringByDeletingLastPathComponent];
}

+ (NSString *)densityForImageAtPath:(NSString *)imagePath {
    NSString *densityDirectory = [imagePath stringByDeletingLastPathComponent];
    NSString *densityFolderName = [densityDirectory lastPathComponent];
    return [densityFolderName stringByReplacingOccurrencesOfString:@"drawable-" withString:@""];
}

+ (NSArray *)availableDensitiesForImageAtPath:(NSString *)imagePath {
    NSString *resDirectory = [LGMFileManager resFolderForImageAtPath:imagePath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *resContent = [fileManager contentsOfDirectoryAtPath:resDirectory error:nil];
    
    NSMutableArray *densities = [NSMutableArray array];
    NSArray *allDensityFolders = @[@"drawable-ldpi", @"drawable-mdpi", @"drawable-tvdpi", @"drawable-hdpi", @"drawable-xhdpi", @"drawable-xxhdpi"];
    [resContent enumerateObjectsUsingBlock:^(NSString *densityFolder, NSUInteger idx, BOOL *stop) {
        if ([allDensityFolders containsObject:densityFolder]) {
            NSString *densityName = [densityFolder stringByReplacingOccurrencesOfString:@"drawable-" withString:@""];
            [densities addObject:densityName];
        }
    }];
    
    return densities;
}

+ (void)saveImage:(NSBitmapImageRep *)imageRep atPath:(NSString *)path {
    
    //[image lockFocus];
    //NSBitmapImageRep *imageRepresentation = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0.0, 0.0, image.size.width, image.size.height)] ;
    //[image unlockFocus];
    
    NSData *data = [imageRep representationUsingType:NSPNGFileType properties:nil];
    [data writeToFile:path atomically:YES];
}

@end
