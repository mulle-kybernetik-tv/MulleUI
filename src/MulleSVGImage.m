#import "import-private.h"

#import "MulleSVGImage.h"

#import "nanovg.h"
#import "nanosvg.h"
#import <errno.h>
#import <stdio.h>

/*
 * the nsvg parser modifies the data and needs a trailing zero.
 * SVG text read from a file will not have this zero. Also for
 * UITextView we want to keep the SVG text intact. Therefore
 * always operate on a copy of the incoming data for parsing
 */
@implementation MulleSVGImage


- (instancetype) initWithNSVGImage:(struct NSVGimage *) image
                         mulleData:(struct mulle_data) data
                         allocator:(struct mulle_allocator *) allocator
{
   if( ! image)
   {
      [self release];
      return( nil);
   }

   self = [super initWithMulleData:data
                         allocator:allocator];
   assert( self);
   
   _NSVGImage = image;  // ownership transfer
   return( self);
}


- (instancetype) initWithMulleData:(struct mulle_data) data
                         allocator:(struct mulle_allocator *) allocator
{	
   NSVGimage   *image;
   BOOL        hasZero;
   char        *tmp;

   if( ! data.bytes || ! data.length)
   {
      errno = EINVAL;
      return( nil);
   }

   // must be 0 terminated
   hasZero = ! ((char *) data.bytes)[ data.length - 1];

   tmp = mulle_malloc( data.length + (hasZero ? 0 : 1));
   memcpy( tmp, data.bytes, data.length);
   if( ! hasZero)
      tmp[ data.length] = 0;

   image = nsvgParse( tmp, "px", 96.0);
   mulle_free( tmp);

   self = [self initWithNSVGImage:image
                        mulleData:data
                        allocator:allocator];
   return( self);
}


- (struct NSVGimage *) NSVGImage
{
   return( _NSVGImage);
}


- (void) dealloc
{
   nsvgDelete( _NSVGImage);
   if( _fileDataAllocator)
      mulle_allocator_free( _fileDataAllocator, _fileData.bytes);	
   [super dealloc];
}


- (CGSize) size
{
   CGSize   size;

   size.width  = _NSVGImage->width;
   size.height = _NSVGImage->height;

#if DEBUG
   fprintf( stderr, "%s size= %.1f,%.1f\n", 
                     __PRETTY_FUNCTION__,
                     size.width,
                     size.height);
#endif                        
   return( size);  
}


- (CGRect) visibleBounds
{
	NSVGshape  *shape;
   CGRect     bounds;
   CGRect     box;
   CGFloat    overdraw;

   bounds = CGRectNull;
	for( shape = _NSVGImage->shapes; shape != NULL; shape = shape->next) 
	{
	   if( ! (shape->flags & NSVG_FLAGS_VISIBLE))
   	   continue;

      overdraw        = shape->strokeWidth / 2.0;
      box.origin.x    = shape->bounds[ 0] - overdraw;
      box.origin.y    = shape->bounds[ 1] - overdraw;
      box.size.width  = shape->bounds[ 2] - shape->bounds[ 0] + 1 + shape->strokeWidth;
      box.size.height = shape->bounds[ 3] - shape->bounds[ 1] + 1 + shape->strokeWidth;
#if 0
      fprintf( stderr, "+ %.1f,%.1f,%.1f,%.1f\n", 
                        box.origin.x,
                        box.origin.y,
                        box.size.width,
                        box.size.height);
#endif                        
      bounds = CGRectUnion( bounds, box);
   }
#if 0   
   fprintf( stderr, "visibleBounds= %.1f,%.1f,%.1f,%.1f\n", 
                     bounds.origin.x,
                     bounds.origin.y,
                     bounds.size.width,
                     bounds.size.height);
#endif                     
   return( bounds);
}

@end
