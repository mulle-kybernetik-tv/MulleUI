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


@class UIPasteboard;


@interface UIWindow( UIPasteboard)

- (UIPasteboard *) pasteboard;
- (char *) pasteboardCString;
- (void) setPasteboardCString:(char *) s;

@end
