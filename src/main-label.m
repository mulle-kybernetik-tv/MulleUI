#import "import-private.h"

#import "CGContext.h"
#import "UIApplication.h"
#import "UIEvent.h"
#import "UILabel.h"
#import "UIWindow.h"
#import "UIColor.h"
#import "MullePopUpButton.h"
#import "UIView+CAAnimation.h"
#import <string.h>

static UILabel                               *one;
static CATextLayerAlignmentMode               hAlign;
static MulleTextLayerVerticalAlignmentMode    vAlign;

static char  *hTitles[] =
{
   "Left",
   "Center",
   "Right"
};

static char  *vTitles[] =
{
   "Top",
   "Middle",
   "Baseline",
   "Bounds",
   "Bottom"
};


static UIEvent   *hButtonClicked( id <UIControl> control, UIEvent *event)
{
   char   *s;

   fprintf( stderr, "%s\n", __PRETTY_FUNCTION__);

   s = [[(MullePopUpButton *) control clickedButton] titleCString];
   if( s)
   {
      if( *s == 'L')
         hAlign = CAAlignmentLeft;
      else
         if( s && *s == 'C')
            hAlign = CAAlignmentCenter;
         else
            hAlign = CAAlignmentRight;

      [control setTitleCString:s];
   }
   return( nil);
}


static UIEvent   *vButtonClicked( id <UIControl> control, UIEvent *event)
{
   char   *s;

   fprintf( stderr, "%s\n", __PRETTY_FUNCTION__);

   s = [[(MullePopUpButton *) control clickedButton] titleCString];
   if( s)
   {
      if( *s == 'T')
         vAlign = MulleTextVerticalAlignmentTop;
      else
         if( s && *s == 'B')
         {
            if( s[ 1] == 'a')
               vAlign = MulleTextVerticalAlignmentBaseline;
            else
               if( s[ 2] == 'u')
                  vAlign = MulleTextVerticalAlignmentBoundsMiddle;
               else
                  vAlign = MulleTextVerticalAlignmentBottom;
         }
         else
            vAlign = MulleTextVerticalAlignmentMiddle;

      [control setTitleCString:s];
   }
   return( nil);
}


static void   willAnimateCallback( UIWindow *window,
                                   CGContext *context,
                                   struct MulleFrameInfo *info,
                                   CAAbsoluteTime now)
{
   UIView                  *views[ 10];
   UILabel                 *label;
   MulleWindowPlane        *plane;
   static CAAbsoluteTime   last;
   NSUInteger              i, n;
   char                    *s;
   CGFloat                 bounds[4];

   plane = [window contentPlane];
   n     = [plane getSubviews:views
                       length:10];

   for( i = 0; i < n; i++)
   {
      if( ! [views[ i] respondsToSelector:@selector( setAlignmentMode:)])
         continue;

      label = (UILabel *) views[ i];
      if( [label debugNameCString] && *[label debugNameCString] == 'i')
      {
         [one  getFontTextBounds:bounds];

         s = MulleObjC_asprintf( "H Align   : %s\n"
                                 "V Align   : %s\n"
                                 "Ascender  : %.1f\n"
                                 "Descender : %.1f\n"
                                 "Height    : %.1f\n"
                                 "Bounds[ 1]: %.1f\n"
                                 "Bounds[ 3]: %.1f\n",
               CATextLayerAlignmentModeCStringDescription( hAlign),
               MulleTextLayerVerticalAlignmentModeCStringDescription( vAlign),
               [one fontAscender],
               [one fontDescender],
               [one fontLineHeight],
               bounds[ 1],
               bounds[ 3]);

         [label setCString:s];
         continue;
      }

      [label setAlignmentMode:hAlign];
      [label mulleSetVerticalAlignmentMode:vAlign];
   }
}

/*
   MULLE_TESTALLOCATOR_TRACE=3
   MULLE_TEST_ALLOCATOR=YES
   MULLE_OBJC_TRACE_UNIVERSE=YES
   MULLE_OBJC_TRACE_METHOD_CALL=YES
   MULLE_OBJC_TRACE_INSTANCE=YES
   MULLE_OBJC_PEDANTIC_EXIT=YES
*/

int   main()
{
   CGRect             frame;
   CGContext          *context;
   UIWindow           *window;
   UILabel            *label;
   UIApplication      *application;
   UIView             *contentView;
   MullePopUpButton   *button;

   /*
   * window and app
   */
   window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 800.0, 600.0)] autorelease];
   assert( window);

   [[UIApplication sharedInstance] addWindow:window];

   contentView = [window contentPlane];

   context = [[CGContext new] autorelease];
   [context setBackgroundColor:CGColorCreateGenericRGB( 1.0, 1.0, 1.0, 1.0)];

   /* singleline Label */
   {
      frame.size.width  = 700;
      frame.size.height = 80+20;
      frame.origin.x    = (800.0 - frame.size.width ) / 2.0;
      frame.origin.y    = 50;

      label = [UILabel mulleViewWithFrame:frame];
      [label setDebugNameCString:"one"];
      [label setBackgroundColor:[UIColor lightGrayColor]];
      [label setCString:"Text on one line"];
      // TODO: this is apparently ignored!!! why ?? (because the prototype
      //       was missing!)
      [label setFontPixelSize:80.0];
      [label setAlignmentMode:CAAlignmentLeft];

      one = label;
      [contentView addSubview:label];
   }

   /* simple Label */
   {
      frame.origin.y   += frame.size.height + 50;
      frame.size.height = 80+80+20;

      label = [UILabel mulleViewWithFrame:frame];
      [label setDebugNameCString:"three"];
      [label setBackgroundColor:[UIColor lightGrayColor]];
      [label setCString:"Text 1 on three lynes\nText 2 on three lynes\nText3 on three lines"];
      // TODO: this is apparently ignored!!! why ?? (because the prototype
      //       was missing!)
      [label setFontPixelSize:80.0];
      [label setAlignmentMode:CAAlignmentLeft];

      [contentView addSubview:label];
   }

   /* info label */
   {
      frame.origin.y   += frame.size.height + 50;
      frame.size.height = 80+10;

      label = [UILabel mulleViewWithFrame:frame];
      [label setDebugNameCString:"info"];
      [label setBackgroundColor:[UIColor lightGrayColor]];
      [label setCString:"Info"];
      // TODO: this is apparently ignored!!! why ?? (because the prototype
      //       was missing!)
      [label setFontPixelSize:10.0];
      [label setAlignmentMode:CAAlignmentLeft];
      [label mulleSetVerticalAlignmentMode:MulleTextVerticalAlignmentBaseline];
      [contentView addSubview:label];
   }

   {
      button = [MullePopUpButton mulleViewWithFrame:CGRectMake( 0, 0, 120, 20)];
      [button setTitleCString:"Horizontal"];
      [button setMargins:UIEdgeInsetsMake( 10, 10, 10, 10)];
      [button setAutoresizingMask:MulleUIViewAutoresizingStickToTop|MulleUIViewAutoresizingStickToLeft];
      [button setClick:hButtonClicked];
      // not strdupped currently!
      [button setTitlesCStrings:hTitles
                           count:sizeof( hTitles) / sizeof( char *)];
      [contentView addSubview:button];


      button = [MullePopUpButton mulleViewWithFrame:CGRectMake( 0, 0, 120, 20)];
      [button setTitleCString:"Vertical"];
      [button setMargins:UIEdgeInsetsMake( 10, 10, 10, 10)];
      [button setAutoresizingMask:MulleUIViewAutoresizingStickToTop|MulleUIViewAutoresizingStickToRight];
      [button setClick:vButtonClicked];
      // not strdupped currently!
      [button setTitlesCStrings:vTitles
                           count:sizeof( vTitles) / sizeof( char *)];
      [contentView addSubview:button];
   }
   [window dump];
   [window setWillLayoutCallback:willAnimateCallback];

   [window renderLoopWithContext:context];

   [[UIApplication sharedInstance] terminate];

   fprintf( stderr, "bye bye\n");
}

