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
            NSLog(@">>> Generating: %@ %@", path, NSStringFromSize(image.size));
            [LGMFileManager saveImage:image atPath:path];
        }];
    }];
}

@end
