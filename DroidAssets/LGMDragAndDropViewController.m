//
//  LGMDragAndDropViewController.m
//  DroidAssets
//
//  Created by Ludovic Landry on 7/4/13.
//  Copyright (c) 2013 Little Green Mens. All rights reserved.
//

#import "LGMDragAndDropViewController.h"
#import "LGMAssetResizer.h"
#import "LGMFileManager.h"

@interface LGMDragAndDropViewController ()
@property (nonatomic, strong) LGMDragAndDropView *dragAndDropView;
@property (nonatomic, strong) NSImageView *imageView;
@end

@implementation LGMDragAndDropViewController

@synthesize dragAndDropView;
@synthesize imageView;

- (id)init {
    self = [super init];
    if (self) {
        imageView = [[NSImageView alloc] initWithFrame:self.view.bounds];
        imageView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        self.imageView.image = [NSImage imageNamed:@"unselected"];
        [self.view addSubview:imageView];
        
        dragAndDropView = [[LGMDragAndDropView alloc] initWithFrame:self.view.bounds];
        dragAndDropView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        dragAndDropView.delegate = self;
        [self.view addSubview:dragAndDropView];
    }
    return self;
}

- (void)didDropFilesWithPaths:(NSArray *)paths {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        // Check if images are in the res/drawable-{density} folder
        NSString *firstImagePath = [paths objectAtIndex:0];
        if ([firstImagePath rangeOfString:@"/res/drawable-"].location == NSNotFound) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSAlert *alert = [NSAlert alertWithMessageText:@"Invalid Image Path"
                                                 defaultButton:@"Ok"
                                               alternateButton:nil
                                                   otherButton:nil
                                     informativeTextWithFormat:@"DroidAssets only support drag and drop for images in the res/drawable-{density} folder."];
                [alert setAlertStyle:NSWarningAlertStyle];
                [alert runModal];
            });
            return;
        }
        
        // Check if images are PGNs (including 9-patch)
        [paths enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
            if (![path hasSuffix:@".png"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSAlert *alert = [NSAlert alertWithMessageText:@"Invalid Image Format"
                                                     defaultButton:@"Ok"
                                                   alternateButton:nil
                                                       otherButton:nil
                                         informativeTextWithFormat:@"DroidAssets only support PNG images and 9-patch (extensions .png and .9.png)."];
                    [alert setAlertStyle:NSWarningAlertStyle];
                    [alert runModal];
                });
                return;
            }
        }];
        
        [paths enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
            NSString *resFolder = [LGMFileManager resFolderForImageAtPath:path];
            NSString *imageName = [path lastPathComponent];
            BOOL isNinePatch = [imageName hasSuffix:@".9.png"];
            NSString *assetDensity = [LGMFileManager densityForImageAtPath:path];
            NSArray *availableDensities = [LGMFileManager availableDensitiesForImageAtPath:path];
            
            // List of densities to generate
            NSMutableArray *densityToGenerate = [availableDensities mutableCopy];
            [densityToGenerate removeObject:assetDensity];
            
            // Generate the densities from the source image
            [densityToGenerate enumerateObjectsUsingBlock:^(NSString *density, NSUInteger idx, BOOL *stop) {
                NSBitmapImageRep *imageRep = [LGMAssetResizer imageWithDensity:density fromDensity:assetDensity sourcePath:path isNinePatch:isNinePatch];
                
                NSString *path = [NSString stringWithFormat:@"%@/drawable-%@/%@", resFolder ,density, imageName];
                NSLog(@">>> Generating: %@", path);
                [LGMFileManager saveImage:imageRep atPath:path];
            }];
        }];
        
        //dispatch_async(dispatch_get_main_queue(), ^{
        //
        //});
    });
}

- (void)didChangeState:(BOOL)selected {
    self.imageView.image = [NSImage imageNamed: (selected) ? @"selected" : @"unselected"];
}

@end
