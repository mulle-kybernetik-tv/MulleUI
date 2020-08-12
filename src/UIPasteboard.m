//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UIPasteboard.h"

#import "import-private.h"



@implementation UIPasteboard

+ (instancetype) pasteboardWithWindow:(UIWindow *) window
{
   // let window dynamically create and manage a single instance
   return( [window pasteboard]);
}

- (char *) cString
{
   return( [_window pasteboardCString]);
}


- (void) setCString:(char *) s
{
   [_window setPasteboardCString:s];
}

@end
