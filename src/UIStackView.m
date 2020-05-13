//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UIStackView.h"

#import "import-private.h"



@implementation UIStackView

- (void) layoutSubviews
{
   struct  mulle_pointerarrayenumerator   rover;
   NSUInteger                             i;
   UIView                                 *view;
   CGRect                                 rect;
   CGRect                                 frame;

   // calculate area, where we can layout
   rect = [self bounds];
   rect = UIEdgeInsetsInsetRect( rect, _contentInsets);

   rover = mulle_pointerarray_enumerate_nil( self->_subviews);
   while( view = _mulle_pointerarrayenumerator_next( &rover))   
   {
      // is view resizable ?
      frame = [view frame];

      frame.origin = rect.origin;
      [view setFrame:frame];

      if( _axis == UILayoutConstraintAxisHorizontal)
         rect.origin.x += frame.size.width;
      else
         rect.origin.y += frame.size.height;
   }
   mulle_pointerarrayenumerator_done( &rover);
}

@end
