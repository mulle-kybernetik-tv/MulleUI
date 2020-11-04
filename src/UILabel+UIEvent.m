//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UILabel+UIEvent.h"

#import "import-private.h"

#import "MulleTextLayer+Selection.h"
#import "UIEvent.h"


@implementation UILabel ( UIEvent)

- (UIEvent *) mouseDown:(UIEvent *) event
{
   CGPoint           mouseLocation;
   MulleTextLayer    *textLayer;

   mouseLocation = [event mouseLocationInView:self];
   textLayer     = (MulleTextLayer *) _mainLayer;
   [textLayer startSelectionAtPoint:mouseLocation];

   return( nil);
}


- (UIEvent *) mouseDragged:(UIEvent *) event
{
   CGPoint           mouseLocation;
   MulleTextLayer    *textLayer;

   mouseLocation = [event mouseLocationInView:self];
   textLayer     = (MulleTextLayer *) _mainLayer;
   [textLayer adjustSelectionToPoint:mouseLocation];
   return( nil);
}

@end
