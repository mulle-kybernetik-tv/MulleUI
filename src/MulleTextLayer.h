#import "CALayer.h"

// not a string in MulleUI
// TODO: rename or at least alias the k constants
typedef enum CATextLayerAlignmentMode
{
   CAAlignmentLeft = 0,
   CAAlignmentRight,
   CAAlignmentCenter

   // kCAAlignmentJustified,
   // kCAAlignmentNatural,
} CATextLayerAlignmentMode;


#define kCAAlignmentLeft    CAAlignmentLeft
#define kCAAlignmentRight   CAAlignmentRight
#define kCAAlignmentCenter  CAAlignmentCenter
  
typedef enum MulleTextLayerVerticalAlignmentMode
{
   MulleTextVerticalAlignmentMiddle = 0,  // default
   MulleTextVerticalAlignmentTop,
   MulleTextVerticalAlignmentBottom
} MulleTextLayerVerticalAlignmentMode;


struct MulleIntegerPoint
{
	NSUInteger    x;
	NSUInteger    y;
};

static inline 
   struct MulleIntegerPoint   MulleIntegerPointMake( NSUInteger x, NSUInteger y)
{
   struct MulleIntegerPoint   point;

   point.x = x;
   point.y = y;
   return( point);
}

static inline NSUInteger   MulleIntegerPointGetX( struct MulleIntegerPoint point)
{
   return( point.x);
}

static inline NSUInteger   MulleIntegerPointGetY( struct MulleIntegerPoint point)
{
   return( point.y);
}

static inline NSUInteger   MulleIntegerPointGetColumn( struct MulleIntegerPoint point)
{
   return( point.x);
}


static inline NSUInteger   MulleIntegerPointGetRow( struct MulleIntegerPoint point)
{
   return( point.y);
}



struct MulleTextLayerRowGlyphs
{
	struct mulle_structarray   glyphArray;
   NVGglyphPosition           *glyphs;
   NSUInteger                 nGlyphs;
};


typedef enum NSLineBreakMode 
{
   NSLineBreakByClipping,
   NSLineBreakByWordWrapping
} NSLineBreakMode;


MULLE_C_NONNULL_FIRST
static inline void   _MulleTextLayerRowGlyphsInit( struct MulleTextLayerRowGlyphs *p,
                                                   struct mulle_allocator *allocator)
{
   _mulle_structarray_init( &p->glyphArray, sizeof( NVGglyphPosition),
                                            alignof( NVGglyphPosition),
                                            0, 
                                            allocator); 
   p->glyphs  = 0;
   p->nGlyphs = 0;
}


static inline void   MulleTextLayerRowGlyphsDone( struct MulleTextLayerRowGlyphs *p)
{
   if( p)
      _mulle_structarray_done( &p->glyphArray); 
}


// search for 'x' position in row glyphs
NSUInteger   MulleNVGglyphPositionSearch( NVGglyphPosition *glyphs,
                                          NSUInteger nGlyphs, 
                                          CGFloat x);

//
// Though the MulleTextLayer can do multiple lines, the number of lines it
// can usefully do is restricted. It chiefly does it for the sake of 
// UILabel, which gives it multiple lines in a "cString" separated by '\n'
// It is not suitable for text with more than a screenful of lines. This is 
// because it has no scrolling smarts and because it expensively recalculates 
// all the glyphs of the text.
//
@interface MulleTextLayer  : CALayer
{
   // values exist after a frame is drawn,
   // will change on next redraw possibly
@private
   char                            *_cStringEnd;
	struct mulle_structarray        _rowArray;
   NVGtextRow                      *_rows;
   NSUInteger                      _nRows;   

	struct mulle_structarray        _rowGlyphArray; 
   struct MulleTextLayerRowGlyphs  *_rowGlyphs;

   CGPoint                         _origin;
   CGFloat                         _lineh;
   NSUInteger                      _startSelection;

   enum MulleTextLayerVerticalAlignmentMode   _verticalAlignmentMode;
}

@property( assign) char     *fontName;
@property( assign) CGFloat  fontPixelSize;
@property( assign) char     *cString;

//
// The selection of the UTF8 characters: the selection must not
// split graphemes and combined emoji. But MulleTextLayer won't check that.
//
@property( assign) NSRange          selection;
@property( observable) CGColorRef   textColor;
@property( observable) CGPoint      textOffset;

// for cleartype it's important to know the color the text is drawn on
// if the layer backgroundColor is transparent, use this color to supply
// the correct color to use
@property CGColorRef                               textBackgroundColor;
@property( assign) enum CATextLayerAlignmentMode   alignmentMode;
@property( assign) NSLineBreakMode                 lineBreakMode;

// if editable and in focus, will draw a caret/cursor
@property( assign, getter=isEditable) BOOL           editable;
@property( assign, getter=isMultiLineEnabled) BOOL   multiLineEnabled;

// cursor position as row/column
@property( assign) struct MulleIntegerPoint          cursorPosition;

- (void) getCursorPosition:(struct MulleIntegerPoint *) cursor_p;

-(enum MulleTextLayerVerticalAlignmentMode)  mulleVerticalAlignmentMode;
-(void) mulleSetVerticalAlignmentMode:(enum MulleTextLayerVerticalAlignmentMode) mode;

- (NSUInteger) characterIndexForPoint:(CGPoint) point;

@end
