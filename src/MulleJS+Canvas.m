//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "MulleJS+Canvas.h"

#import "import-private.h"

#include "mulle-js-math.h"
#include "mulle-js-nanovg.h"



@implementation MulleJS ( Canvas)

MULLE_OBJC_DEPENDS_ON_CATEGORY( MulleJS, MulleUI);

- (void) includeJavaScript
{
   mulle_js_init_javascript_math( self->_state);
   mulle_js_init_nanovg_canvas( self->_state);
}

@end
