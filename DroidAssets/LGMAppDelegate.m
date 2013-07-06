//
//  LGMAppDelegate.m
//  DroidAssets
//
//  Created by Ludovic Landry on 7/4/13.
//  Copyright (c) 2013 Little Green Mens. All rights reserved.
//

#import "LGMAppDelegate.h"
#import "LGMDragAndDropViewController.h"

@interface LGMAppDelegate ()
@property (nonatomic, strong) LGMDragAndDropViewController *dragAndDropViewController;
@end

@implementation LGMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // Create the Project View Controller
    self.dragAndDropViewController = [[LGMDragAndDropViewController alloc] init];
    
    // Add the view controller to the Window's content view
    NSView *contentView = self.window.contentView;
    [contentView addSubview:self.dragAndDropViewController.view];
    self.dragAndDropViewController.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.dragAndDropViewController.view.frame = contentView.bounds;
}

@end
