//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UIView+Layout.h"

#import "UIView+CAAnimation.h"
#import "import-private.h"



@implementation UIView ( Layout)

// https://developer.apple.com/documentation/uikit/uiview/1622625-sizethatfits?language=objc
- (CGSize) sizeThatFits:(CGSize) size
{
   return( [_mainLayer frame].size);
}

# pragma mark -

- (void) startLayoutWithFrameInfo:(struct MulleFrameInfo *) info
{
   [UIView beginAnimations:NULL
                   context:NULL];

   // linear is better for animations that are restarted often,
   // like during a resize
   [UIView setAnimationCurve:UIViewAnimationCurveLinear];

   // if this is too small, it looks more like a glitch than a wanted effect
   // e.g. 0.05 too small
   [UIView setAnimationDuration:0.20];
}


- (void) endLayout
{
   [UIView commitAnimations];
}

#pragma mark - layout


//
// propagate up, but stop if already marked
//
- (void) _setNeedsLayout
{
   UIView   *view;

   view = self;
   do
   {
      if( view->_needsLayout)
         break;
      view->_needsLayout = YES;
   }
   while( (view = view->_superview));
}


- (void) setNeedsLayout
{
   [self _setNeedsLayout]; // patch point
}


- (void) layoutSubview:(UIView *) view
              inBounds:(CGRect) bounds
      autoresizingMask:(UIViewAutoresizing) autoresizingMask
{
   CGRect   frame;
   CGRect   newFrame;
   CGRect   marginalBounds;

   if( ! autoresizingMask)
      return;

   frame    = [view frame];
   newFrame = frame;

   marginalBounds = bounds;
   if( ! (autoresizingMask & MulleUIViewAutoresizingIgnoreMargins))
   {
      marginalBounds  = UIEdgeInsetsInsetRect( bounds, [view margins]);
      newFrame.origin = marginalBounds.origin;
   }

   // if too small now, remove from drawing
   // as the drawing code does it too, what's really the point though ?

   if( autoresizingMask & UIViewAutoresizingFlexibleWidth)
   {
      newFrame.size.width = marginalBounds.size.width;
      if( newFrame.size.width < 0.9)
        newFrame.size.width = 0.0;
   }

   if( autoresizingMask & UIViewAutoresizingFlexibleHeight)
   {
      newFrame.size.height = marginalBounds.size.height;
      if( newFrame.size.height < 0.9)
        newFrame.size.height = 0.0;
   }

   if( autoresizingMask & MulleUIViewAutoresizingStickToCenter)
   {
      // probably too obscure ?
      if( (autoresizingMask & MulleUIViewAutoresizingStickToCenter) == MulleUIViewAutoresizingStickToCenter)
         newFrame = MulleCGRectCenterInRect( newFrame, marginalBounds);
      else
      {
         if( autoresizingMask & MulleUIViewAutoresizingStickToTop)
         {
            newFrame.origin.y = marginalBounds.origin.y;
         }
         else
            if( autoresizingMask & MulleUIViewAutoresizingStickToBottom)
            {
               newFrame.origin.y = CGRectGetMaxY( marginalBounds) - newFrame.size.height;
            }

         if( autoresizingMask & MulleUIViewAutoresizingStickToLeft)
         {
            newFrame.origin.x = marginalBounds.origin.x;
         }
         else
            if( autoresizingMask & MulleUIViewAutoresizingStickToRight)
            {
               newFrame.origin.x = CGRectGetMaxX( marginalBounds) - newFrame.size.width;
            }
      }
   }

   // if view doesn't fit into bounds, we do what ? we make it invisible
   if( ! CGRectContainsRect( bounds, newFrame))
      newFrame.size = CGSizeZero;

   if( ! CGRectEqualToRect( frame, newFrame))
      [view setFrame:newFrame];
}


- (enum UILayoutStrategy) layoutStrategy
{
   return( UILayoutStrategyDefault);
}


- (void) layoutSubviews
{
   struct mulle_pointerarrayenumerator   rover;
   UIView                                *view;
   CGRect                                bounds;

   bounds = [self bounds];
   rover = mulle_pointerarray_enumerate( _subviews);
   while( _mulle_pointerarrayenumerator_next( &rover, (void **) &view))
      [self layoutSubview:view
                 inBounds:bounds
         autoresizingMask:[view autoresizingMask]];
   mulle_pointerarrayenumerator_done( &rover);
}

//
// Layouting is strictly top/down. Space is distributed from the top to
// the button via bounds/frame and the code in "layoutSubviews" that
// distributes it.
//
- (void) layout
{
   struct mulle_pointerarrayenumerator   rover;
   UIView                                *view;

   /*
    * TOP/DOWN
    */
   [self setNeedsLayout:NO];

   // start Yoga
   switch( [self layoutStrategy])
   {
   case UILayoutStrategyDefault:
   case UILayoutStrategyContinue :
      break;

   case UILayoutStrategyStop:  // yoga says this because its doing it all
      return;
   }

   // this is the flat possibly hardcoded code, that layouts each subview
   [self layoutSubviews];

   //
   // this is recursive code, triggering possibly more autoresizes
   // or yogas..
   //
   rover = mulle_pointerarray_enumerate( _subviews);
   while( _mulle_pointerarrayenumerator_next( &rover, (void **) &view))
      [view layout];
   mulle_pointerarrayenumerator_done( &rover);
}



- (void) layoutIfNeeded
{
   if( [self needsLayout])
      [self layout];
}

@end
