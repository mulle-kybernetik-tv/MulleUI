#import "MulleSVGLayer.h"

#import "MulleSVGImage.h"

#import "nanovg.h"
#import "nanosvg.h"

static NVGcolor getNVGColor(uint32_t color) 
{
	return nvgRGBA(
		(color >> 0) & 0xff,
		(color >> 8) & 0xff,
		(color >> 16) & 0xff,
		(color >> 24) & 0xff);
}


@implementation MulleSVGLayer

- (instancetype) initWithSVGImage:(MulleSVGImage *) image
{
   if( ! (self = [super init]))
      return( self);
   
   _SVGImage      = [image retain];  // ownership transfer

   _bounds        = [_SVGImage visibleBounds];
   _offset.x      = -_bounds.origin.x;
   _offset.y      = -_bounds.origin.y;
   _bounds.origin = CGPointMake( 0.0f, 0.0f);

   return( self);
}


- (BOOL) drawInContext:(struct NVGcontext *) vg 
{
   NSVGimage     *image;
	NSVGshape     *shape;
	NSVGpath      *path;
   int           i;
	float         *p;
   CGPoint       scale;

   if( ! [super drawInContext:vg])
      return( NO);

   image = [_SVGImage NSVGImage];
   if ( ! image)
      return( YES);

   nvgTranslate( vg, _offset.x, _offset.y);

   for( shape = image->shapes; shape != NULL; shape = shape->next) 
	{
	   if( ! (shape->flags & NSVG_FLAGS_VISIBLE))
   	   continue;

	   nvgFillColor( vg, getNVGColor( shape->fill.color));
	   nvgStrokeColor( vg, getNVGColor( shape->stroke.color));
	   nvgStrokeWidth( vg, shape->strokeWidth);

	   for( path = shape->paths; path != NULL; path = path->next) 
	   {
			nvgBeginPath( vg);

			nvgMoveTo( vg, path->pts[0], path->pts[1]);
			for (i = 0; i < path->npts-1; i += 3) 
			{
			   p = &path->pts[i*2];
			   nvgBezierTo( vg, p[2], p[3], p[4], p[5], p[6], p[7]);
			}

			if( path->closed)
			   nvgLineTo( vg, path->pts[0], path->pts[1]);

			if( shape->fill.type)
			   nvgFill( vg);

			if( shape->stroke.type)
			   nvgStroke( vg);
	   }
	}
   return( YES);
}

- (CGRect) visibleBounds
{
   CGRect   bounds;

   bounds = [_SVGImage visibleBounds];
   return( bounds);
}

@end
