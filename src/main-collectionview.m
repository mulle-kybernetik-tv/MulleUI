#import "import-private.h"

#import "CALayer.h"
#import "CGBase.h"
#import "CGColor+MulleObjC.h"
#import "CGContext.h"
#import "CGGeometry.h"
#import "CGGeometry+CString.h"
#import "CGGeometry+MulleObjC.h"
#import "NSIndexPath.h"
#import "UIApplication.h"
#import "UIButton.h"
#import "UICollectionView.h"
#import "UICollectionViewCell.h"
#import "UIColor.h"
#import "UIEdgeInsets.h"
#import "UIFont.h"
#import "UILabel.h"
#import "UIView.h"
#import "UIView+CAAnimation.h"
#import "UIWindow.h"

#include <string.h>


// scale stuff for stream
#define SCALE     2.0


@interface TextCollectionViewCell : UICollectionViewCell 

@property( assign) UILabel  *label;

@end


@implementation TextCollectionViewCell 

- (id) initWithFrame:(CGRect) frame 
{
    if((self = [super initWithFrame:frame])) 
    {
        _label = [[UILabel alloc] initWithFrame:frame];
        [_label setMargins:UIEdgeInsetsMake( 3, 3, 3, 3)];
        [_label setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [_label setTextAlignment:UITextAlignmentCenter];
        [_label setFont:[UIFont boldSystemFontOfSize:40.0]];
        [_label setBackgroundColor:[UIColor underPageBackgroundColor]];
        [_label setTextColor:[UIColor blackColor]];

        [[self contentView] addSubview:_label];
        
    }
    return self;
}

@end



@interface DataSource : NSObject < UICollectionViewDataSource>

@property( retain) NSArray   *objects;

@end


@implementation DataSource

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
   return( 1);
}


- (NSInteger) collectionView:(UICollectionView *)collectionView 
      numberOfItemsInSection:(NSInteger) section
{
   assert( section == 0);
   return( [_objects count]);
}

- (UICollectionViewCell *) collectionView:(UICollectionView *) collectionView 
                   cellForItemAtIndexPath:(NSIndexPath *) indexPath
{
   TextCollectionViewCell   *cell;
   NSUInteger               row;
   id                       obj;
   char                     buf[ 64];

   cell = (TextCollectionViewCell *) 
            [collectionView dequeueReusableCellWithReuseIdentifier:@"whatever"
                                                      forIndexPath:indexPath];
   NSParameterAssert( [cell isKindOfClass:[TextCollectionViewCell class]]);

   row = [indexPath row];
   obj = [_objects objectAtIndex:row];
   [[cell label] setCString:[[obj description] UTF8String]];
   [cell setBackgroundColor:[UIColor redColor]];

   sprintf( buf, "Cell %lu.%lu", 
                  (unsigned long) [indexPath section],
                  (unsigned long) [indexPath item]);
   [cell setCStringName:buf];
   return( cell);
}

@end


static void   setupDataSource( DataSource *dataSource)
{
   [dataSource setObjects:@[ @"VfL", @"Bochum", @"1848"]];
}


static UICollectionView   *collectionView;


static UIEvent   *add_button_callback( UIButton *button, UIEvent *event)
{
   DataSource *dataSource;
   NSArray    *array;

   fprintf( stderr, "add_button_callback: %s\n", [button cStringDescription]);

   dataSource = (DataSource *) [collectionView dataSource];

   array = [dataSource objects];
   array = [array arrayByAddingObject:@"Tour de France"];
   [dataSource setObjects:array];

   [collectionView reloadData];
   return( nil);
}


static UIEvent   *remove_button_callback( UIButton *button, UIEvent *event)
{
   DataSource       *dataSource;
   NSMutableArray   *objects;
   NSArray          *indexes;
   NSIndexPath      *indexPath;
   NSEnumerator     *rover;
   NSUInteger       item;

   fprintf( stderr, "remove_button_callback: %s\n", [button cStringDescription]);

   dataSource = (DataSource *) [collectionView dataSource];

   objects = [NSMutableArray arrayWithArray:[dataSource objects]];

   indexes = [collectionView indexPathsForSelectedItems];
   indexes = [indexes sortedArrayUsingSelector:@selector( compare:)];
  
   rover = [indexes reverseObjectEnumerator];
   while( indexPath = [rover nextObject])
   {
      NSCParameterAssert( [indexPath isKindOfClass:[NSIndexPath class]]);
      
      item = [indexPath item];
      [objects removeObjectAtIndex:item];
   }
   [dataSource setObjects:objects];

   [collectionView reloadData];
   return( nil);
}

static void   setupSceneInContentPlane( MulleWindowPlane *contentPlane)
{
   CGRect             frame;
   CGRect             rect;
   NSInteger          i;
   UIButton           *uiButton;
   UIView             *contentView;
   UIView             *view;
   DataSource         *dataSource;

   frame = [contentPlane frame];

   frame.size.height -= 100;

   // global collectionView
   collectionView = [[[UICollectionView alloc] initWithFrame:frame] autorelease];
   [collectionView setContentSize:CGSizeMake( frame.size.width, frame.size.height)];
   [collectionView setItemSize:CGSizeMake( 350, 80)];
   [contentPlane addSubview:collectionView];
   
   contentView = [collectionView contentView];

   dataSource  = [DataSource object];
   setupDataSource( dataSource);

   [collectionView registerClass:[TextCollectionViewCell class]
      forCellWithReuseIdentifier:@"whatever"];
   [collectionView setDataSource:dataSource];
   [collectionView reloadData];

   frame.origin.x   += 10;
   frame.origin.y   += frame.size.height + 10;
   frame.size.width  = 120;
   frame.size.height = 44;

   uiButton = [[[UIButton alloc] initWithFrame:frame] autorelease];
   [uiButton setTitleCString:"Add"];
   [uiButton setClick:add_button_callback];
   [contentPlane addSubview:uiButton];

   frame.origin.x   += frame.size.width + 10;

   uiButton = [[[UIButton alloc] initWithFrame:frame] autorelease];
   [uiButton setTitleCString:"Remove"];
   [uiButton setClick:remove_button_callback];
   [contentPlane addSubview:uiButton];
/*
   for( i = 0; i < 1000; i++)
   {
      rect.origin.x = rand() % ((int) frame.size.width - 64);
      rect.origin.y = rand() % ((int) 4000 - 64);
      rect.size     = CGSizeMake( 64, 64);
      view  = [[[UIView alloc] initWithFrame:rect] autorelease];
      [view setBackgroundColor:MulleColorCreateRandom( 0x00FF00FF, 0xFF00FF00)];
      [contentView addSubview:view];
   }
*/
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

