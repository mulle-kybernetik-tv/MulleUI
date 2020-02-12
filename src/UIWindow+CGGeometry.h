//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
// prefer a local UIWindow over one in import.h
#ifdef __has_include
# if __has_include( "UIWindow.h")
#  import "UIWindow.h"
# endif
#endif

// we wan't "import.h" always anyway
#import "import.h"


@interface UIWindow( CGGeometry)

// @property( assign) NSUInteger  value;
// @property( retain) id          other;

// - (id) method:(id) other;

@end
