//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
// prefer a local MulleJS over one in import.h
#ifdef __has_include
# if __has_include( "MulleJS.h")
#  import "MulleJS.h"
# endif
#endif

// we wan't "import.h" always anyway
#import "import.h"


@interface MulleJS( Math)

// @property( assign) NSUInteger  value;
// @property( retain) id          other;

// - (id) method:(id) other;

@end
