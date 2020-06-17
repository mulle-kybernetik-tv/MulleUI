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


struct MulleJSImage
{
   int      handle;
   float    width;
   float    height;
   int      flags;
};




@interface MulleJS( MulleUI)

- (void) addMulleUI;

@end
