//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifndef cgpath__nano_vg_h__
#define cgpath__nano_vg_h__

#include "include.h"

#include <nanovg.h>   // TODO: make cgpath+nanovg.h private header ?
#include "CGPath.h"

// set append to YES, if you don't want to begin a new path
void nvgAddCGPath( NVGcontext *nvg, CGPathRef path);

#endif
