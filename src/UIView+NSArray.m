#import "UIView+NSArray.h"


#import "MulleObjectArray.h"

#pragma clang diagnostic ignored "-Wparentheses"


@interface UIView( Private)

- (struct mulle_pointerarray *) _subviews;

@end


@implementation UIView( NSArray)

static inline NSUInteger   UIViewGetIndexOfSubview( UIView *self, UIView *other)
{
   struct  mulle_pointerarrayenumerator   rover;
   NSUInteger                             i;
   UIView                                 *p;

   i     = 0;
   rover = mulle_pointerarray_enumerate( self->_subviews);
   while( _mulle_pointerarrayenumerator_next( &rover, (void **) &p))
   {
      if( p == other)
        return(i);
      ++i;
   }
   mulle_pointerarrayenumerator_done( &rover);
   return( NSNotFound);
}

- (NSArray *) subviews
{
   if( ! self->_subviews)
      return( nil);

   if( ! _subviewsArrayProxy)
      _subviewsArrayProxy = [[MulleObjectArray alloc] initWithPointerarray:self->_subviews
                                                              freeWhenDone:NO];
   return( (NSArray *) _subviewsArrayProxy);
}


void  _mulle_pointerarray_swap( struct mulle_pointerarray *array1,
                                struct mulle_pointerarray *array2)
{
   struct mulle_pointerarray   tmp;

   tmp     = *array1;
   *array1 = *array2;
   *array2 = tmp;
}


void  mulle_pointerarray_remove_at_index( struct mulle_pointerarray *array,
                                          void *item,
                                          int i)
{
   struct mulle_pointerarray   tmp;
   void                        **curr;
   void                        **deletion;
   void                        **sentinel;
   unsigned int                count;

   assert( array);

   count = mulle_pointerarray_get_count( array);
   if( i == count - 1)
   {
      _mulle_pointerarray_remove_last( array);
      return;
   }

   curr      = array->_storage;
   deletion  = &curr[ i];
   sentinel  = &curr[ count];
   if( deletion >= sentinel)
      return;

   _mulle_pointerarray_init( &tmp,
                             count - 1,
                             _mulle_pointerarray_get_allocator( array));

   // copy old over including item of insertion
   while( curr < deletion)
   {
      _mulle_pointerarray_add( &tmp, *curr++);
      curr++;
   }

   // skip ours
   curr++;

   // copy rest
   while( curr < sentinel)
   {
      _mulle_pointerarray_add( &tmp, *curr++);
      curr++;
   }

   _mulle_pointerarray_swap( array, &tmp);
   _mulle_pointerarray_done( &tmp);
}


//
// if you have 'A B C' then an insert at 1 of D will get you
// 'A D B C'
//
// Debatable! It might be nicer to have the subviews atomically switched out ?
//
void  mulle_pointerarray_insert_at_index( struct mulle_pointerarray *array,
                                          void *item,
                                          int i)
{
   struct mulle_pointerarray   tmp;
   void                        **curr;
   void                        **insertion;
   void                        **sentinel;
   unsigned int                count;

   assert( array);

   count = mulle_pointerarray_get_count( array);
   if( i == count)
   {
      _mulle_pointerarray_add( array, item);
      return;
   }

   curr      = array->_storage;
   insertion = &curr[ i];
   sentinel  = &curr[ count];
   if( insertion > sentinel)
      insertion = sentinel;

   _mulle_pointerarray_init( &tmp,
                             count + 1,
                             _mulle_pointerarray_get_allocator( array));
   // copy old over including item of insertion
   while( curr < insertion)
   {
      _mulle_pointerarray_add( &tmp, *curr++);
      curr++;
   }

   // insert ours
   _mulle_pointerarray_add( &tmp, item);

   // copy rest
   while( curr < sentinel)
   {
      _mulle_pointerarray_add( &tmp, *curr++);
      curr++;
   }

   _mulle_pointerarray_swap( array, &tmp);
   _mulle_pointerarray_done( &tmp);
}


- (void) insertSubview:(UIView *) view
               atIndex:(NSInteger) index;
{
   UIView   *superview;

   superview = [view superview];
   if( superview != self)
      [view removeFromSuperview];

   mulle_pointerarray_insert_at_index( [self _subviews], [view retain], (unsigned int) index);
}


- (void) insertSubview:(UIView *) view
          aboveSubview:(UIView *) other
{
   NSInteger   index;

   index = UIViewGetIndexOfSubview( self, other);
   if( index == NSNotFound)
      index = -1;
   [self insertSubview:view
               atIndex:index + 1];
}

- (void) insertSubview:(UIView *) view
          belowSubview:(UIView *) other
{
   NSInteger   index;

   index = UIViewGetIndexOfSubview( self, other);
   [self insertSubview:view
              atIndex:index];
}


- (void) exchangeSubviewAtIndex:(NSInteger) index1
             withSubviewAtIndex:(NSInteger) index2
{
   void           **curr;
   void           *item;
   unsigned int   count;

   count = mulle_pointerarray_get_count( _subviews);
   if( index1 >= count || index2 >= count)
      abort();

   curr          = _subviews->_storage;
   item          = curr[ index1];
   curr[ index2] = curr[ index1];
   curr[ index2] = item;
}


/*
 *
 */


void  mulle_pointerarray_move( struct mulle_pointerarray *array,
                               size_t from,
                               size_t to)
{
   struct mulle_pointerarray   tmp;
   void                        **curr;
   void                        **insertion;
   void                        **sentinel;
   size_t                      count;
   void                        *item;

   assert( array);

   count     = _mulle_pointerarray_get_count( array);
   curr      = array->_storage;
   sentinel  = &curr[ count];

   if( &curr[ from] >= sentinel || &curr[ to] >= sentinel)
      abort();
   if( &curr[ from] < curr || &curr[ to] < curr)
      abort();

   item = curr[ from];

   if( from < to)
   {
      //
      // a b c d  move  b to d
      //   *   o
      // save b
      // a X <[c d] = a c d d
      // -> a c d b
      //
      memmove( &curr[ from],
               &curr[ from + 1],
               sizeof( void *) * (sentinel - &curr[ from + 1]));
   }
   else
   {
      //
      // a b c d  move  c to a
      // o   *
      // save c
      // [a b]> X d = a a b d
      // -> c a b d
      //
      memmove( &curr[ 1],
               &curr[ 0],
               sizeof( void *) * (&curr[ from + 1] - curr));
   }

   curr[ to] = item;
}


- (void) bringSubviewToFront:(UIView *) view
{
   NSUInteger                  index;
   struct mulle_pointerarray   *array;

   index = UIViewGetIndexOfSubview( self, view);
   assert( index != NSNotFound);
   if( index == NSNotFound)
      return;

   array = [self _subviews];
   mulle_pointerarray_move( array, index, 0);
}


- (void) sendSubviewToBack:(UIView *) view
{
   NSUInteger                  index;
   unsigned int                count;
   struct mulle_pointerarray   *array;

   index = UIViewGetIndexOfSubview( self, view);
   assert( index != NSNotFound);
   if( index == NSNotFound)
      return;

   array = [self _subviews];
   count = mulle_pointerarray_get_count( array);
   mulle_pointerarray_move( array, index, count);
}

- (void) removeFromSuperview
{
   UIView       *superview;
   NSUInteger   index;

   superview = [self superview];
   if( ! superview)
      return;

   index = UIViewGetIndexOfSubview( superview, self);
   assert( index != NSNotFound);
   mulle_pointerarray_remove_at_index( [superview _subviews], [self autorelease], (unsigned int) index);
}




/*
 *
 */

- (BOOL) _isSubviewOrDescendantview:(UIView *) view
{
   struct mulle_pointerarrayenumerator   rover;
   UIView                                *candidate;

   rover = mulle_pointerarray_enumerate( _subviews);
   while( _mulle_pointerarrayenumerator_next( &rover, (void **) &candidate))
   {
      if( view == candidate)
         return( YES);
   }
   mulle_pointerarrayenumerator_done( &rover);

   rover = mulle_pointerarray_enumerate( _subviews);
   while( _mulle_pointerarrayenumerator_next( &rover, (void **) &candidate))
   {
      if( [candidate _isSubviewOrDescendantview:view])
         return( YES);
   }
   mulle_pointerarrayenumerator_done( &rover);
   return( NO);
}


- (BOOL) isDescendantOfView:(UIView *) view
{
   if( self == view)
      return( YES);
   return( [self _isSubviewOrDescendantview:view]);
}

@end

