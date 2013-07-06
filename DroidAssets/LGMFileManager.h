//
//  LGMFileManager.h
//  DroidAssets
//
//  Created by Ludovic Landry on 7/4/13.
//  Copyright (c) 2013 Little Green Mens. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LGMFileManager : NSObject

+ (NSString *)resFolderForImageAtPath:(NSString *)imagePath;

+ (NSString *)densityForImageAtPath:(NSString *)imagePath;
+ (NSArray *)availableDensitiesForImageAtPath:(NSString *)imagePath;

+ (void)saveImage:(NSImage *)image atPath:(NSString *)path;

@end
