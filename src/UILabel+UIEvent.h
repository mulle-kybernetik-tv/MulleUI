//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
// prefer a local UILabel over one in import.h
#ifdef __has_include
# if __has_include( "UILabel.h")
#  import "UILabel.h"
# endif
#endif

// we wan't "import.h" always anyway
#import "import.h"


@interface UILabel( UIEvent)
@end
