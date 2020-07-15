//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "MulleJS+Math.h"

#import "import-private.h"

#include "mulle-js-math.h"


@implementation MulleJS ( Math)

- (void) includeJavaScript
{
   mulle_js_init_c_math( self->_state);
}

@end
