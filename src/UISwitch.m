#import "UISwitch.h"

#import "MulleCheckboxLayer.h"


@implementation UISwitch : UIView

- (id) initWithFrame:(CGRect) frame
{
   MulleCheckboxLayer  *checkboxLayer;

   checkboxLayer = [[[MulleCheckboxLayer alloc] initWithFrame:frame] autorelease];
   return( [self initWithLayer:checkboxLayer]);
}


//
// works as long as the return value is no struct or double
//
- (void *) forward:(void *) param
{
   MulleCheckboxLayer  *layer;

   layer = (MulleCheckboxLayer *) _mainLayer;
   return( MulleObjCPerformSelector( layer, _cmd, param));
}


- (void) setCStringName:(char *) s 
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
   if( [super becomeFirstResponder])
   {
      fprintf( stderr, "become\n");
      [self toggleState];
      return( YES);
   }
   return( NO);
}


- (BOOL) resignFirstResponder
{
   if( [super resignFirstResponder])
   {
      fprintf( stderr, "resign\n");
      [self toggleState];
      return( YES);
   }
   return( NO);
}

@end
