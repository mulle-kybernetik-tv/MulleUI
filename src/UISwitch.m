#import "UISwitch.h"

#import "MulleCheckboxLayer.h"


@implementation UISwitch

- (id) initWithFrame:(CGRect) frame
{
   MulleCheckboxLayer  *checkboxLayer;

   checkboxLayer = [[[MulleCheckboxLayer alloc] initWithFrame:frame] autorelease];
   return( [self initWithLayer:checkboxLayer]);
}


- (void) setDebugNameCString:(char *) s
{
   // ignore
}

- (void) setState:(UIControlState) state
{
   MulleCheckboxLayer  *layer;

   if( _state == state)
      return;

   _state = state;

   layer = (MulleCheckboxLayer *) _mainLayer;
   [layer setChecked:[self isSelected]];
}

- (BOOL) becomeFirstResponder
{
   // I think calling this too often is not good, as it does too much
   assert( ! [self isFirstResponder]);

   if( [super becomeFirstResponder])
   {
      [self mulleToggleSelectedState];
      return( YES);
   }
   return( NO);
}

@end
