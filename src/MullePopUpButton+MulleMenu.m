//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "MullePopUpButton+MulleMenu.h"

#import "import-private.h"

#import "UIWindow.h"
#import "MulleMenu.h"
#import "UIView+CGGeometry.h"
#import "UIView+Layout.h"


@implementation MullePopUpButton ( MulleMenu)

- (MulleMenu *) menu
{
   MulleWindowPlane   *menuPlane;
   UIWindow           *window;
   MulleMenu          *menuView;

   if( _menu)
      return( _menu);

   menuView = [MulleMenu mulleViewWithFrame:CGRectMake( 0, 0, 200, 75)];
   [menuView setTarget:self];
   [menuView setAction:@selector( outsideMenuClicked:)];
   [menuView setHidden:YES];

   window = [self window];
   [menuView addMenuButtonsWithTitleCStrings:_titles
                                       count:_titlesCount
                                      target:self
                                      window:window];


   menuPlane = [window menuPlane];

   [menuPlane addSubview:menuView];
   [menuPlane setNeedsLayout];
   [menuPlane setHidden:NO];

   [self setMenu:menuView];

   return( menuView);
}

- (void) positionMenu:(MulleMenu *) menu
{
   CGRect              left;
   CGRect              right;
   CGRect              top;
   CGRect              bottom;
   CGRect              frame;
   CGRect              buttonFrame;
   CGRect              menuFrame;
   CGRect              menuPlaneBounds;
   MulleWindowPlane   *plane;
   
   // this positions the menu origin and size relative to the button, so
   // a) it looks nice
   // b) enough entries are visible

   // 1. look at spaces to left, right, top an bottom
   frame       = [self frame];

   plane       = [self mulleWindowPlane];
   buttonFrame = [[self superview] convertRect:frame
                                        toView:plane];

   // now we look at the plance and divide it up
   top    =  
   left   = 
   bottom =
   right  = [plane bounds];

   //  0   4   8  12   16
   //  +---------------+
   //  | t :   o   : p |
   //  |...+-------+...| bounds
   //  |   | frame |   |
   //  |...+-------+...|
   //  |   :       :   |
   //  +---------------+

   top.size.height     = CGRectGetMinY( buttonFrame) + top.origin.y;

   left.size.width     = CGRectGetMinX( buttonFrame) + left.origin.x;

   bottom.size.height -= buttonFrame.size.height + CGRectGetMinY( buttonFrame) + bottom.origin.y;
   bottom.origin.y    += CGRectGetMaxY( buttonFrame);

   right.size.width   -= buttonFrame.size.width + CGRectGetMinX( buttonFrame) + right.origin.x;
   right.origin.x     += CGRectGetMaxX( buttonFrame);

   menuFrame = [menu frame];

   // Try to align menu so it fits left edge of button, otherwise try right
   // edge. otherwise ?
   // Prefer direction bottom:

   if( menuFrame.size.width <= right.size.width)
   {
      // Can extend right.
      //
      //  ( Button | V )
      //   +--------------+
      //   |  Menu        |
      //   +--------------+ 

      menuFrame.origin.x = CGRectGetMinX( buttonFrame);
   }
   else
      if( menuFrame.size.width <= left.size.width)
      {
         // Can extend up, possibly should cover button text here ? 
         //
         //  ( Button | V )
         // +-------------+
         // |  Menu       |
         // +-------------+ 

         menuFrame.origin.x = CGRectGetMaxX( buttonFrame) - menuFrame.size.width;
      }
      else
         abort();

   // get size of menu, can we fit it vertically ?
   // Prefer direction bottom:

   if( menuFrame.size.height <= bottom.size.height)
   {
      // Can extend down. Ideally want to extend from top/left, leaving the
      // disclosure rectangle out of the scene. Don't want to truncate the
      // titles though. Tricky! Menu should already be layouted for the titles,
      // so that we can enlarge the widths, but don't shrink the widths.
      //
      //
      //  ( Button | V )
      //   +-------+
      //   |  Menu |
      //   +-------+ 

      menuFrame.origin.y    = CGRectGetMaxY( buttonFrame);
      menuFrame.size.height = bottom.size.height; 
   }
   else
      if( menuFrame.size.height <= top.size.height)
      {
         // Can extend up, possibly should cover button text here ? 
         //
         //   +-------+
         //   |  Menu |
         //   +-------+ 
         //  ( Button | V )

         menuFrame.origin.y = CGRectGetMinY( buttonFrame) - menuFrame.size.height;
         menuFrame.size.height = top.size.height; 
      }
      else
         abort();

   [menu setFrame:menuFrame];
   [menu setNeedsLayout];
}
 
@end
