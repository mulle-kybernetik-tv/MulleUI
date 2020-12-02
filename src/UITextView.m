//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UITextView.h"

#import "import-private.h"

#import "MulleTextStorage.h"
#import "MulleTextLayer.h"
#import "MulleSVGLayer.h"
#import "MulleImageLayer.h"
#import "MulleBitmapImage.h"
#import "MulleSVGImage.h"
#import "UIImage.h"
#import "UIColor.h"
#import "UIView+UIEvent.h"
#import "UIView+Layout.h"

#include <stdio.h>


@implementation UITextView

- (instancetype) initWithLayer:(CALayer *) layer 
{
   self = [super initWithLayer:layer];
   if( self)
      _textStorage = [MulleTextStorage new];
   return( self);
}


- (void) finalize 
{
   [_textStorage autorelease];
   _textStorage = nil;
   [super finalize];
}


- (void *) forward:(void *) param
{
   assert( _textStorage); // window should not forward...
   switch( _cmd)
   {
   case @selector( textData) :
   case @selector( images) :
      return( mulle_objc_object_call_variablemethodid_inline( _textStorage,
                                                             (mulle_objc_methodid_t) _cmd,
                                                             param));
   }

   // TODO: wasn't there a runtime function to call super forward: ?
   return( mulle_objc_object_call_variablemethodid_inline( _mainLayer,
                                                          (mulle_objc_methodid_t) _cmd,
                                                          param));
}


- (void) setTextData:(NSData *) data
{
   Class             nsNumberClass;
   NSUInteger        i;
   CALayer           *layer;
   MulleImageLayer   *imageLayer;
   MulleTextLayer    *textLayer;
   MulleSVGLayer     *svgLayer;
   UIImage           *image;
   CGRect            textViewFrame;
   CGRect            layerFrame;
   id                line;

   [_textStorage setTextData:data];

   // [self removeAllViews]; 
   textViewFrame          = [self frame];
   layerFrame.origin      = textViewFrame.origin;
   layerFrame.size.width  = textViewFrame.size.width;
   layerFrame.size.height = 0.0;
   nsNumberClass = [NSNumber class];

   for( line in _textStorage)
   {
      // step over previous
      layerFrame.origin.y   += layerFrame.size.height;

      if( [line isKindOfClass:nsNumberClass])
      {
         image = [_textStorage imageForNumber:line];
         if( [image isKindOfClass:[MulleBitmapImage class]])
         {
            imageLayer = [[[MulleImageLayer alloc] initWithImage:image] autorelease];
            [imageLayer setBackgroundColor:[UIColor blueColor]];
            layer      = imageLayer;
         }
         else
         {
            svgLayer = [[[MulleSVGLayer alloc] initWithImage:image] autorelease];
            layer    = svgLayer;
         }

         layerFrame.size     = [image size];
         layerFrame.origin.x = textViewFrame.origin.x + 
                               (textViewFrame.size.width - layerFrame.size.width) / 2.0;
      }
      else
      {
         textLayer = [[[MulleTextLayer alloc] initWithFrame:CGRectZero] autorelease];
         [textLayer setUTF8Data:mulle_data_as_utf8data( [line mulleData])];
         [textLayer setFontPixelSize:20.0];
         [textLayer setBackgroundColor:[UIColor yellowColor]];
         [textLayer setTextBackgroundColor:[UIColor yellowColor]];

         layerFrame.origin.x    = textViewFrame.origin.x;
         layerFrame.size.width  = textViewFrame.size.width;
         layerFrame.size.height = 20;

         layer = textLayer;
      }

      [layer setFrame:layerFrame];
    
      [self addLayer:layer];  
   }
}

//
// If the textStorage changes, this will mean that the selection is invalid
// as it could be splitting UTF8 seqeuences. If the whole textStorage is 
// replaced, it will be very, very hard to keep a selection alive.
//
- (void) reflectSelection
{
   struct mulle_pointerarrayenumerator   rover;
   NSUInteger                            length;
   CALayer                               *layer;
   CGRect                                frame;
   Class                                 textLayerClass;
   NSUInteger                            offset;
   NSRange                               layerRange;
   NSRange                               intersection;
   MulleTextLayer                        *textLayer;
   MulleImageLayer                       *imageLayer;
   
   // we aren't really doing layout of subviews here, but it seems to be 
   // a good time for setting selection and cursor

   textLayerClass = [MulleTextLayer class];

   offset = 0;

   rover = mulle_pointerarray_enumerate( _layers);
   while( _mulle_pointerarrayenumerator_next( &rover, (void **) &layer))
   {
      if( [layer isKindOfClass:textLayerClass]) 
      {
         textLayer    = (MulleTextLayer *) layer;
         length       = [textLayer UTF8Data].length;
         layerRange   = NSMakeRange( offset, length);
         intersection = NSIntersectionRange( _selection, layerRange);
         if( intersection.length)
            intersection.location -= offset;
         else
            intersection.location = 0;
         [textLayer setSelection:intersection];
         offset += length;
      }   
      else
      {
         // MulleSVGLayer is compatible with MulleImageLayer with regard to
         // selection
         imageLayer   = (MulleImageLayer *) layer;
         [imageLayer setSelected:NSLocationInRange( offset, _selection)];
         offset += 1;         
         // MulleSVGLayer or MulleImageLayer
      }  
   }
   _mulle_pointerarrayenumerator_done( &rover);
}


- (void) reflectCursor
{
   struct mulle_pointerarrayenumerator   rover;
   NSUInteger                            length;
   CALayer <MulleCursor>                 *layer;
   CGRect                                frame;
   Class                                 textLayerClass;
   NSUInteger                            row;
   NSRange                               layerRange;
   NSRange                               intersection;
   
   row   = 0;
   rover = mulle_pointerarray_enumerate( _layers);
   while( _mulle_pointerarrayenumerator_next( &rover, (void **) &layer))
   {
      if( _cursorPosition.y == row)
      {
         [layer setEditable:YES];
         [layer setCursorPosition:MulleIntegerPointMake( _cursorPosition.x, 0)];
      }
      else  
         [layer setEditable:NO];
      row += 1;
   }
   _mulle_pointerarrayenumerator_done( &rover);
}


- (void) layoutSubviews
{
   [super layoutSubviews];
   [self reflectSelection];
}


- (void) setSelection:(NSRange) selection
{
   _selection = selection;
   [self reflectSelection];
}

- (void) setCursorPosition:(struct MulleIntegerPoint) point
{
   _cursorPosition = point;
   [self reflectCursor];
}



- (NSUInteger) rowOfLayer:(CALayer *) search 
{
   struct mulle_pointerarrayenumerator   rover;
   CALayer                               *layer;
   NSUInteger                            row;

   row   = 0;
   rover = mulle_pointerarray_enumerate( _layers);
   while( _mulle_pointerarrayenumerator_next( &rover, (void **) &layer))
   {
      if( layer == search)
         break;

      row += 1;         
   }
   _mulle_pointerarrayenumerator_done( &rover);

   return( row);
}


- (NSUInteger) offsetOfLayer:(CALayer *) search 
{
   struct mulle_pointerarrayenumerator   rover;
   NSUInteger                            length;
   CALayer                               *layer;
   Class                                 textLayerClass;
   NSUInteger                            offset;
   MulleTextLayer                        *textLayer;

   offset         = 0;
   textLayerClass = [MulleTextLayer class];

   rover = mulle_pointerarray_enumerate( _layers);
   while( _mulle_pointerarrayenumerator_next( &rover, (void **) &layer))
   {
      if( layer == search)
         break;

      if( [layer isKindOfClass:textLayerClass]) 
      {
         textLayer = (MulleTextLayer *) layer;
         length    = [textLayer UTF8Data].length;
         offset   += length;
      }   
      else
      {
         offset += 1;         
      }  
   }
   _mulle_pointerarrayenumerator_done( &rover);

   return( offset);
}


- (void) startSelectionAtPoint:(CGPoint) mouseLocation
{
   CALayer       *layer;
   NSUInteger    i;
   NSUInteger    offset;

   fprintf( stderr, "%s\n", __PRETTY_FUNCTION__);

   layer = [self layerAtPoint:mouseLocation];
   if( ! layer)
      return;

   i = [(MulleTextLayer *) layer characterIndexForPoint:mouseLocation];
   if( i == NSNotFound)
      return;

   offset = [self offsetOfLayer:layer];
   i     += offset;

   _startSelection = i;   
   [self setSelection:NSMakeRange( i, 0)];  // memorize start

 //  [layer setBackgroundColor:[UIColor redColor]];
}


- (void) adjustSelectionToPoint:(CGPoint) mouseLocation
{
   CALayer       *layer;
   NSUInteger    i;
   NSUInteger    offset;

   layer = [self layerAtPoint:mouseLocation];
   if( ! layer)
      return;

   i = [(MulleTextLayer *) layer characterIndexForPoint:mouseLocation];
   if( i == NSNotFound)
      return;

   offset = [self offsetOfLayer:layer];
   i     += offset;

   // is cursor to the left ?
   if( i <= _startSelection)  
      [self setSelection:NSMakeRange( i, _startSelection - i)];
   else
      [self setSelection:NSMakeRange( _startSelection, i - _startSelection)];
#if 0
   fprintf( stderr, "Selection: %.*s (%ld, %ld)\n", 
         (int) _selection.length, &_data.characters[ _selection.location],
         (long) _selection.location,
         (long) _selection.length);

#endif
}


- (struct MulleIntegerPoint) cursorPositionForPoint:(CGPoint) mouseLocation
{
   CALayer <MulleCursor>      *layer;
   NSUInteger                 row;
   struct MulleIntegerPoint   cursor;
   CGRect                     frame;
   CGRect                     layerFrame;
   CGPoint                    point;

   layer = (id) [self layerAtPoint:mouseLocation];
   if( ! layer)
      return( MulleIntegerPointMake( -1, -1));

   frame      = [self frame];
   layerFrame = [layer frame];
   point.x = mouseLocation.x;
   point.y = mouseLocation.y - (layerFrame.origin.y - frame.origin.y);

   cursor   = [layer cursorPositionForPoint:point];
   if( cursor.x == -1)
      return( MulleIntegerPointMake( -1, -1));
     
   row      = [self rowOfLayer:layer];
   cursor.y += row;

   return( cursor);
}


- (void) setCursorPositionToPoint:(CGPoint) mouseLocation
{
   struct MulleIntegerPoint   cursor;

   cursor = [self cursorPositionForPoint:mouseLocation];
   if( cursor.x == -1)
      return;

   [self setCursorPosition:cursor];
}


@end
