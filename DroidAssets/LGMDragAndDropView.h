//
//  LGMDragAndDropView.h
//  DroidAssets
//
//  Created by Ludovic Landry on 7/4/13.
//  Copyright (c) 2013 Little Green Mens. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol LGMDragAndDropViewDelegate <NSObject>

- (void)didDropFilesWithPaths:(NSArray *)paths;

@end

@interface LGMDragAndDropView : NSView

@property (nonatomic, assign) id<LGMDragAndDropViewDelegate> delegate;

@end
