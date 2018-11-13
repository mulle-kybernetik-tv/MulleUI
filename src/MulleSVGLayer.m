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
   
   _SVGImage = [image retain];  // ownership transfer
   return( self);
}


- (void) drawInContext:(struct NVGcontext *) vg 
{
   NSVGimage  *image;
	NSVGshape  *shape;
	NSVGpath   *path;
	int        i;
	float      *p;
	int        shape_no;
	int        path_no;
   CGPoint    scale;
   CGRect     bounds;

   image = [_SVGImage NSVGImage];
   if ( ! image)
      return;

   if( _frame.size.width == 0.0 || _frame.size.height == 0.0)
      return;

   static struct NVGcolor  blue = { 0, 0, 0.66, 1.0 };

   bounds  = [self bounds];
   scale.x = _frame.size.width / bounds.size.width;
   scale.y = _frame.size.height / bounds.size.height;

   nvgScale( vg, scale.x, scale.y);
   nvgTranslate( vg, _frame.origin.x, 
                     _frame.origin.y);

   nvgBeginPath( vg);
   nvgMoveTo( vg, 0.0f, 0.0f);
   nvgLineTo( vg, 0.0f + bounds.size.width - 1, 0.0f);
   nvgLineTo( vg, 0.0f + bounds.size.width - 1, 0.0f + bounds.size.height - 1);
   nvgLineTo( vg, 0.0f, 0.0f + bounds.size.height - 1);
   nvgLineTo( vg, 0.0f, 0.0f);
   
   nvgFillColor( vg, blue);
   nvgFill( vg);

   nvgTranslate( vg, -bounds.origin.x, -bounds.origin.y);

	shape_no = 0;
	for( shape = image->shapes; shape != NULL; shape = shape->next) 
	{
		shape_no++;
	   if( ! (shape->flags & NSVG_FLAGS_VISIBLE))
   	   continue;

	   nvgFillColor( vg, getNVGColor( shape->fill.color));
	   nvgStrokeColor( vg, getNVGColor( shape->stroke.color));
	   nvgStrokeWidth( vg, shape->strokeWidth);

		path_no = 0;

	   for( path = shape->paths; path != NULL; path = path->next) 
	   {
			path_no++;

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
}

- (CGRect) bounds
{
   CGRect   bounds;

   bounds = [_SVGImage visibleBounds];
   return( bounds);
}

@end
