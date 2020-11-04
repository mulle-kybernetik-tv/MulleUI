//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "MulleTextLayer+Selection.h"

#import "import-private.h"

#import "MulleTextLayer+Cursor.h"


@implementation MulleTextLayer ( Selection)

- (void) drawSelectionWithNVGContext:(NVGcontext *) vg
                           textRange:(NSRange) textRange
                                 row:(NSUInteger) i
{
   NSInteger                        x;
   float                            xyxy[ 4];
   CGRect                           frame;
   struct MulleTextLayerRowGlyphs   *p;
   NSRange                          selectionRange;
   CGRect                           rect;

   selectionRange = NSIntersectionRange( textRange, _selection);
   if( ! selectionRange.length)
      return;

   frame = [self frame];

   // draw background for selection, compute area by removing
   // unselected characters
   // "a[iiii]a"

   x = selectionRange.location - textRange.location;
   p = &_rowGlyphs[ i];
   if( x + selectionRange.length > p->nGlyphs)
      abort();  // can't happen or ?

   rect.origin.x    = frame.origin.x + _origin.x + p->glyphs[ x].x;
   rect.origin.y    = frame.origin.y + _origin.y + (i * _lineh) - _lineh / 2.0;
   rect.size.width  = p->glyphs[ x + selectionRange.length].x - p->glyphs[ x].x;
   rect.size.height = _lineh;

   nvgFillColor( vg, nvgRGBA(127,255,127,255));
   nvgBeginPath( vg);
   nvgRect( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height); 
   nvgFill( vg);  

   // Der nvgTextBounds code ist zum einen langsamer, zum anderen (wegen)
   // Kerning ? ist die Selektion auch nicht sonderlich stabil. 
   // Es ist besser die glpyh information zu benutzen..
#if 0
   //
   // TODO: use glyphs info here possible ? Would be much faster
   //
   switch( _alignmentMode)
   {
   case CAAlignmentLeft   :
      {
         float   offset;

         // 1) get number of characters to the left of selection
         //    then get the offset in pixels
         nvgTextBounds( vg, frame.origin.x + _origin.x, 
                            frame.origin.y + _origin.y, 
                            _rows[ i].start, 
                            &_rows[ i].start[ leftCharacters], 
                            xyxy);  
         offset = xyxy[ 2];  
                    
         nvgTextBounds( vg, offset,
                            frame.origin.y + _origin.y, 
                            &_rows[ i].start[ leftCharacters], 
                            &_rows[ i].start[ leftCharacters + selectionRange.length], 
                            xyxy);
         break;       
      } 

   case CAAlignmentRight  : 
      {
         NSUInteger   rightOffset;
         NSUInteger   rightCharacters;
         float        offset;
            // abcdef   0,5  1,3  > 4, 2 ef
         rightOffset     = selectionRange.location + selectionRange.length;
         rightCharacters = textRange.length - rightOffset;
         nvgTextBounds( vg, frame.origin.x + _origin.x, 
                            0, 
                            &_rows[ i].start[ rightOffset], 
                            &_rows[ i].start[ rightOffset + rightCharacters], 
                            xyxy);  
         offset = xyxy[ 0];  
           
          // 2) get offset and width of characters of the selection
         nvgTextBounds( vg, offset,
                            frame.origin.y + _origin.y, 
                            &_rows[ i].start[ leftCharacters], 
                            &_rows[ i].start[ leftCharacters + selectionRange.length], 
                            xyxy);                       
         break;
      } 

   case CAAlignmentCenter : 
      {
         float    offset;
         float    width;

         nvgTextBounds( vg, 0, 
                            0, 
                            _rows[ i].start, 
                            &_rows[ i].start[ leftCharacters], 
                            xyxy);  
         offset = xyxy[ 2] - xyxy[ 0];
         nvgTextBounds( vg, 0,
                            0, 
                            &_rows[ i].start[ leftCharacters], 
                            &_rows[ i].start[ leftCharacters + selectionRange.length], 
                            xyxy);
         width = xyxy[ 2] - xyxy[ 0];

         nvgTextBounds( vg, frame.origin.x + _origin.x,
                            frame.origin.y + _origin.y, 
                            _rows[ i].start,
                            _rows[ i].end,
                            xyxy);
         xyxy[ 0] += offset;
         xyxy[ 2]  = xyxy[ 0] + width;
      }
   }
#endif            
}



// #1 When selecting left, one on the right of the actual 
//    cursor is being selected
// #2 When selecting right, there is no way to deselect all
// 
- (void) startSelectionAtPoint:(CGPoint) point 
{
   NSUInteger   i;

   i = [self characterIndexForPoint:point];
   if( i == NSNotFound)
      return;

   _selection      = NSMakeRange( i, 0);  // memorize start
   _startSelection = i;   
}


- (void) adjustSelectionToPoint:(CGPoint) point 
{
   NSUInteger   i;

   i = [self characterIndexForPoint:point];
   if( i == NSNotFound)
      return;

   // is cursor to the left ?
   if( i <= _startSelection)  
      _selection = NSMakeRange( i, _startSelection - i);
   else
      _selection = NSMakeRange( _startSelection, i - _startSelection);

   fprintf( stderr, "Selection: %.*s (%ld, %ld)\n", 
         (int) _selection.length, &_cString[ _selection.location],
         (long) _selection.location,
         (long) _selection.length);
}

@end
