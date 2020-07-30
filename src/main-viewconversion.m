#import "import-private.h"

#import "UIView.h"
#import "UIView+CGGeometry.h"
#import "CGGeometry+CString.h"
#import <string.h>

static void   print( UIView *a,
                     UIView *b,
                     CGRect rect)
{
   CGRect   converted;

   converted = [a convertRect:rect
                       toView:b];
   printf( "%s <%s [f:%s b:%s]> -> <%s [f:%s b:%s]> : %s\n",
      CGRectCStringDescription( rect),
      [a cStringName],
      CGRectCStringDescription( [a frame]),
      CGRectCStringDescription( [a bounds]),
      [b cStringName],
      CGRectCStringDescription( [b frame]),
      CGRectCStringDescription( [b bounds]),
      CGRectCStringDescription( converted));
}


int   main()
{
   UIView   *a;
   UIView   *b;
   UIView   *c;
   CGRect    frame;
   CGRect    bounds;
   CGRect    rect;
   CGRect    converted;

   frame             = CGRectMake( 0, 0, 1, 1);
   a                 = [[[UIView alloc] initWithFrame:frame] autorelease];

   frame             = CGRectMake( 0, 0, 1, 1);
   b                 = [[[UIView alloc] initWithFrame:frame] autorelease];
   rect              = [b bounds];
   rect.origin.y     = 0.25;
   rect.size.width  *= 2.0;
   rect.size.height *= 2.0;
   [b setBounds:rect];

   frame             = CGRectMake( 0, 0, 1, 1);
   c                 = [[[UIView alloc] initWithFrame:frame] autorelease];
   rect              = [c bounds];
   rect.origin.x     = 0.25;
   rect.size.width  *= 2.0;
   rect.size.height *= 2.0;
   [c setBounds:rect];

   [a addSubview:b];
   [b addSubview:c];

   [a setCStringName:"a"];
   [b setCStringName:"b"];
   [c setCStringName:"c"];

   rect = CGRectMake( 0, 0, 1, 1);

   print( a, a, rect);
   print( a, b, rect);
   print( b, c, rect);
   print( a, c, rect);

   [a dump];
   return( 0);
}

// desired values: a -> c 0.25, 0.50, 4, 4