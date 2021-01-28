//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "CALayer.h")
#  import "CALayer.h"
# endif
#endif

#import "import.h"

@class MullePaint;


@interface CAGradientLayer : CALayer

@property( retain) MullePaint   *paint;

@end
