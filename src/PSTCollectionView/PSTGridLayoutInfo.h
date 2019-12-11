//
//  PSTGridLayoutInfo.h
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "import.h"

#import "CGGeometry.h"
#import "NSIndexPath.h"


@class PSTGridLayoutSection;

/*
 Every PSTCollectionViewLayout has a PSTGridLayoutInfo attached.
 Is used extensively in PSTCollectionViewFlowLayout.
 */
@interface PSTGridLayoutInfo : NSObject
{    
   NSMutableArray * _sections;
   CGRect _visibleBounds;
   CGSize _layoutSize;
   BOOL _isValid;
}

@property ( copy) NSDictionary * rowAlignmentOptions;
@property ( assign) BOOL usesFloatingHeaderFooter;

// Vertical/horizontal dimension (depending on horizontal)
// Used to create row objects
@property ( assign) CGFloat dimension;

@property ( assign) BOOL horizontal;
@property ( assign) BOOL leftToRight;
@property ( assign) CGSize contentSize;

- (void) setSections:(NSArray *) array; 
- (NSArray *) sections;

// Frame for specific PSTGridLayoutItem.
- (CGRect)frameForItemAtIndexPath:(NSIndexPath *)indexPath;

// Add new section. Invalidates layout.
- (PSTGridLayoutSection *)addSection;

// forces the layout to recompute on next access
// TODO; what's the parameter for?
- (void)invalidate:(BOOL)arg;

// Make a copy of the current state.
- (PSTGridLayoutInfo *)snapshot;

@end
