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
@end

@implementation LGMDragAndDropViewController

@synthesize dragAndDropView;

- (id)init {
    self = [super init];
    if (self) {
        dragAndDropView = [[LGMDragAndDropView alloc] initWithFrame:self.view.frame];
        dragAndDropView.delegate = self;
        [[self view] addSubview:dragAndDropView];
    }
    return self;
}

- (void)didDropFilesWithPaths:(NSArray *)paths {
    
    // Check if images are in the res/drawable-{density} folder
    NSString *firstImagePath = [paths objectAtIndex:0];
    if ([firstImagePath rangeOfString:@"/res/drawable-"].location == NSNotFound) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Invalid Image Path"
                                         defaultButton:@"Ok"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"DroidAssets only support drag and drop for images in the res/drawable-{density} folder."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        return;
    }
    
    // Check if images are PGNs (including 9-patch)
    [paths enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
        if (![path hasSuffix:@".png"]) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Invalid Image Format"
                                             defaultButton:@"Ok"
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:@"DroidAssets only support PNG images and 9-patch (extensions .png and .9.png)."];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
            return;
        }
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [paths enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
            NSString *resFolder = [LGMFileManager resFolderForImageAtPath:path];
            NSString *imageName = [path lastPathComponent];
            NSString *assetDensity = [LGMFileManager densityForImageAtPath:path];
            NSArray *availableDensities = [LGMFileManager availableDensitiesForImageAtPath:path];
            
            // List of densities to generate
            NSMutableArray *densityToGenerate = [availableDensities mutableCopy];
            [densityToGenerate removeObject:assetDensity];
            
            // Generate the densities from the source image
            [densityToGenerate enumerateObjectsUsingBlock:^(NSString *density, NSUInteger idx, BOOL *stop) {
                NSImage *image = [LGMAssetResizer imageWithDensity:density fromDensity:assetDensity sourcePath:path];
                
                NSString *path = [NSString stringWithFormat:@"%@/drawable-%@/%@", resFolder ,density, imageName];
                NSLog(@">>> Generating: %@", path);
                [LGMFileManager saveImage:image atPath:path];
            }];
        }];
        
        //dispatch_async(dispatch_get_main_queue(), ^{
        //
        //});
    });
}

@end
