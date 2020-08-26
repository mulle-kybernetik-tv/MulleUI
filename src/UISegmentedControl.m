#import "UISegmentedControl.h"

#import "MulleSegmentedControlLayer.h"
#import "UIEvent.h"
#import "UIView+CGGeometry.h"
#import "CGGeometry+CString.h"
#import "CGColor.h"

@implementation UISegmentedControl

- (id) initWithFrame:(CGRect) frame
{
   MulleSegmentedControlLayer  *segmentedControlLayer;

   segmentedControlLayer = [[[MulleSegmentedControlLayer alloc] initWithFrame:frame] autorelease];
   [segmentedControlLayer setBorderWidth:1.5];
   [segmentedControlLayer setBorderColor:MulleColorCreate( 0x7F7FFFFF)];
   return( [self initWithLayer:segmentedControlLayer]);
}

// move this to + UIEvent ?
- (UIEvent *) consumeMouseDown:(UIEvent *) event
{
   // figure our which segment the click, was in
   // and select this
   CGPoint       mouseLocation;
   CGPoint       contentMousePosition;
   NSUInteger    index;
   char          *s;

   assert( [self allowsEmptySelection]|| [self numberOfSelectedSegments] > 0);

   mouseLocation        = [event locationInWindow];
 //  contentMousePosition = [self convertPoint:mouseLocation 
 //                                   fromView:nil];
//
   contentMousePosition = mouseLocation;
   s = CGPointCStringDescription( mouseLocation);
   fprintf( stderr, "mouse event: %s\n", s);
   s = CGPointCStringDescription( contentMousePosition);
   fprintf( stderr, "mouse view : %s\n", s);

   index = [self segmentIndexAtPoint:contentMousePosition];
   if( index == NSNotFound)
      return( nil);

   if( ! [self isFirstResponder])
      [self becomeFirstResponder];

   [self memorizeSelectedSegments];   
   if( [self allowsMultipleSelection])
   {
      if( [self isSelectedSegmentAtIndex:index])
      {
         if( [self allowsEmptySelection] || [self numberOfSelectedSegments] > 1)
            [self deselectSegmentAtIndex:index];
      }
      else
         [self selectSegmentAtIndex:index];
   }
   else
   {
      if( [self selectedSegmentIndex] == index && [self allowsEmptySelection])
         index = -1;  
      [self setSelectedSegmentIndex:index];
   }

   return( [super consumeMouseDown:event]);
}

- (UIEvent *) consumeMouseUp:(UIEvent *) event
{
   // figure our which segment the click, was in
   // and select this
   CGPoint       mouseLocation;
   CGPoint       contentMousePosition;
   NSUInteger    index;

   mouseLocation        = [event locationInWindow];
//  contentMousePosition = [self convertPoint:mouseLocation 
//                                   fromView:nil];
//
   contentMousePosition = mouseLocation;

   index = [self segmentIndexAtPoint:contentMousePosition];
   if( index == NSNotFound)
   {
      [self recallSelectedSegments];      
      return( nil);
   }

   return( [super consumeMouseUp:event]);
}

@end
