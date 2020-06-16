//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UIStackView.h"

#import "UIView+Layout.h"

#import "import-private.h"



struct UIStackViewLayoutContext
{
   CGRect               bounds;
   NSUInteger           n_views;
   UIViewAutoresizing   defaultMask;   
};



@implementation UIStackView

- (instancetype) initWithLayer:(CALayer *) layer
{
   [super initWithLayer:layer];

   _axis                    = UILayoutConstraintAxisVertical;
   _minimumInteritemSpacing = 10.0;
   _minimumLineSpacing      = 10.0;   

   return( self);
}


- (void) setSubviewLayoutSizeIfNeeded
 {
   CGSize                                 size;
   CGRect                                 rect;
   struct  mulle_pointerarrayenumerator   rover;
   UIView                                 *view;   

   rover = mulle_pointerarray_enumerate_nil( self->_subviews);
   while( view = _mulle_pointerarrayenumerator_next( &rover))   
   {
      size = [view mulleLayoutSize];
      if( ! CGSizeEqualToSize( size, CGSizeZero))
         continue;

      rect = MulleEdgeInsetsExtrudeRect( [view margins], [view frame]);
      [view setMulleLayoutSize:rect.size];
   }
   mulle_pointerarrayenumerator_done( &rover);
}


- (BOOL) setupLayoutContext:(struct UIStackViewLayoutContext *) ctxt
{
   [self setSubviewLayoutSizeIfNeeded];

   ctxt->n_views = mulle_pointerarray_get_count( self->_subviews);
   if( ctxt->n_views == 0)
      return( NO);

   // calculate area, where we can layout
   ctxt->bounds = [self bounds];
   ctxt->bounds = UIEdgeInsetsInsetRect( ctxt->bounds, _contentInsets);

   switch( _alignment)
   {
   case UIStackViewAlignmentTop         : ctxt->defaultMask = MulleUIViewAutoresizingStickToTop; break;
   case MulleUIStackViewAlignmentBottom : ctxt->defaultMask = MulleUIViewAutoresizingStickToBottom; break;
   case UIStackViewAlignmentLeading     : ctxt->defaultMask = MulleUIViewAutoresizingStickToLeft; break;
   case UIStackViewAlignmentTrailing    : ctxt->defaultMask = MulleUIViewAutoresizingStickToRight; break;
   default :                              ctxt->defaultMask = MulleUIViewAutoresizingStickToCenter; break;
   }
   return( YES);
}


- (CGSize) areaCoveredByStackingSubviews
 {
   CGSize                                 size;
   CGSize                                 area;
   struct  mulle_pointerarrayenumerator   rover;
   UIView                                 *view;   
   int                                    axis;
   int                                    otherAxis;

   area      = CGSizeZero;
   axis      = _axis;
   otherAxis = ! axis;
        
   rover = mulle_pointerarray_enumerate_nil( self->_subviews);
   while( view = _mulle_pointerarrayenumerator_next( &rover))   
   {
      size = [view mulleLayoutSize];
      area.value[ otherAxis] = size.value[ otherAxis] > area.value[ otherAxis] 
                                   ? size.value[ otherAxis] 
                                   : area.value[ otherAxis];
      area.value[ axis]     += size.value[ axis];
   }
   mulle_pointerarrayenumerator_done( &rover);

   return( area);
}


// UIStackViewDistributionFillEqually
- (void) layoutSubviewsFillEqually
{
   CGRect                                 rect;
   int                                    axis;
   struct  mulle_pointerarrayenumerator   rover;
   UIView                                 *view;
   UIViewAutoresizing                     mask;
   struct UIStackViewLayoutContext        ctxt;

   if( ! [self setupLayoutContext:&ctxt])
      return;

   rect = ctxt.bounds;
   axis = _axis;

   rect.size.value[ axis] = rect.size.value[ axis] / ctxt.n_views;
   rover = mulle_pointerarray_enumerate_nil( self->_subviews);
   while( view = _mulle_pointerarrayenumerator_next( &rover))   
   {
      // each view autoresizes in the bounds we divided it up for
      mask = [view autoresizingMask];
      if( mask == UIViewAutoresizingNone)
         mask = ctxt.defaultMask;
      [self layoutSubview:view
                 inBounds:rect
         autoresizingMask:mask];
      rect.origin.value[ axis] += rect.size.value[ axis];
   }
   mulle_pointerarrayenumerator_done( &rover);
}


//
// UIStackViewDistributionFill
//
// Basically just add views, left to right or top to bottom. If there is space 
// left at the end, the last view will get it. If views exhaust the space, they
// will get bounds of 0 size 
//
// UIStackViewDistributionFillProportionally. Only really useful if there
// are resizable views in there, possibly all of them
//
- (void) layoutSubviewsFillProportionally:(BOOL) proportionally
{
   CGFloat                                factor;
   CGFloat                                remainder;
   CGRect                                 rect;
   CGSize                                 area;
   CGSize                                 size;
   int                                    axis;
   struct  mulle_pointerarrayenumerator   rover;
   UIView                                 *flexView;
   UIView                                 *lastView;
   UIView                                 *view;
   UIViewAutoresizing                     flexBit;
   UIViewAutoresizing                     mask;
   struct UIStackViewLayoutContext        ctxt;

   if( ! [self setupLayoutContext:&ctxt])
      return;

   axis      = _axis;
   lastView = _mulle_pointerarray_find_last( self->_subviews);
   area     = [self areaCoveredByStackingSubviews];
   rect     = ctxt.bounds;
   factor   = 1.0;

   flexBit = (axis == UILayoutConstraintAxisHorizontal) 
                  ?  UIViewAutoresizingFlexibleWidth 
                  : UIViewAutoresizingFlexibleHeight;

   remainder = ctxt.bounds.size.value[ axis];
      if( proportionally && area.value[ axis] != 0.0)
         factor = ctxt.bounds.size.value[ axis] / area.value[ axis];

   rover = mulle_pointerarray_enumerate_nil( self->_subviews);
   while( view = _mulle_pointerarrayenumerator_next( &rover))   
   {
      mask = [view autoresizingMask];
      if( mask == UIViewAutoresizingNone)
         mask = ctxt.defaultMask;

      // if the view is resizable and we are doing  just Fill, then
      // the first candidate gets all the remaining space or gets shrunk
      // by it
      size = [view mulleLayoutSize];
      if( ! proportionally && (mask & flexBit))
      {
         // calc space as height - height given to others
         size.value[ axis] = ctxt.bounds.size.value[ axis] - (area.value[ axis] - size.value[ axis]);
         if( size.value[ axis] < 0.0)
            size.value[ axis] = 0.0;
         rect.size.value[ axis] = size.value[ axis];
      }
      else
      {
         size.value[ axis] *= factor;
         if( size.value[ axis] > remainder || view == lastView)
            rect.size.value[ axis] = remainder;
         else
            rect.size.value[ axis] = size.value[ axis];
      }

      // each view autoresizes in the bounds we divided it up for
      [self layoutSubview:view
                 inBounds:rect
         autoresizingMask:mask];

      rect.origin.value[ axis] += rect.size.value[ axis];
      remainder                -= rect.size.value[ axis];
   }
   mulle_pointerarrayenumerator_done( &rover);
}



// UIStackViewDistributionEqualSpacing
- (void) layoutSubviewsEquallySpaced:(CGFloat) edge
{
   CGRect                                 rect;
   int                                    axis;
   struct mulle_pointerarrayenumerator    rover;
   UIView                                 *view;
   UIViewAutoresizing                     mask;
   CGFloat                                space;
   CGSize                                 size;
   CGSize                                 area;
   struct UIStackViewLayoutContext        ctxt;

   if( ! [self setupLayoutContext:&ctxt])
      return;

   axis  = _axis;
   area  = [self areaCoveredByStackingSubviews];
   space = 0;
   if( ctxt.n_views > 1)
      space = (ctxt.bounds.size.value[ axis] - area.value[ axis] - edge) / (ctxt.n_views - 1);

   rect = ctxt.bounds;
   rover = mulle_pointerarray_enumerate_nil( self->_subviews);
   while( view = _mulle_pointerarrayenumerator_next( &rover))   
   {
      // each view autoresizes in the bounds we divided it up for
      mask = [view autoresizingMask];
      if( mask == UIViewAutoresizingNone)
         mask = ctxt.defaultMask;

      size                   = [view mulleLayoutSize];
      rect.size.value[ axis] = size.value[ axis]; 
      [self layoutSubview:view
                 inBounds:rect
         autoresizingMask:mask];
      rect.origin.value[ axis] += rect.size.value[ axis] + space;
   }
   mulle_pointerarrayenumerator_done( &rover);
}


// UIStackViewDistributionEqualCentering
// See: https://spin.atomicobject.com/2016/06/22/uistackview-distribution/ 
// for what this does. It's probably useles

- (void) layoutSubviewsEquallyCentered
{
   int                                   axis;
   UIView                                *firstView;
   UIView                                *lastView;
   UIView                                *view;
   struct UIStackViewLayoutContext       ctxt;
   struct mulle_pointerarrayenumerator   rover;
   UIViewAutoresizing                    mask;
   CGFloat                               leftEdge;
   CGFloat                               rightEdge;
   CGFloat                               space;
   CGRect                                rect;
   CGSize                                size;
   NSUInteger                            i;

   if( ! [self setupLayoutContext:&ctxt])
      return;

   firstView = _mulle_pointerarray_get( self->_subviews, 0);
   lastView  = _mulle_pointerarray_find_last( self->_subviews);
   axis      = _axis;
   leftEdge  = [firstView mulleLayoutSize].value[ axis] / 2.0;
   rightEdge = [lastView mulleLayoutSize].value[ axis] / 2.0;

   space = 0;
   if( ctxt.n_views)
      space = (ctxt.bounds.size.value[ axis] - leftEdge - rightEdge) / (ctxt.n_views - 1);

   rect = ctxt.bounds;
   i    = 0;
   rover = mulle_pointerarray_enumerate_nil( self->_subviews);
   while( view = _mulle_pointerarrayenumerator_next( &rover))   
   {
      // each view autoresizes in the bounds we divided it up for
      mask = [view autoresizingMask];
      if( mask == UIViewAutoresizingNone)
         mask = ctxt.defaultMask;

      size                     = [view mulleLayoutSize];
      rect.size.value[ axis]   = size.value[ axis]; 
      rect.origin.value[ axis] = ctxt.bounds.origin.value[ axis]
                                 + leftEdge 
                                 + (space * i) 
                                 - rect.size.value[ axis] / 2; 
      [self layoutSubview:view
                 inBounds:rect
         autoresizingMask:mask];
      ++i;
   }
   mulle_pointerarrayenumerator_done( &rover);
}


//
// layout in row, column fashion. The views need to be fixed size currently
// 
- (void) layoutSubviewsFillRowColumn
{
   CGRect                                 bounds;
   struct  mulle_pointerarrayenumerator   rover;
   UIView                                 *view;
   CGRect                                 rect;
   CGRect                                 rowBounds;
   CGRect                                 frame;
   CGFloat                                rowHeight;
   CGFloat                                value;
   CGSize                                 spacing;
   NSUInteger                             column;
   int                                    axis;
   int                                    otherAxis;

   axis      = [self axis];
   otherAxis = ! axis;

   spacing.value[ axis]      = [self minimumInteritemSpacing];
   spacing.value[ otherAxis] = [self minimumLineSpacing];

   bounds        = [self bounds];
   bounds        = UIEdgeInsetsInsetRect( bounds, [self contentInsets]);
   rowBounds     = bounds;
   column        = 0;

   rover  = mulle_pointerarray_enumerate_nil( self->_subviews);
   while( view = _mulle_pointerarrayenumerator_next( &rover))   
   {
      frame = [view frame];
      if( frame.size.value[ axis] > rowBounds.size.value[ axis] - (column ? spacing.value[ axis] : 0))
      {
         // start a new row
         column                             = 0;
         rowBounds.size.value[ axis]        = bounds.size.value[ axis];
         rowBounds.origin.value[ axis]      = bounds.origin.value[ axis];
         rowBounds.origin.value[ otherAxis] = rowBounds.origin.value[ otherAxis] \
                                              + rowHeight \
                                              + spacing.value[ otherAxis];
         rowBounds.size.value[ otherAxis]   = bounds.size.value[ otherAxis] \
                                              - rowBounds.origin.value[ otherAxis];
         rowHeight = frame.size.value[ otherAxis];
      }
      rect.origin = rowBounds.origin;
      if( frame.size.value[ otherAxis] > rowBounds.size.value[ otherAxis])
         rect.size = CGSizeZero;
      else
         rect.size = frame.size;

      [self layoutSubview:view
                 inBounds:rect
         autoresizingMask:MulleUIViewAutoresizingStickToTop|MulleUIViewAutoresizingStickToLeft];

      // advance preshrunk remaining row 
      rowBounds.origin.value[ axis] += frame.size.value[ axis] + spacing.value[ axis];
      rowBounds.size.value[ axis]   -= frame.size.value[ axis] + spacing.value[ axis];
      rowHeight                      = frame.size.value[ otherAxis] > rowHeight ? frame.size.value[ otherAxis] : rowHeight;
      ++column;
   }
   mulle_pointerarrayenumerator_done( &rover);
}


- (void) layoutSubviews
{
   switch( _distribution)
   {
   case UIStackViewDistributionFill               : [self layoutSubviewsFillProportionally:NO]; break;
   case UIStackViewDistributionFillEqually        : [self layoutSubviewsFillEqually]; break;
   case UIStackViewDistributionFillProportionally : [self layoutSubviewsFillProportionally:YES]; break;
   case UIStackViewDistributionEqualSpacing       : [self layoutSubviewsEquallySpaced:0]; break;
   case UIStackViewDistributionEqualCentering     : [self layoutSubviewsEquallyCentered]; break;
   case MulleStackViewDistributionFillRowColumn   : [self layoutSubviewsFillRowColumn]; break;
   default                                        : abort();
   }
}

@end
