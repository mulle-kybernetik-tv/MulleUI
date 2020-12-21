#import "import-private.h"

#import "MulleSVGLayer.h"

#import "MulleSVGImage.h"
#import "CGContext.h"

#import "nanovg.h"
#import "nanosvg.h"


static NVGcolor getSVGColor(uint32_t color) 
{
	return nvgRGBA(
		(color >> 0) & 0xff,
		(color >> 8) & 0xff,
		(color >> 16) & 0xff,
		(color >> 24) & 0xff);
}


@implementation MulleSVGImage( MulleSVGLayer)

- (Class) preferredLayerClass
{
	return( [MulleSVGLayer class]);
}

@end


@implementation MulleSVGLayer

- (instancetype) initWithSVGImage:(MulleSVGImage *) image
{
	assert( ! image || [image isKindOfClass:[MulleSVGImage class]]);
	
   if( ! (self = [super init]))
      return( self);
   
   _image          = [image retain];  // ownership transfer

   _bounds         = [_image visibleBounds];
   _offset.x       = -_bounds.origin.x;
   _offset.y       = -_bounds.origin.y;
   _bounds.origin  = CGPointMake( 0.0f, 0.0f);
   _selectionColor = MulleColorCreate( 0x7FFF7F7F);

   return( self);
}


- (instancetype) initWithImage:(UIImage *) image
{
	if( image && ! [image isKindOfClass:[MulleSVGImage class]])
   {
      [self release];
      return( self);
   }
	
   return( [self initWithSVGImage:(MulleSVGImage *) image]);
}


- (BOOL) drawContentsInContext:(CGContext *) context
{
   NSVGimage     *image;
	NSVGshape     *shape;
	NSVGpath      *path;
   CGColorRef    color;

   int           i;
	float         *p;
   CGPoint       scale;
   NVGcontext    *vg;
   CGRect        frame;
   CGRect        rect;

   image = [(MulleSVGImage *) _image NSVGImage];
   if ( ! image)
      return( NO);

   vg    = [context nvgContext];
  
   frame = [self frame];
 
   nvgTranslate( vg, frame.origin.x, frame.origin.y);
   nvgTranslate( vg, 0 /* -_offset.x */, _offset.y); /// hacked to negative
   nvgBezierTessellation( vg, NVG_TESS_AFD); // patched nanovg function

   for( shape = image->shapes; shape != NULL; shape = shape->next) 
	{
	   if( ! (shape->flags & NSVG_FLAGS_VISIBLE))
   	   continue;

	   nvgStrokeWidth( vg, shape->strokeWidth);

      color = getSVGColor( shape->fill.color);
      if( _selected)
         color = CGColorDim( color, 0.5);
	   nvgFillColor( vg, color);
      
      color = getSVGColor( shape->stroke.color);
      if( _selected)
         color = CGColorDim( color, 0.5);
	   nvgStrokeColor( vg, color);

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

   if( _selected)
   {
      rect = [_image visibleBounds];

      // MEMO: wenn man den nvgBeginPath weglaesst, dann klippt das rect gegen
      // den letzten shape, was ev. ganz nuetzlich mal sein kann.
		nvgBeginPath( vg);
      nvgRect( vg, rect.origin.x,
                   rect.origin.y,
                   rect.size.width,
                   rect.size.height);

  	   nvgFillColor( vg, _selectionColor);
	   nvgFill( vg);
   }
   return( YES);
}

- (CGRect) visibleBounds
{
   CGRect   bounds;

   bounds = [_image visibleBounds];
   return( bounds);
}


- (void) getCursorPosition:(struct MulleIntegerPoint *) p_point
{
   p_point->x = _image ? 1 : 0;
   p_point->y = 0;
}


- (NSUInteger) characterIndexForPoint:(CGPoint) point
{
   // TODO: HACK!!!
   return( _image ? 1 : 0);
}


- (struct MulleIntegerPoint) cursorPositionForPoint:(CGPoint) mouseLocation
{
   // TODO: HACK!!!
   return( MulleIntegerPointMake( _image ? 1 : 0, 0));
}

- (CGFloat) offsetNeededToMakeCursorVisible
{
   return( 0.0);
}

- (struct MulleIntegerPoint) maxCursorPosition
{
   return( MulleIntegerPointMake( _image ? 1 : 0, 0));
}


@end
