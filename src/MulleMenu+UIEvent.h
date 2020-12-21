//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
// prefer a local MulleMenu over one in import.h
#ifdef __has_include
# if __has_include( "MulleMenu.h")
#  import "MulleMenu.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


@interface MulleMenu( UIEvent)
@end
