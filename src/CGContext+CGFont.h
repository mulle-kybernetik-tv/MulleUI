//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
// prefer a local CGContext over one in import.h
#ifdef __has_include
# if __has_include( "CGContext.h")
#  import "CGContext.h"
# endif
#endif

// we wan't "import.h" always anyway
#import "import.h"


@interface CGContext( CGFont)

- (CGFont *) fallbackFont;
- (CGFont *) fontWithName:(char *) s;
- (CGFont *) fontWithName:(char *) s;
- (CGFloat) fontScale;
@end
