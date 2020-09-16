//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UICollectionViewCell+UIResponder.h"

#import "import-private.h"



@implementation UICollectionViewCell ( UIResponder)

- (void) setState:(UIControlState) state 
{
   UIControlState   oldState;

   if( state == _state)
      return;

   oldState = _state;
   _state = state;

   [_delegate cell:self
   didChangeStateTo:state
          fromState:oldState];
}


- (void) reflectState
{
   UIControlState   state;

   state = [self state];
   if( state & UIControlStateSelected)
   {
      [self setBorderColor:getNVGColor( 0x20D020FF)];
      [self setBorderWidth:5];
   }
   else
      [self setBorderWidth:0.0];
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


- (BOOL) becomeFirstResponder
{
   if( [super becomeFirstResponder])
   {
      [self mulleToggleSelectedState];
      return( YES);
   }
   return( NO);
}

@end
