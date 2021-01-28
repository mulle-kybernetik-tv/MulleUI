//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "UIImage.h")
#  import "UIImage.h"
# endif
#endif

#import "import.h"


// common base class for MulleBitmapImage and MulleTextureImage

@interface _MulleBitmapImage : UIImage 

@property( readonly) struct mulle_bitmap_size   bitmapSize;
// NVGImageFlags are use for repetitive patterns
@property( readonly) int                        nvgImageFlags;
@property( readonly) void *                     image;

@end
