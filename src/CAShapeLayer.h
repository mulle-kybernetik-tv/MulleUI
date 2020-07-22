//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "CALayer.h")
#  import "CALayer.h"
# endif
#endif

#import "import.h"

#include "CGPath.h"


@interface CAShapeLayer : CALayer

@property( observable) CGColorRef   strokeColor;
@property( observable) CGColorRef   fillColor;

//
// Ownership of CGPath is transferred to CALayer and CALayer will call 
// CGPathDestroy on 
// it!
//
@property( assign) struct CGPath  *path;

@end
