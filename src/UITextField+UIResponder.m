//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UITextField+UIResponder.h"

#import "import-private.h"

#import "UIEvent.h"
#import "MulleTextLayer.h"
#include "CGGeometry+CString.h"


@implementation UITextField( UIResponder)

- (BOOL) becomeFirstResponder
{
   // I think calling this too often is not good, as it does too much
   assert( ! [self isFirstResponder]);

   if( [super becomeFirstResponder])
   {
      [self setSelected:YES];
      [self reflectState];
      return( YES);
   }
   return( NO);
}


- (BOOL) resignFirstResponder
{
   if( [super resignFirstResponder])
   {
      [self setSelected:NO];
      [self reflectState];
      return( YES);
   }
   return( NO);
}

@end


@implementation UITextField ( UIControl)

- (void) reflectState
{
   UIControlState   state;
   UIControlState   fallbackState;
   CGRect           frame;
   CGColorRef       color;

   state = [self state];

   if( state & UIControlStateSelected)
   {
      [_titleBackgroundLayer setBackgroundColor:getNVGColor( 0xD0D0D0FF)];
      [_titleLayer setTextBackgroundColor:getNVGColor( 0xD0D0D0FF)];
   }
   else
      if( state & UIControlStateHighlighted)
      {
         [_titleBackgroundLayer setBackgroundColor:getNVGColor( 0x6060E0FF)];
         [_titleLayer setTextBackgroundColor:getNVGColor( 0x6060E0FF)];
      }
      else
      {
         [_titleBackgroundLayer setBackgroundColor:getNVGColor( 0xFFFFFFFF)];
         [_titleLayer setTextBackgroundColor:getNVGColor( 0xFFFFFFFF)];
      }
}


// use compatible code
- (void) mulleToggleSelectedState
{
   //
   // target/action has been called already by UIControl
   //
   [super mulleToggleSelectedState];
   [self reflectState];
}


- (void) mulleToggleHighlightedState
{
   [super mulleToggleHighlightedState];
   [self reflectState];
}

//
// The key events are checked for special keys only, like backspace or
// cursor keys. (Or CTRL-A / CTRL-E). Actual text input is being taken
// though Unicode events
//
- (UIEvent *) consumeKeyDown:(UIEvent *) event
{
   UIKeyboardEvent   *keyEvent = (UIKeyboardEvent *) event;
   NSInteger         pos;
   NSInteger         max;
   NSUInteger        key;
   NSUInteger        modifiers;

   fprintf( stderr, "key: %ld scanCode: %ld modifiers: %ld\n", 
                        (long) [keyEvent key], 
                        (long) [keyEvent scanCode],
                        (long) [keyEvent modifiers]);

   pos       = [self cursorPosition];
   key       = [keyEvent key];
   modifiers = [keyEvent modifiers];
   switch( key)
   {
   default   :
      return( nil);

   // TODO: these should be global (MENU ?) events!!
   //       so actually pass the event back up
   case 'V'  :
      if( modifiers == 2) // 2  is CONTROL (linux)
         [self paste];
      return( nil);
   case 'C'  :
      if( modifiers == 2)
         [self copy];
      return( nil);
   case 'XS'  :
      if( modifiers == 2)
         [self cut];
      return( nil);

   case 259  :  
      [self backspaceCharacter]; 
      return( nil);

   case 262 :  pos++; break; // cursor right
   case 263 :  --pos; break; // cursor left
   }

   if( pos < 0)
      pos = 0;
   max = [self maxCursorPosition];
   if( pos > max)
      pos = max;
   [self setCursorPosition:pos];

   return( nil);
}


- (UIEvent *) consumeUnicodeCharacter:(UIEvent *) event
{
   UIUnicodeEvent *unicodeEvent = (UIUnicodeEvent *) event;
   int   c;

   fprintf( stderr, "character: %ld\n", 
                        (long) [unicodeEvent character]);

   c = [unicodeEvent character];
   [self insertCharacter:c];
   return( nil);
}


- (UIEvent *) consumeMouseDown:(UIEvent *) event
{
   CGPoint   mouseLocation;

   mouseLocation = [event mouseLocationInView:self];
   fprintf( stderr, "b) %s\n", CGPointCStringDescription( mouseLocation));

   [_titleLayer setCursorPositionToPoint:mouseLocation];
   return( nil);
}

- (UIEvent *) consumeMouseDragged:(UIEvent *) event
{
   CGPoint   mouseLocation;

   mouseLocation = [event mouseLocationInView:self];
   [_titleLayer adjustSelectionToPoint:mouseLocation];
   return( nil);
}

@end
