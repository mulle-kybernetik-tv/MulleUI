//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
// prefer a local UIButton over one in import.h
#ifdef __has_include
# if __has_include( "UIButton.h")
#  import "UIButton.h"
# endif
#endif

// we wan't "import.h" always anyway
#import "import.h"


@interface UIButton( UIResponder)

- (void) reflectState;

@end
