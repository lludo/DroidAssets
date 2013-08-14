//
//  NSImage+PixelSize.h
//  DroidAssets
//
//  Created by Ludovic Landry on 7/6/13.
//  Copyright (c) 2013 Little Green Mens. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface NSImage (PixelSize)

- (NSInteger)pixelsWide;
- (NSInteger)pixelsHigh;
- (NSSize)pixelSize;

@end
