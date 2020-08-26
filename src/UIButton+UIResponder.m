//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UIButton+UIResponder.h"

#import "import-private.h"


@implementation UIButton ( UIResponder)

- (void) reflectState
{
   UIControlState   state;
   UIControlState   fallbackState;
   CGRect           frame;
   UIImage          *image;
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

   image         = [self backgroundImageForState:state];
   fallbackState = state & ~UIControlStateDisabled;
   if( ! image)
   {
      image = [self backgroundImageForState:fallbackState];
      fallbackState &=~UIControlStateSelected;
   }
   if( ! image)
      image = [self backgroundImageForState:fallbackState];
   [self setBackgroundImage:image];
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


- (BOOL) becomeFirstResponder
{
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
      fprintf( stderr, "resign\n");
      [self setSelected:NO];
      [self reflectState];
      return( YES);
   }
   return( NO);
}

@end
