//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
// prefer a local UITextView over one in import.h
#ifdef __has_include
# if __has_include( "UITextView.h")
#  import "UITextView.h"
# endif
#endif

// we wan't "import.h" always anyway
#import "import.h"


@interface UITextView( Markdown)

- (NSArray *) textLines;
- (NSArray *) images;

@end
