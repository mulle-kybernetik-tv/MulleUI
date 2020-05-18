//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UIStackView.h"

#import "UIView+Layout.h"

#import "import-private.h"



@implementation UIStackView

- (void) layoutSubviews
{
   struct  mulle_pointerarrayenumerator   rover;
   NSUInteger                             n_views;
   UIView                                 *view;
   CGRect                                 bounds;

   // calculate area, where we can layout
   bounds = [self bounds];
   bounds = UIEdgeInsetsInsetRect( bounds, _contentInsets);

   n_views = mulle_pointerarray_get_count( self->_subviews);
   if( n_views == 0)
      return;

   if( _axis == UILayoutConstraintAxisVertical)
   {
      bounds.size.height = bounds.size.height / n_views;
      rover = mulle_pointerarray_enumerate_nil( self->_subviews);
      while( view = _mulle_pointerarrayenumerator_next( &rover))   
      {
         // each view autoresizes in the bounds we divided
         [view layoutSelfInBounds:bounds];
         bounds.origin.y += bounds.size.height;
      }
      mulle_pointerarrayenumerator_done( &rover);
   }
   else
   {
      bounds.size.width = bounds.size.width / n_views;
      rover = mulle_pointerarray_enumerate_nil( self->_subviews);
      while( view = _mulle_pointerarrayenumerator_next( &rover))   
      {
         // each view autoresizes in the bounds we divided
         [view layoutSelfInBounds:bounds];
         bounds.origin.x += bounds.size.width;
      }
      mulle_pointerarrayenumerator_done( &rover);
   }
}

@end
