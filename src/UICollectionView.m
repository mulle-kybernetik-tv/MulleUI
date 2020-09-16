//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UICollectionView.h"

#import "import-private.h"

#import "NSIndexPath.h"
#import "NSMutableIndexSet.h"
#import "UICollectionViewCell.h"
#import "UIStackView.h"
#import "mulle-pointerarray+ObjC.h"


@implementation UICollectionView

// UICollectionView wants to use a different view here
+ (UIView *) mulleScrollContentsViewWithFrame:(CGRect) frame
{
   UIStackView   *view;
   CGFloat       minimumInteritemSpacing; 
   CGFloat       minimumLineSpacing;

   view = [[[UIStackView alloc] initWithFrame:frame] autorelease];
   [view setCStringName:"ScrollViewContentStackView"];
   [view setDistribution:MulleStackViewDistributionFillRowColumn];
   [view setAxis:UILayoutConstraintAxisHorizontal];

   minimumLineSpacing      = [view minimumLineSpacing];
   minimumInteritemSpacing = [view minimumInteritemSpacing];

   // T  L  B  R  : how is with insets
   // L  T  R  B  : how i think it is, because of CGRect
   // T  R  B  L  : clockwise would be cool 
   [view setContentInsets:UIEdgeInsetsMake( minimumLineSpacing, 
                                            minimumInteritemSpacing, 
                                            minimumLineSpacing, 
                                            minimumInteritemSpacing)];
   return( view);
}


- (instancetype) initWithLayer:(CALayer *) layer 
{
   self = [super initWithLayer:layer];
   if( self)
      _itemSize = CGSizeMake( 50, 50);   
   return( self);
}


- (void) finalize
{
   [self removeAllCells];  // also set delegate of cells to nil

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

   [cell setDelegate:nil];

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
      cell = [[[cellClass alloc] initWithFrame:CGRectZero] autorelease];
   }

   // fill cell with default info
   frame.origin = CGPointMake( 0, 0);
   frame.size   = [self itemSize];
   [cell setFrame:frame];
   
   return( cell);
}
    

// TODO: move this elsewhere ??
- (void) removeAllCells
{
   struct mulle_pointerarrayenumerator   rover;
   UIView                                *view;
   UIView                                *contentView;

   contentView = [self contentView];

   rover = mulle_pointerarray_enumerate( contentView->_subviews);
   while( _mulle_pointerarrayenumerator_next( &rover, (void **) &view))
   {
      assert( [view isKindOfClass:[UICollectionViewCell class]]);
      [self discardCell:(UICollectionViewCell *) view];
   }
   mulle_pointerarrayenumerator_done( &rover);

   // clean all subviews out now
   mulle_pointerarray_release_all( contentView->_subviews);
   mulle_pointerarray_reset( contentView->_subviews);    
}



- (void) _setSelectedIndexPath:(NSIndexPath *) indexPath 
{
   if( ! _selectedIndexes)
      _selectedIndexes = [NSMutableSet new];
   [_selectedIndexes addObject:indexPath];
}

- (void) _removeSelectedIndexPath:(NSIndexPath *) indexPath 
{
   [_selectedIndexes removeObject:indexPath];   
}


- (void) reloadData
{
   NSUInteger             nSections;
   NSUInteger             nItems;
   NSUInteger             section;
   NSUInteger             item;
   NSIndexPath            *indexPath;
   UIView                 *contentView;
   UICollectionViewCell   *cell;
   
   [self removeAllCells];

   contentView = [self contentView];

   [_selectedIndexes removeAllObjects];

   /* ask datasource */
   nSections = [_dataSource numberOfSectionsInCollectionView:self];
   assert( nSections <= 1);
   for( section = 0; section < nSections; section++)
   {
      nItems = [_dataSource collectionView:self
                    numberOfItemsInSection:section];
      for( item = 0; item < nItems; item++)
      {
         // terrible, can we live without these ephemeral mallocs somehow ?
         indexPath = [NSIndexPath indexPathForItem:item
                                         inSection:section];

         cell = [_dataSource collectionView:self
                     cellForItemAtIndexPath:indexPath];
         [cell setDelegate:self];
         [cell setIndexPath:indexPath];
         if( [cell isSelected])
            [self _setSelectedIndexPath:indexPath];
         
         [contentView addSubview:cell];
      }
   }
   [contentView setNeedsLayout];
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
#if 0
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
#endif   
}


- (NSArray *) indexPathsForSelectedItems
{
   if( !_selectedIndexes)
      return( nil); // by spec
   // lets return these sorted
   return( [_selectedIndexes allObjects]);
}


- (NSIndexPath *) indexPathForCell:(UICollectionViewCell *) cell
{
   return( [cell indexPath]);
}


- (void)       cell:(UICollectionViewCell *) cell
   didChangeStateTo:(UIControlState) state 
          fromState:(UIControlState) oldState
{
   NSIndexPath   *indexPath;

   if( (state & UIControlStateSelected) == (oldState & UIControlStateSelected))
      return;

   indexPath = [self indexPathForCell:cell];
   if( state & UIControlStateSelected)
      [self _setSelectedIndexPath:indexPath];
   else
      [self _removeSelectedIndexPath:indexPath];
}


@end
