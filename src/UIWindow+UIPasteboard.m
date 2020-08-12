//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UIWindow+UIPasteboard.h"

#import "import-private.h"

#import "UIPasteboard.h"


@implementation UIWindow ( UIPasteboard)


- (UIPasteboard *) pasteboard
{
   if( ! _pasteboard)
   {
      assert( _window);
      _pasteboard = [UIPasteboard new];
      [_pasteboard setWindow:self];
   }
   return( _pasteboard);
}


- (char *) pasteboardCString
{
   return( glfwGetClipboardString( _window));	
}


- (void) setPasteboardCString:(char *) s
{
   glfwSetClipboardString( _window, s ? s : "");
}

@end
