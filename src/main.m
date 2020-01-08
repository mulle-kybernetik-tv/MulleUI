#import "import-private.h"

#import "CGContext.h"
#import "CGGeometry+CString.h"
#import "CALayer.h"
#import "CAAnimation.h"
#import "PSTCollectionView.h"
#import "PSTCollectionViewCell.h"
#import "MulleBitmapImage.h"
#import "MulleImageLayer.h"
#import "MulleSVGImage.h"
#import "MulleSVGLayer.h"

#import "UIColor.h"
#import "UIFont.h"

#import "UIApplication.h"
#import "UIButton.h"
#import "UIView+Yoga.h"
#import "UIScrollView.h"
#import "UIEvent.h"
#import "UILabel.h"
#import "UIScrollView.h"
#import "UISegmentedControl.h"
#import "UISlider.h"
#import "UIStepper.h"
#import "UISwitch.h"
#import "UIView+CAAnimation.h"
#import "UIWindow.h"
#import <string.h>


//	stolen from catgl ©2015,2018 Yuichiro Nakada
#define W  320
#define H  200

#include "Ghostscript_Tiger-svg.inc"
#include "sealie-bitmap.inc"
#include "turtle-bitmap.inc"
#include "viech-bitmap.inc"

#if 0
static char   svginput[] = \
"<svg version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\">\n"
"   <rect x=\"100\" y=\"50\" width=\"200\" height=\"100\" stroke=\"#c04949\" stroke-linejoin=\"round\" stroke-width=\"5.265\"/>\n"
"</svg>\n"
"\n"
;
#endif


@interface Cell : PSTCollectionViewCell

@property( assign) UILabel *   label;

@end


@implementation Cell

- (id) initWithFrame:(CGRect) frame 
{
    if ((self = [super initWithFrame:frame])) 
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        [label setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [label setTextAlignment:UITextAlignmentCenter];
        [label setFont:[UIFont boldSystemFontOfSize:50.0]];
        [label setBackgroundColor:[UIColor underPageBackgroundColor]];
        [label setTextColor:[UIColor blackColor]];

        [[self contentView] addSubview:label];
        _label = label;
    }
    return self;
}


#pragma mark - PSTCollectionViewDataSource

+ (NSInteger) collectionView:(PSTCollectionView *) view 
      numberOfItemsInSection:(NSInteger) section 
{
   if( section == 0)
      return 2;
   return( 0);
}

#pragma mark - PSTCollectionViewDelegate

+ (PSTCollectionViewCell *) collectionView:(PSTCollectionView *) collectionView 
                    cellForItemAtIndexPath:(NSIndexPath *)indexPath 
{
   char   buf[ 128];
   static int  count;

    Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" 
                                                           forIndexPath:indexPath];
    sprintf( buf, "what--%d", count++);
    [[cell label] setCString:buf];
    return cell;
}

#pragma mark - PSTCollectionViewDelegateFlowLayout

+ (CGSize) collectionView:(PSTCollectionView *) collectionView 
                   layout:(PSTCollectionViewLayout*)collectionViewLayout 
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath 
{
    return CGSizeMake(200, 40);
}

+ (CGFloat)collectionView:(PSTCollectionView *)collectionView 
                   layout:(PSTCollectionViewLayout*) collectionViewLayout 
                   minimumInteritemSpacingForSectionAtIndex:(NSInteger)section 
{
    return 4;
}

+ (CGFloat) collectionView:(PSTCollectionView *) collectionView 
                    layout:(PSTCollectionViewLayout*)collectionViewLayout 
minimumLineSpacingForSectionAtIndex:(NSInteger)section 
{
    return 10;
}

@end


@interface UIWindow( Debug)

- (void) dump;

@end


static UIEvent   *button_callback( UIButton *button, UIEvent *event)
{
   fprintf( stderr, "button_callback: %s\n", [button cStringDescription]);
   return( nil);
}


static UIEvent   *scroll_callback( UIButton *button, UIEvent *event)
{
   UIScrollView   *scroller;
   CGPoint        offset;

   fprintf( stderr, "scroll_callback: %s\n", [button cStringDescription]);

   scroller = (UIScrollView *) [[button superview] superview];
   assert( [scroller isKindOfClass:[UIScrollView class]]);

   offset    = [scroller contentOffset];
   offset.y += 10;
   [scroller setContentOffset:offset];

   return( nil);
}


@implementation UIView( MouseMotion)

- (UIEvent *) mouseDragged:(UIEvent *) event 
{
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, CGPointCStringDescription( [event mousePosition]));
   return( nil);
}

- (UIEvent *) mouseEntered:(UIEvent *) event 
{
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, CGPointCStringDescription( [event mousePosition]));
   return( nil);
}

- (UIEvent *) mouseMoved:(UIEvent *) event 
{
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, CGPointCStringDescription( [event mousePosition]));
   return( nil);
}

- (UIEvent *) mouseExited:(UIEvent *) event 
{
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, CGPointCStringDescription( [event mousePosition]));
   return( nil);
}

@end


// scale stuff for stream
#define SCALE     2.0


static void   setupSceneInWindow( UIWindow *window)
{
   PSTCollectionView            *root;
   PSTCollectionViewFlowLayout   *layout;
   CGRect                        frame;

   frame = [window bounds];
   assert( frame.size.width > 0.0);
   assert( frame.size.height > 0.0);

   frame.origin.x    += 150;
   frame.origin.y    += 50;
   frame.size.width  -= 200;
   frame.size.height -= 100;

   layout = [[PSTCollectionViewFlowLayout new] autorelease];;
   root   = [[[PSTCollectionView alloc] initWithFrame:frame
                                 collectionViewLayout:layout] autorelease];
   [[root layer] setBackgroundColor:getNVGColor( 0xFF0000FF)]; // red
   [[root layer] setCStringName:"root"];
  
   [root registerClass:[Cell class] forCellWithReuseIdentifier:@"MY_CELL"];
   [root setDataSource:[Cell class]];
   [root setDelegate:[Cell class]];

   [window addSubview:root];

   [root reloadData];

}


int  main()
{
   CGContext       *context;
   UIApplication   *application;
   UIWindow        *window;

   /* 
    * window and app 
    */
   window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, W * SCALE, H * SCALE)] autorelease];
   assert( window);

   application = [UIApplication sharedInstance];
   [application addWindow:window];

   setupSceneInWindow( window);
   /*
    * view placement in window 
    */

   [window dump];

   context = [[CGContext new] autorelease];
   [window renderLoopWithContext:context];

   [application terminate];
}

