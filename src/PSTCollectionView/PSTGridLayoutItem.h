//
//  PSTGridLayoutItem.h
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "import.h"

#import "CGGeometry.h"


@class PSTGridLayoutSection, PSTGridLayoutRow;

// Represents a single grid item; only created for non-uniform-sized grids.
@interface PSTGridLayoutItem : NSObject

@property ( assign) PSTGridLayoutSection *section;
@property ( assign) PSTGridLayoutRow *rowObject;
@property ( assign) CGRect itemFrame;

@end
