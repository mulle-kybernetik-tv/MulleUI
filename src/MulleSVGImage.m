#import "import-private.h"

#import "MulleSVGImage.h"

#import "nanovg.h"
#import "nanosvg.h"
#import <errno.h>
#import <stdio.h>


@implementation MulleSVGImage

- (instancetype) initWithBytes:(void *) bytes 
                        length:(NSUInteger) length
{	
   NSVGimage   *image;

   if( ! bytes || ! length)
   {
      errno = EINVAL;
      return( nil);
   }

   // must be 0 terminated
   if( ((char *) bytes)[ length - 1])
   {
      errno = EINVAL;
      return( nil);
   }

   image = nsvgParse( bytes, "px", 96.0);
   self = [self initWithNSVGImage:image];
   return( self);
}

- (instancetype) initWithContentsOfFileWithFileRepresentationString:(char *) s
{
   NSVGimage   *image;

	image = nsvgParseFromFile( s, "px", 96);
   self = [self initWithNSVGImage:image];
   return( self);
}


- (instancetype) initWithNSVGImage:(struct NSVGimage *) image
{
   if( ! image)
      return( nil);

   if( ! (self = [super init]))
      return( self);
   
   _NSVGImage = image;  // ownership transfer
   return( self);
}


- (struct NSVGimage *) NSVGImage
{
   return( _NSVGImage);
}


- (void) dealloc
{
   nsvgDelete( _NSVGImage);	
   [super dealloc];
}


- (CGSize) size
{
   CGSize   size;

   size.width  = _NSVGImage->width;
   size.height = _NSVGImage->height;

   fprintf( stderr, "size= %.1f,%.1f\n", 
                     size.width,
                     size.height);   
   return( size);  
}


- (CGRect) visibleBounds
{
	NSVGshape  *shape;
   CGRect     bounds;
   CGRect     box;

   bounds = CGRectNull;
	for( shape = _NSVGImage->shapes; shape != NULL; shape = shape->next) 
	{
	   if( ! (shape->flags & NSVG_FLAGS_VISIBLE))
   	   continue;

      box.origin.x    = shape->bounds[ 0];
      box.origin.y    = shape->bounds[ 1];
      box.size.width  = shape->bounds[ 2] - box.origin.x + 1;
      box.size.height = shape->bounds[ 3] - box.origin.y + 1;
#if 0
      fprintf( stderr, "+ %.1f,%.1f,%.1f,%.1f\n", 
                        box.origin.x,
                        box.origin.y,
                        box.size.width,
                        box.size.height);
#endif                        
      bounds = CGRectUnion( bounds, box);
   }
   fprintf( stderr, "visibleBounds= %.1f,%.1f,%.1f,%.1f\n", 
                     bounds.origin.x,
                     bounds.origin.y,
                     bounds.size.width,
                     bounds.size.height);
   return( bounds);
}

@end
