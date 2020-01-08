#import "MulleSegmentedControlLayer.h"

#import "CGContext.h"
#import "CGFont.h"


@implementation MulleSegmentedControlLayer : CALayer


- (void) setFontName:(char *) s
{
   MulleObjCObjectSetDuplicatedCString( self, &_fontName, s);
}

- (void) dealloc
{
   struct mulle_allocator   *allocator;
   NSUInteger               i;

   MulleObjCObjectDeallocateMemory( self, &_fontName);

   allocator = MulleObjCObjectGetAllocator( self);

   for( i = _n; i;)
      mulle_allocator_free( allocator, self->_titles[ --i]);
   mulle_allocator_free( allocator, self->_titles);
   [super dealloc];
}


- (NSUInteger) numberOfSegments
{
   return( self->_n);
}

- (void) insertSegmentWithCString:(char *) title 
                          atIndex:(NSUInteger) segment 
                         animated:(BOOL )animated
{
   NSUInteger               size;
   struct mulle_allocator   *allocator;

   allocator = MulleObjCObjectGetAllocator( self);
   if( segment > _n)
      segment = _n;

   size = self->_size;
   if( self->_n + 1 > size)
   {
      size = size * 2;
      if( size < 4)
         size = 4;

      self->_titles = mulle_allocator_realloc( allocator,
                                               self->_titles,
                                               size * sizeof( char *));
      self->_size = size;
   }

   memmove( &self->_titles[ segment + 1], 
            &self->_titles[ segment], 
            (self->_n - segment) * sizeof( char *));

   self->_titles[ segment] = mulle_allocator_strdup( allocator, title); 
   self->_n++;
}                         


- (void) drawContentsInContext:(CGContext *) context
{
   CGFloat             fontPixelSize;
   CGFloat             midX;
   CGFloat             strokeWidth;
   CGFont              *font;
   CGRect              frame;
   CGRect              segmentFrame;
   CGRect              innerFrame;
   CGRect              frame2;
   char                *name;
   struct NVGcontext   *vg;
   NSUInteger          i;

   vg    = [context nvgContext];
   frame = [self frame];

   strokeWidth = 2.0;

   // calculate inner frames without surrounding box/border/divider
   innerFrame.origin.x    = frame.origin.x + strokeWidth;
   innerFrame.origin.y    = frame.origin.y + strokeWidth;
   innerFrame.size.height = frame.size.height - strokeWidth * 2;;
   if( _n >= 2 )
      innerFrame.size.width  = (frame.size.width - strokeWidth * (_n - 1)) / _n - strokeWidth;
   else
      innerFrame.size.width  = frame.size.width - strokeWidth * 2;
                                       
   // draw surrounding box and the dividers
   nvgBeginPath( vg);
   nvgRoundedRect( vg, frame.origin.x, 
                       frame.origin.y, 
                       frame.size.width - strokeWidth, 
                       frame.size.height - strokeWidth, 
                       2.0);

   for( i = 1; i < _n; i++)
   {
      midX  = innerFrame.origin.x;
      midX += innerFrame.size.width + strokeWidth / 2.0;
      midX += (innerFrame.size.width + strokeWidth) * (i - 1);
      nvgMoveTo( vg, midX, frame.origin.y);
      nvgLineTo( vg, midX, frame.origin.y + frame.size.height - 1.0);
   }
   nvgStrokeColor( vg, nvgRGBA(127,127,255,255));
   nvgStrokeWidth( vg, (int) strokeWidth);
   nvgStroke( vg);
 
   // draw text labels in each segment

   font = [context fontWithName:_fontName ? _fontName : "sans"];
   name = [font name];  // get actual name, which could have different address

   fontPixelSize = [self fontPixelSize];
   if( fontPixelSize == 0.0)
      fontPixelSize = innerFrame.size.height;

	nvgFontSize( vg, fontPixelSize);
	nvgFontFace( vg, name);
   nvgTextColor( vg, nvgRGBA(255,255,255,255), [self backgroundColor]); // TODO: use textColor
   nvgTextAlign( vg,NVG_ALIGN_CENTER|NVG_ALIGN_MIDDLE);

   segmentFrame = innerFrame;
   for( i = 0; i < _n; i++)
   {
      segmentFrame.origin.x  = innerFrame.origin.x;
      if( i >= 1)
      {
         segmentFrame.origin.x += innerFrame.size.width + strokeWidth / 2.0;
         segmentFrame.origin.x += (innerFrame.size.width + strokeWidth) * (i - 1);
      }

   	nvgText( vg, segmentFrame.origin.x + segmentFrame.size.width / 2.0, 
                   segmentFrame.origin.y + segmentFrame.size.height *0.5f, 
                   _titles[ i], NULL);
   }
}

@end
