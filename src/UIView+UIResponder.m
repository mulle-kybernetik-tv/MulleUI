
#import "UIView+UIResponder.h"
#import "UIWindow+UIResponder.h"


@implementation UIView( UIResponder)

- (id <UIResponder>) nextResponder
{
   return( [self superview]);
}

- (BOOL) becomeFirstResponder
{
   UIWindow      *window;
   UIResponder   *firstResponder;

   window         = [self window];
   firstResponder = [window firstResponder];
   if( firstResponder)
   {   
      if( firstResponder == self)
         return( YES);
      if( ! [firstResponder canResignFirstResponder])
         return( NO);
      if( ! [firstResponder resignFirstResponder])
         return( NO);
   }
   [window makeFirstResponder:self];
   return( YES);
}

- (BOOL) resignFirstResponder
{
   return( [[self window] makeFirstResponder:nil]);
}

- (BOOL) isFirstResponder
{
   return( [[self window] firstResponder] == self);
}

@end
