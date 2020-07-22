#import "import-private.h"

#import "UIView.h"
#import "UIView+CGGeometry.h"
#import "CGGeometry+CString.h"
#import <string.h>


int   main()
{
   UIView   *a;
   UIView   *b;
   UIView   *c;
   CGRect    frame;
   CGRect    rect;
   CGRect    converted;
  
   frame = CGRectMake( 0, 0, 100, 100);
   a     = [[[UIView alloc] initWithFrame:frame] autorelease];
   frame = CGRectMake( 5, 5, 90, 90);
   b     = [[[UIView alloc] initWithFrame:frame] autorelease];
   frame = CGRectMake( 10, 10, 70, 70);
   c     = [[[UIView alloc] initWithFrame:frame] autorelease];

   [a addSubview:b];
   [b addSubview:c];

   rect      = CGRectMake( 1, 1, 1, 1);
   converted = [a convertRect:rect
                       toView:b];
   printf( "%s a -> b : %s\n", 
      CGRectCStringDescription( rect),
      CGRectCStringDescription( converted));

   converted = [a convertRect:CGRectMake( 1, 1, 1, 1)
                       toView:c];
   printf( "%s a -> b : %s\n", 
      CGRectCStringDescription( rect),
      CGRectCStringDescription( converted));

   [a dump];
   return( 0);
}

