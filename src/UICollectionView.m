//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UICollectionView.h"

#import "import-private.h"

#import "NSIndexPath.h"
#import "UICollectionViewCell.h"
#import "mulle-pointerarray+ObjC.h"


@implementation UICollectionView

- (void) finalize
{
  [_cellPool release];
  _cellPool = nil;

  [super finalize];
}

- (void) dealloc
{
   [_cellClassRegistry release];

   [super dealloc];
}


- (void)     registerClass:(Class) cellClass 
forCellWithReuseIdentifier:(NSString *)identifier
{
   if( ! _cellClassRegistry)
      _cellClassRegistry = [NSMutableDictionary new];

   [_cellClassRegistry setObject:cellClass
                          forKey:identifier];
}

- (void) discardCell:(UICollectionViewCell *) cell 
{
   NSMutableArray  *pool;
   NSString        *identifier;

   identifier = [cell reuseIdentifier];
   if( ! identifier)  // let it autorelease itself
      return;

   if( ! _cellPool)
      _cellPool = [NSMutableDictionary new];
   pool = [_cellPool objectForKey:identifier];
   if( ! pool)
   {
      pool = [NSMutableArray new];
      [_cellPool mulleSetRetainedObject:pool
                                 forKey:identifier];
   }
   NSParameterAssert( [pool indexOfObjectIdenticalTo:cell] == NSNotFound);

   [pool addObject:cell];
}


- (UICollectionViewCell *) 
   dequeueReusableCellWithReuseIdentifier:(NSString *) identifier 
                             forIndexPath:(NSIndexPath *) indexPath
{
   NSMutableArray        *pool;
   Class                 cellClass;
   UICollectionViewCell  *cell;
   CGRect                frame;

   pool = [_cellPool objectForKey:identifier];
   cell = [pool lastObject];
   if( cell)
   {
     [pool removeLastObject];
     [cell prepareForReuse];

     // undo some stuff
     [cell setHighlighted:NO];
     [cell setSelected:NO];
   }
   else
   {
      cellClass = [_cellClassRegistry objectForKey:identifier];
      if( ! cellClass)
         cellClass = [UICollectionViewCell class];
      cell = [[[UICollectionViewCell alloc] initWithFrame:CGRectZero] autorelease];
   }

   // fill cell with default info
   frame.origin = CGPointMake( 0, 0);
   frame.size   = [self cellSize];
   [cell setFrame:frame];
   
   return( cell);
}
    

- (void) removeAllCells
{
   struct mulle_pointerarrayenumerator   rover;
   UIView                                *view;
   
   rover = mulle_pointerarray_enumerate( _subviews);
   while( _mulle_pointerarrayenumerator_next( &rover, (void **) &view))
   {
      assert( [view isKindOfClass:[UICollectionViewCell class]]);
      [self discardCell:(UICollectionViewCell *) view];
   }
   mulle_pointerarrayenumerator_done( &rover);

   // clean all subviews out now
   mulle_pointerarray_release_all( _subviews);
   mulle_pointerarray_reset( _subviews);    
}


- (void) reloadData
{
   [self removeAllCells];
   
   /* ask datasource */
}


- (void) setContentOffset:(CGPoint) offset
{
	CGRect                                oldBounds;
	CGRect                                actualBounds;
	CGRect                                newlyVisibleRect;
   struct mulle_pointerarrayenumerator   rover;
   struct mulle_pointerarray             array;
   struct mulle_allocator                *allocator;
   CGPoint                               oldOffset;
   CGPoint                               actualOffset;
   CGPoint                               diff;

   oldBounds = [self bounds];
   oldOffset = [self contentOffset];

   [super setContentOffset:offset];

   actualOffset = [self contentOffset];
   if( CGPointEqualToPoint( oldOffset, actualOffset))
      return;

   actualBounds           = [self bounds];
   oldBounds.origin.x    += oldOffset.x;
   oldBounds.origin.y    += oldOffset.y;
   actualBounds.origin.x += actualOffset.x;
   actualBounds.origin.y += actualOffset.y;

   newlyVisibleRect = actualBounds;
   if( actualOffset.x < oldOffset.x)
   {
      // new visible space at left
      newlyVisibleRect.origin.x   = CGRectGetMinX( actualBounds);
      newlyVisibleRect.size.width = CGRectGetMinX( oldBounds) - CGRectGetMinX( actualBounds);
   }
      if( actualOffset.x > oldOffset.x)
      {
         newlyVisibleRect.origin.x   = CGRectGetMaxX( oldBounds);
         newlyVisibleRect.size.width = CGRectGetMaxX( actualBounds) - CGRectGetMaxX( oldBounds);
         // new visible space at right
      }

   if( actualOffset.y < oldOffset.y)
   {
      newlyVisibleRect.origin.y    = CGRectGetMinY( actualBounds);
      newlyVisibleRect.size.height = CGRectGetMinY( oldBounds) - CGRectGetMinY( actualBounds);
   }
   else
      if( actualOffset.y > oldOffset.y)
      {
         newlyVisibleRect.origin.y    = CGRectGetMaxY( oldBounds);
         newlyVisibleRect.size.height = CGRectGetMaxY( actualBounds) - CGRectGetMaxY( oldBounds);
      }


   fprintf( stderr, "oldBounds        : %s\n", CGRectCStringDescription( oldBounds));
   fprintf( stderr, "actualBounds     : %s\n", CGRectCStringDescription( actualBounds));
   fprintf( stderr, "newlyVisibleRect : %s\n", CGRectCStringDescription( newlyVisibleRect));

   fprintf( stderr, "oldOffset    : %s\n", CGPointCStringDescription( oldOffset));
   fprintf( stderr, "actualOffset : %s\n", CGPointCStringDescription( actualOffset));

//
//   diff.x           = oldOffset.x - actualOffset.x;
//   diff.y           = oldOffset.y - actualOffset.y;

   allocator = MulleObjCInstanceGetAllocator( self);
   _mulle_pointerarray_init( &array, 0, allocator);
   [_contentView addSubviewsIntersectingRect:actualBounds
                             toPointerArray:&array
                     invertIntersectionTest:NO];
   [_contentView setSubviews:&array];
   mulle_pointerarray_done( &array);
}

@end
