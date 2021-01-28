//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "CAGradientLayer.h"

#import "import-private.h"



@implementation CAGradientLayer

- (BOOL) drawBackgroundInContext:(CGContext *) context
{
   [self fillBackgroundInContext:context
                           color:_backgroundColor
                           paint:_paint];
   return( NO);
}

@end
