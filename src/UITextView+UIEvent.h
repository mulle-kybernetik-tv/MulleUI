//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
// prefer a local UITextView over one in import.h
#ifdef __has_include
# if __has_include( "UITextView.h")
#  import "UITextView.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


#ifdef __has_include
# if __has_include( "MulleKeyboardEventConsumer.h")
#  import "MulleKeyboardEventConsumer.h"
# endif
#endif


@interface UITextView( UIEvent) < MulleKeyboardEventConsumer >
@end
