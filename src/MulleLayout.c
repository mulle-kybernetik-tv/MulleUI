#include "MulleLayout.h"

#include "include-private.h"

CGRect   _MulleLayoutAddToRowWithOverflow( struct MulleLayout *p,
                                           CGSize size,
                                           MulleEdgeInsets margins)
{
   CGRect   rect;

   rect = _MulleLayoutAddToRow( p, size, margins);
   if( rect.size.width != 0.0)
      return( rect);

   _MulleLayoutNewRow( p);
   rect = _MulleLayoutAddToRow( p, size, margins);
   return( rect);
}

