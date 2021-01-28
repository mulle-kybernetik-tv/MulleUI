#ifdef __has_include
# if __has_include( "CGBase.h")
#  include "CGBase.h"
# endif
#endif

#ifdef __has_include
# if __has_include( "MulleEdgeInsets.h")
#  include "MulleEdgeInsets.h"
# endif
#endif


#include "include.h"

#include <string.h>


static inline CGPoint   MulleRectGetCenter( CGRect rect)
{
   return( CGPointMake( CGRectGetMidX( rect), CGRectGetMidY( rect)));
}

//
// Basically follow the definitions set in here
// https://yogalayout.com/
// except we don't do padding (which is insets used by UIView for the content)
// The margin handling is different, in that we merge margins.
// i.e. ---| |----   will be a distance of 20 and not of 30 like in Yoga
//       10   20
//

// keep this simple.. any additional layouting like centering or justifying
// should be done in a second pass

struct MulleLayout
{
   CGPoint           offset;
   CGSize            space;

   CGPoint           origin;
   CGSize            size;

   CGRect            lastRect;
   CGRect            usedRect;   // combined rectangle ?
   MulleEdgeInsets   lastMargins;
};


static inline void  _MulleLayoutInitWithRect( struct MulleLayout *p, CGRect rect)
{
   p->space       = rect.size;
   p->offset      = rect.origin;

   // read only (in algorithm)
   p->origin      = rect.origin;
   p->size        = rect.size;

   p->lastRect    = CGRectZero;
   p->usedRect    = CGRectZero;
   p->lastMargins = MulleEdgeInsetsZero;
}


static inline void  _MulleLayoutDone( struct MulleLayout *p)
{
}


static inline void  MulleLayoutDone( struct MulleLayout *p)
{
}


// 
// +++.......
// + +   ++ .
// +++   ++ .
// .........+
//          
// ###
// # #
// ###

static inline void  _MulleLayoutSetLastRectAndMargins( struct MulleLayout *p,
                                                       CGRect lastRect,
                                                       MulleEdgeInsets lastMargins)
{
   p->lastRect    = lastRect;
   p->lastMargins = lastMargins;
   p->usedRect    = CGRectUnion( p->usedRect, p->lastRect);
}


static inline CGSize  _MulleLayoutGetRemainingRowSize( struct MulleLayout *p)
{
   CGSize   size;

   //
   // problem: when we are adding views to a row we should be adding the
   // max y of the rect plus their margins
   //
   size.width  = p->space.width - p->lastMargins.right;
   size.height = p->space.height - p->lastMargins.bottom;

   return( size);
}


// Each row starts at 0,0. The origin is added to the returned rect on return.
// When a row is done, the height of the row is added to the origin.
//
// +-------------------+
// |                   |
// +-------------------+
//
static inline void   _MulleLayoutNewRow( struct MulleLayout *p)
{
   p->lastMargins.left     = 0.0;
   p->lastMargins.right    = 0.0;
   p->space.width          = p->size.width;
   p->space.height        -= p->usedRect.size.height;
   p->offset.y            += p->usedRect.size.height;
   p->lastRect.origin.x    = 0.0;
   p->lastRect.origin.y    = CGRectGetMaxY( p->usedRect);
   p->lastRect.size.width  = 0.0;
   p->lastRect.size.height = p->usedRect.size.height;
   p->usedRect             = CGRectZero;
}


//
// straightforward, except when space runs out and the margin handling is also
// a bit compicated. Size doesn't fit if there isn't room enough for margins,
// which is also the right edge of the space. The larger margin wins.
// Returns zerosized rect, if it doesn't fit. Does not attempt to change 'y'
//
static inline CGRect   _MulleLayoutAddToRow( struct MulleLayout *p,
                                             CGSize size,
                                             MulleEdgeInsets margins)
{
   CGRect    rect;
   CGFloat   margin;

   rect.size     = size;
   rect.origin.y = CGRectGetMinY( p->lastRect) + margins.top;
   if( CGRectGetMaxY( rect) > p->space.height)
      return( CGRectZero);

   margin        = margins.left > p->lastMargins.right 
                     ? margins.left 
                     : p->lastMargins.right;
   rect.origin.x = CGRectGetMaxX( p->lastRect) + margin;

   // check that we don't extend over space
   if( rect.size.width + margins.right > p->space.width)
      return( CGRectZero);

   // left margin is now "fixed" and can be subtracted
   p->space.width -= rect.size.width + margin;

   _MulleLayoutSetLastRectAndMargins( p, rect, margins);

   rect.origin.x += p->offset.x;
   rect.origin.y += p->offset.y;

   return( rect);
}


CGRect   _MulleLayoutAddToRowWithOverflow( struct MulleLayout *p,
                                           CGSize size,
                                           MulleEdgeInsets margins);


// so adjust x, so that centers align
static inline CGRect   MulleRectAlignCenterInColumn( CGRect rect,
                                                     CGPoint otherCenter)
{
   rect.origin.x += otherCenter.x - CGRectGetMidX( rect);
   return( rect);
}


static inline CGRect   MulleRectAlignCenterInRow( CGRect rect,
                                                  CGPoint otherCenter)
{
   rect.origin.y += otherCenter.y - CGRectGetMidY( rect);
   return( rect);
}
