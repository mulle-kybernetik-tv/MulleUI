#import "import-private.h"

#import "CGBase.h"
#import "CGContext.h"
#import "CGGeometry.h"
#import "CGColor+MulleObjC.h"
#import "CGGeometry+CString.h"
#import "CGGeometry+MulleObjC.h"
#import "UIApplication.h"
#import "UIWindow.h"
#import "UIView.h"
#import "UICollectionView.h"
#import "UIView+CAAnimation.h"
#import "UIColor.h"
#import "CALayer.h"
#import <string.h>
#import "UIEdgeInsets.h"

// scale stuff for stream
#define SCALE     2.0

static void   setupSceneInContentPlane( MulleWindowPlane *contentPlane)
{
   UIView                                *view;
   CGRect                                frame;
   CGRect                                rect;
   UIEdgeInsets                          insets;
   CGFloat                               scale;
   CGFloat                               translate;
   NSInteger                             i;
   UICollectionView                      *collectionView;
   UIView                                *contentView;
   struct mulle_pointerarrayenumerator   rover;
   struct mulle_pointerarray             array;

   frame = [contentPlane frame];

   collectionView = [[[UICollectionView alloc] initWithFrame:CGRectZero] autorelease];
   [collectionView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
   [collectionView setContentSize:CGSizeMake( frame.size.width, 4000)];
   [contentPlane addSubview:collectionView];

   contentView = [collectionView contentView];

   for( i = 0; i < 1000; i++)
   {
      rect.origin.x = rand() % ((int) frame.size.width - 64);
      rect.origin.y = rand() % ((int) 4000 - 64);
      rect.size     = CGSizeMake( 64, 64);
      view  = [[[UIView alloc] initWithFrame:rect] autorelease];
      [view setBackgroundColor:MulleColorCreateRandom( 0x00FF00FF, 0xFF00FF00)];
      [contentView addSubview:view];
   }
}


int   main()
{
   CGContext   *context;
   UIWindow    *window;

   /*
    * window and app 
    */
   window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 400.0 * SCALE, 300.0 * SCALE)] autorelease];
   assert( window);

   [[UIApplication sharedInstance] addWindow:window];

   context = [[CGContext new] autorelease];
   [context setBackgroundColor:CGColorCreateGenericRGB( 1.0, 1.0, 1.0, 1.0)];

   setupSceneInContentPlane( [window contentPlane]);

   [window dump];
   [window renderLoopWithContext:context];

   [[UIApplication sharedInstance] terminate];
}

