#import "UIApplication.h"

#import "import-private.h"


@implementation UIApplication

- (id) init
{
   struct mulle_allocator   *allocator;

   allocator = MulleObjCInstanceGetAllocator( self);
   mulle_array_init( &_windows,
                     2,
                     MulleObjCContainerKeyRetainCallback,
                     allocator);
   return( self);
}


- (void) dealloc
{
   mulle_array_done( &_windows);
   [super dealloc];
}


- (NSInteger) _indexOfWindow:(UIWindow *) window
{
   uintptr_t   found;

   found = mulle_array_find_in_range_identical( &_windows,
                                                window,
                                                mulle_range_make_all());

   return( found == mulle_not_found_e ? NSNotFound : (NSInteger) found);
}


- (NSInteger) getWindows:(UIWindow **) buf
                  length:(NSUInteger) length
{
   unsigned int    n;

   n = mulle_array_get_count( &_windows);
   if( length >= n)
      mulle_array_get_in_range( &_windows, mulle_range_make( 0, n), buf);
   return( n);
}


- (void) addWindow:(UIWindow *) window
{
   assert( window);
   assert( [self _indexOfWindow:window] == NSNotFound);

   mulle_array_add( &_windows, window);
}


- (void) removeWindow:(UIWindow *) window
{
   NSInteger   found;

   found = [self _indexOfWindow:window];
   if( found == NSNotFound)
      return;

   mulle_array_remove_in_range( &_windows,
                                mulle_range_make( found, 1));
}


- (void) terminate
{
   mulle_array_reset( &_windows);
   [self os_terminate];
}

@end
