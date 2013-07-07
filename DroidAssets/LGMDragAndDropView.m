//
//  LGMDragAndDropView.m
//  DroidAssets
//
//  Created by Ludovic Landry on 7/4/13.
//  Copyright (c) 2013 Little Green Mens. All rights reserved.
//

#import "LGMDragAndDropView.h"

@interface LGMDragAndDropView ()
@property (nonatomic, assign) BOOL isHighlighted;
@end

@implementation LGMDragAndDropView

@synthesize delegate;
@synthesize isHighlighted;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    }
    return self;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    [self setHighlighted:YES];
    return NSDragOperationGeneric;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
    [self setHighlighted:NO];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender  {
    NSPasteboard *pboard = [sender draggingPasteboard];
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        NSArray *paths = [pboard propertyListForType:NSFilenamesPboardType];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDropFilesWithPaths:)]) {
            [self.delegate didDropFilesWithPaths:paths];
        }
    }
    [self setHighlighted:NO];
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    [self setHighlighted:NO];
    return YES;
}

- (void)concludeDragOperation:(id )sender {
    [self setNeedsDisplay:YES];
}

- (BOOL)isHighlighted {
    return isHighlighted;
}

- (void)setHighlighted:(BOOL)value {
    isHighlighted = value;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeState:)]) {
        [self.delegate didChangeState:value];
    }
}

@end
