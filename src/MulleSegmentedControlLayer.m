#import "MulleSegmentedControlLayer.h"

#import "CGContext.h"
#import "CGFont.h"
#import "CGGeometry+CString.h"
#import "UIEdgeInsets.h"


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

   allocator = MulleObjCInstanceGetAllocator( self);

   for( i = _n; i;)
   {
      --i;
      mulle_allocator_free( allocator, self->_segments[ i].title);
   }
   mulle_allocator_free( allocator, self->_segments);
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

   allocator = MulleObjCInstanceGetAllocator( self);
   if( segment > _n)
      segment = _n;

   size = self->_size;
   if( self->_n + 1 > size)
   {
      size = size * 2;
      if( size < 4)
         size = 4;

      self->_segments = mulle_allocator_realloc( allocator,
                                                 self->_segments,
                                                 size * sizeof( struct MulleUISegment));
      self->_size = size;
   }

   memmove( &self->_segments[ segment + 1], 
            &self->_segments[ segment], 
            (self->_n - segment) * sizeof( struct MulleUISegment));

   self->_segments[ segment].title   = mulle_allocator_strdup( allocator, title);
   self->_segments[ segment].offset =  segment ? self->_segments[ segment - 1].offset
                                               : CGSizeMake( 0, 0);
   self->_segments[ segment].backgroundColor = [self backgroundColor];
   self->_n++;
}                         

- (void) setContentOffset:(CGSize) offset 
        forSegmentAtIndex:(NSUInteger) segment
{
   if( segment >= self->_n)
      abort();

   self->_segments[ segment].offset = offset;
}

- (void) setBackgroundColor:(CGColorRef) color 
          forSegmentAtIndex:(NSUInteger) segment
{
   if( segment >= self->_n)
      abort();

   self->_segments[ segment].backgroundColor = color;
}

- (void) drawBackgroundInContext:(CGContext *) context
{
}

- (void) drawBorderInContext:(CGContext *) context
{
}


static inline int   is_first_segment( NSUInteger i, NSUInteger n)
{
   return( i == 0);
}

static inline int   is_last_segment( NSUInteger i, NSUInteger n)
{
   return( i == n - 1);
}


static inline int   is_middle_segment( NSUInteger i, NSUInteger n)
{
   return( n > 2 && ! is_first_segment( i, n) && ! is_last_segment( i, n));
}


static inline int   is_only_segment( NSUInteger i, NSUInteger n)
{
   return( n == 1);
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
   CGColorRef          color;
   UIEdgeInsets        insets;
   
   if( ! _n)
      return;

   vg    = [context nvgContext];
   frame = [self frame];

   strokeWidth = 1.5;

   segmentFrame             = frame;
   segmentFrame.origin.x    = frame.origin.x + strokeWidth / 2.0;
   segmentFrame.origin.y    = frame.origin.y + strokeWidth / 2.0;
   segmentFrame.size.width  = frame.size.width / _n - strokeWidth;
   segmentFrame.size.height = frame.size.height - strokeWidth;

   for( i = 0; i < _n; i++)
   {
      _segments[ i].frame    = segmentFrame;
      segmentFrame.origin.x += segmentFrame.size.width + strokeWidth;
   }

   // fill inner colors, use clipping to cut off at neighbor

   for( i = 0; i < _n; i++)
   {
      color = _segments[ i].backgroundColor;
      nvgFillColor( vg, color);

      if( is_middle_segment( i, _n))
      {      
         nvgShapeAntiAlias( vg, 0);      

         nvgBeginPath( vg);
         nvgRect( vg, _segments[ i].frame.origin.x, 
                      _segments[ i].frame.origin.y, 
                      _segments[ i].frame.size.width, 
                      _segments[ i].frame.size.height);
         nvgFill( vg);
         nvgShapeAntiAlias( vg, 1);  
         continue;    
      }

      if( is_first_segment( i, _n))
      {
         nvgShapeAntiAlias( vg, 0);
         nvgBeginPath( vg);
         // fill top/right and bottom/right corner
         nvgRect( vg, _segments[ i].frame.origin.x + _segments[ i].frame.size.width - _cornerRadius, 
                      _segments[ i].frame.origin.y, 
                      _cornerRadius, 
                      _cornerRadius);    
         nvgRect( vg, _segments[ i].frame.origin.x + _segments[ i].frame.size.width - _cornerRadius, 
                      _segments[ i].frame.origin.y + _segments[ i].frame.size.height - _cornerRadius,
                      _cornerRadius, 
                      _cornerRadius);                                     
         nvgFill( vg);
         nvgShapeAntiAlias( vg, 1);  
      }
      else
         if( is_last_segment( i, _n))
         {
            // fill top/left and bottom/left corner
            nvgShapeAntiAlias( vg, 0);
            nvgBeginPath( vg);

            nvgRect( vg, _segments[ i].frame.origin.x, 
                         _segments[ i].frame.origin.y, 
                         _cornerRadius, 
                         _cornerRadius);    
            nvgRect( vg, _segments[ i].frame.origin.x, 
                         _segments[ i].frame.origin.y + _segments[ i].frame.size.height - _cornerRadius,
                         _cornerRadius, 
                         _cornerRadius);                
            nvgFill( vg);
            nvgShapeAntiAlias( vg, 1);  
         }
   
      nvgBeginPath( vg);
      nvgRoundedRect( vg, _segments[ i].frame.origin.x, 
                          _segments[ i].frame.origin.y, 
                          _segments[ i].frame.size.width, 
                          _segments[ i].frame.size.height, 
                          _cornerRadius);
      nvgFill( vg);
   }


   // draw surrounding box , antialias again

   nvgBeginPath( vg);
   nvgRoundedRect( vg, frame.origin.x, 
                       frame.origin.y, 
                       frame.size.width, 
                       frame.size.height, 
                        _cornerRadius);

   // draw dividers
   // calculate inner frame without surrounding border
   for( i = 1; i < _n; i++)
   {
      midX  = CGRectGetMaxX( _segments[ i - 1].frame);
      midX += strokeWidth / 2.0;

      nvgMoveTo( vg, midX, _segments[i].frame.origin.y);
      nvgLineTo( vg, midX, CGRectGetMaxY( _segments[i].frame));
   }
   nvgStrokeColor( vg, nvgRGBA(127,127,255,255));
   nvgStrokeWidth( vg, (int) strokeWidth);
   nvgStroke( vg);
 

   // draw text labels in each segment

   font = [context fontWithName:_fontName ? _fontName : "sans"];
   name = [font name];  // get actual name, which could have different address

   fontPixelSize = [self fontPixelSize];
   if( fontPixelSize == 0.0)
      fontPixelSize = frame.size.height - strokeWidth;

	nvgFontSize( vg, fontPixelSize);
	nvgFontFace( vg, name);
   nvgTextAlign( vg,NVG_ALIGN_CENTER|NVG_ALIGN_MIDDLE);

   for( i = 0; i < _n; i++)
   {
      color = _segments[ i].backgroundColor;
      if( CGColorGetAlpha( color) < 1.0)
         color = [self textBackgroundColor];
      nvgTextColor( vg, [self textColor], color); // TODO: use textColor

      // center screen in the middle, for that we specify the center point
   	nvgText( vg, _segments[i].frame.origin.x + (_segments[ i].offset.width * 2)  + _segments[i].frame.size.width / 2.0, 
                   _segments[i].frame.origin.y + (_segments[ i].offset.height * 2) + _segments[i].frame.size.height / 2.0, 
                   _segments[ i].title, NULL);
   }
}

@end
