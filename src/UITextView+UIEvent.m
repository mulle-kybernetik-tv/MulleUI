//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UITextView+UIEvent.h"

#import "import-private.h"

#import "UIView+UIEvent.h"
#import "UIEvent.h"

#import "MulleCursorProtocol.h"


@implementation UITextView ( UIEvent)


- (UIEvent *) mouseDown:(UIEvent *) event
{
   CGPoint   mouseLocation;

   mouseLocation = [event mouseLocationInView:self];
   [self startSelectionAtPoint:mouseLocation];
   [self setCursorPositionToPoint:mouseLocation];

   return( nil);
}


- (UIEvent *) mouseDragged:(UIEvent *) event
{
   CGPoint                    mouseLocation;
   struct MulleIntegerPoint   cursor;

   mouseLocation = [event mouseLocationInView:self];
   [self adjustSelectionToPoint:mouseLocation];

   cursor = [self cursorPositionForPoint:mouseLocation];
   [self setCursorPosition:cursor]; 
       
   return( nil);
}

@end
